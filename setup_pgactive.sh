#!/bin/bash
set -euo pipefail

DB_ENDPOINT_1="$1"
DB_ENDPOINT_2="$2"
DB_NAME="$3"
DB_USER="$4"
SECRET_NAME="$5"

echo "=== Installing required tools ==="
sudo yum install -y postgresql15 jq awscli

echo "=== Retrieving DB password from Secrets Manager ==="
SECRET_JSON=$(aws secretsmanager get-secret-value \
  --region us-gov-west-1 \
  --secret-id "$SECRET_NAME" \
  --query SecretString \
  --output text)

DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')

export PGPASSWORD="$DB_PASSWORD"

# ============================================================
# NODE 1 — Create DB + User
# ============================================================
echo "=== Creating DB + user on Node 1 ==="
psql "host=$DB_ENDPOINT_1 port=5430 dbname=postgres user=postgres" \
  -c "CREATE DATABASE $DB_NAME;" || true

psql "host=$DB_ENDPOINT_1 port=5430 dbname=postgres user=postgres" \
  -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD' LOGIN;" || true

psql "host=$DB_ENDPOINT_1 port=5430 dbname=postgres user=postgres" \
  -c "GRANT rds_replication, rds_superuser TO $DB_USER;"

psql "host=$DB_ENDPOINT_1 port=5430 dbname=postgres user=postgres" \
  -c "ALTER DATABASE $DB_NAME OWNER TO $DB_USER;"

# ============================================================
# NODE 1 — Load Schema
# ============================================================
echo "=== Loading schema on Node 1 ==="
psql "host=$DB_ENDPOINT_1 port=5430 dbname=$DB_NAME user=$DB_USER" \
  -f /opt/accumulator/docmp_tables.sql || true

# ============================================================
# NODE 1 — Enable pgactive
# ============================================================
echo "=== Enabling pgactive on Node 1 ==="
psql "host=$DB_ENDPOINT_1 port=5430 dbname=$DB_NAME user=$DB_USER" \
  -c "CREATE EXTENSION IF NOT EXISTS pgactive;"

# ============================================================
# NODE 2 — Create DB + User
# ============================================================
echo "=== Creating DB + user on Node 2 ==="
psql "host=$DB_ENDPOINT_2 port=5430 dbname=postgres user=postgres" \
  -c "CREATE DATABASE $DB_NAME;" || true

psql "host=$DB_ENDPOINT_2 port=5430 dbname=postgres user=postgres" \
  -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD' LOGIN;" || true

psql "host=$DB_ENDPOINT_2 port=5430 dbname=postgres user=postgres" \
  -c "GRANT rds_replication, rds_superuser TO $DB_USER;"

psql "host=$DB_ENDPOINT_2 port=5430 dbname=postgres user=postgres" \
  -c "ALTER DATABASE $DB_NAME OWNER TO $DB_USER;"

# ============================================================
# NODE 2 — Load Schema
# ============================================================
echo "=== Loading schema on Node 2 ==="
psql "host=$DB_ENDPOINT_2 port=5430 dbname=$DB_NAME user=$DB_USER" \
  -f /opt/accumulator/docmp_tables.sql || true

# ============================================================
# NODE 2 — Enable pgactive
# ============================================================
echo "=== Enabling pgactive on Node 2 ==="
psql "host=$DB_ENDPOINT_2 port=5430 dbname=$DB_NAME user=$DB_USER" \
  -c "CREATE EXTENSION IF NOT EXISTS pgactive;"

# ============================================================
# Create replication group
# ============================================================
echo "=== Creating pgactive group on Node 1 ==="
psql "host=$DB_ENDPOINT_1 port=5430 dbname=$DB_NAME user=$DB_USER" \
  -c "SELECT pgactive.pgactive_create_group(
        node_name := '${DB_NAME}-endpoint1-app',
        node_dsn := 'host=$DB_ENDPOINT_1 dbname=$DB_NAME port=5430 user=$DB_USER password=$DB_PASSWORD'
      );" || true

echo "=== Joining Node 2 to pgactive group ==="
psql "host=$DB_ENDPOINT_2 port=5430 dbname=$DB_NAME user=$DB_USER" \
  -c "SELECT pgactive.pgactive_join_group(
        node_name := '${DB_NAME}-endpoint2-app',
        node_dsn := 'host=$DB_ENDPOINT_2 dbname=$DB_NAME port=5430 user=$DB_USER password=$DB_PASSWORD',
        join_using_dsn := 'host=$DB_ENDPOINT_1 dbname=$DB_NAME port=5430 user=$DB_USER password=$DB_PASSWORD'
      );" || true

echo "=== pgactive setup complete ==="
