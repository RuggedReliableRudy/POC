#!/bin/bash
set -euo pipefail

INSTANCE_ID="$1"
S3_BUCKET="$2"
JAR_PATH="$3"
DB_ENDPOINT_1="$4"
DB_ENDPOINT_2="$5"
DB_NAME="$6"
DB_PORT="$7"
DB_USER="$8"
SECRET_NAME="$9"

echo "=== Uploading JAR to S3 bucket: project-accumulator-glue-job ==="
aws s3 cp AccumulatorLoad-1.0.0.jar "s3://project-accumulator-glue-job/accumulator.jar"

if [ -f "docmp_tables.sql" ]; then
  echo "=== Uploading schema file to S3 ==="
  aws s3 cp "docmp_tables.sql" "s3://project-accumulator-glue-job/docmp_tables.sql"
fi

echo "=== Building SSM command payload ==="

read -r -d '' COMMANDS <<'EOF'
set -e

echo "=== Installing required tools ==="
sudo yum install -y postgresql15 jq awscli

echo "=== Creating base directories ==="
sudo mkdir -p /opt/accumulator
sudo mkdir -p /opt/cpe-app
sudo chown ec2-user:ec2-user /opt/cpe-app
sudo chmod 755 /opt/cpe-app

echo "=== Downloading JAR from S3 ==="
sudo aws s3 cp s3://project-accumulator-glue-job/accumulator.jar /opt/accumulator/accumulator.jar
sudo chmod 755 /opt/accumulator/accumulator.jar

echo "=== Copying JAR into application directory ==="
sudo cp /opt/accumulator/accumulator.jar /opt/cpe-app/AccumulatorLoad-1.0.0.jar
sudo chmod 755 /opt/cpe-app/AccumulatorLoad-1.0.0.jar
sudo chown ec2-user:ec2-user /opt/cpe-app/AccumulatorLoad-1.0.0.jar

echo "=== Writing db_active.conf ==="
sudo bash -c "cat > /opt/accumulator/db_active.conf <<CONFIG
db_endpoint_1=\$DB_ENDPOINT_1
db_endpoint_2=\$DB_ENDPOINT_2
db_name=\$DB_NAME
db_port=\$DB_PORT
CONFIG"

echo "=== Retrieving DB password from Secrets Manager ==="
SECRET_JSON=$(aws secretsmanager get-secret-value \
  --region us-gov-west-1 \
  --secret-id "accumulator" \
  --query SecretString \
  --output text)

DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')
export PGPASSWORD="$DB_PASSWORD"

echo "=== Writing application DB properties ==="
sudo bash -c "cat > /opt/cpe-app/db.properties <<PROPS
db.primary.host=\$DB_ENDPOINT_1
db.secondary.host=\$DB_ENDPOINT_2
db.port=\$DB_PORT
db.name=\$DB_NAME
db.user=\$DB_USER
db.password=\$DB_PASSWORD
PROPS"
sudo chmod 600 /opt/cpe-app/db.properties
sudo chown ec2-user:ec2-user /opt/cpe-app/db.properties

echo "=== Creating systemd service for cpe-app ==="
sudo bash -c "cat > /etc/systemd/system/cpe-app.service <<SERVICE
[Unit]
Description=Accumulator Load Service
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/opt/cpe-app
ExecStart=/usr/bin/java -jar /opt/cpe-app/AccumulatorLoad-1.0.0.jar \\
  --spring.config.additional-location=/opt/cpe-app/db.properties
Restart=always
RestartSec=5
Environment=JAVA_OPTS=\"-Xms512m -Xmx1024m\"

[Install]
WantedBy=multi-user.target
SERVICE"

echo "=== Reloading systemd and restarting service ==="
sudo systemctl daemon-reload
sudo systemctl enable cpe-app
sudo systemctl restart cpe-app

if aws s3 ls "s3://project-accumulator-glue-job/docmp_tables.sql" >/dev/null 2>&1; then
  echo "=== Downloading schema file for pgactive setup ==="
  sudo aws s3 cp s3://project-accumulator-glue-job/docmp_tables.sql /opt/accumulator/docmp_tables.sql

  echo "=== Creating DB + user and loading schema on Node 1 ==="
  psql "host=\$DB_ENDPOINT_1 port=5430 dbname=postgres user=postgres" \
    -c "CREATE DATABASE \$DB_NAME;" || true

  psql "host=\$DB_ENDPOINT_1 port=5430 dbname=postgres user=postgres" \
    -c "CREATE USER \$DB_USER WITH PASSWORD '\$DB_PASSWORD' LOGIN;" || true

  psql "host=\$DB_ENDPOINT_1 port=5430 dbname=postgres user=postgres" \
    -c "GRANT rds_replication, rds_superuser TO \$DB_USER;"

  psql "host=\$DB_ENDPOINT_1 port=5430 dbname=postgres user=postgres" \
    -c "ALTER DATABASE \$DB_NAME OWNER TO \$DB_USER;"

  psql "host=\$DB_ENDPOINT_1 port=5430 dbname=\$DB_NAME user=\$DB_USER" \
    -f /opt/accumulator/docmp_tables.sql || true

  echo "=== Enabling pgactive on Node 1 ==="
  psql "host=\$DB_ENDPOINT_1 port=5430 dbname=\$DB_NAME user=\$DB_USER" \
    -c "CREATE EXTENSION IF NOT EXISTS pgactive;"

  echo "=== Creating DB + user and loading schema on Node 2 ==="
  psql "host=\$DB_ENDPOINT_2 port=5430 dbname=postgres user=postgres" \
    -c "CREATE DATABASE \$DB_NAME;" || true

  psql "host=\$DB_ENDPOINT_2 port=5430 dbname=postgres user=postgres" \
    -c "CREATE USER \$DB_USER WITH PASSWORD '\$DB_PASSWORD' LOGIN;" || true

  psql "host=\$DB_ENDPOINT_2 port=5430 dbname=postgres user=postgres" \
    -c "GRANT rds_replication, rds_superuser TO \$DB_USER;"

  psql "host=\$DB_ENDPOINT_2 port=5430 dbname=postgres user=postgres" \
    -c "ALTER DATABASE \$DB_NAME OWNER TO \$DB_USER;"

  psql "host=\$DB_ENDPOINT_2 port=5430 dbname=\$DB_NAME user=\$DB_USER" \
    -f /opt/accumulator/docmp_tables.sql || true

  echo "=== Enabling pgactive on Node 2 ==="
  psql "host=\$DB_ENDPOINT_2 port=5430 dbname=\$DB_NAME user=\$DB_USER" \
    -c "CREATE EXTENSION IF NOT EXISTS pgactive;"

  echo "=== Creating pgactive group on Node 1 ==="
  psql "host=\$DB_ENDPOINT_1 port=5430 dbname=\$DB_NAME user=\$DB_USER" \
    -c "SELECT pgactive.pgactive_create_group(
          node_name := '\${DB_NAME}-endpoint1-app',
          node_dsn := 'host=\$DB_ENDPOINT_1 dbname=\$DB_NAME port=5430 user=\$DB_USER password=\$DB_PASSWORD'
        );" || true

  echo "=== Joining Node 2 to pgactive group ==="
  psql "host=\$DB_ENDPOINT_2 port=5430 dbname=\$DB_NAME user=\$DB_USER" \
    -c "SELECT pgactive.pgactive_join_group(
          node_name := '\${DB_NAME}-endpoint2-app',
          node_dsn := 'host=\$DB_ENDPOINT_2 dbname=\$DB_NAME port=5430 user=\$DB_USER password=\$DB_PASSWORD',
          join_using_dsn := 'host=\$DB_ENDPOINT_1 dbname=\$DB_NAME port=5430 user=\$DB_USER password=\$DB_PASSWORD'
        );" || true
fi

echo "=== Deployment and pgactive setup completed on instance ==="
EOF

echo "=== Sending SSM Run Command to EC2 instance: $INSTANCE_ID ==="

aws ssm send-command \
  --document-name "AWS-RunShellScript" \
  --targets "Key=InstanceIds,Values=$INSTANCE_ID" \
  --parameters "commands=$COMMANDS" \
  --region us-gov-west-1 \
  --output text

echo "=== Deployment triggered successfully ==="
