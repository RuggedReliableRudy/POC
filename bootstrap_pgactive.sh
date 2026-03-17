#!/bin/bash
set -euo pipefail

# ============================================================
# CONFIGURATION
# ============================================================
SECRET_NAME="qa/docmp/db"
AWS_REGION="us-gov-west-1"
DB_PORT=5430

echo "=== Installing required tools (PostgreSQL 17, jq, AWS CLI) ==="
sudo yum install -y postgresql17 jq awscli

# ============================================================
# RETRIEVE CREDS + ENDPOINTS FROM SECRETS MANAGER
# ============================================================
echo "=== Pulling DB credentials + endpoints from Secrets Manager ==="

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --region "$AWS_REGION" \
  --secret-id "$SECRET_NAME" \
  --query SecretString \
  --output text)

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')
DB_ENDPOINT_1=$(echo "$SECRET_JSON" | jq -r '.db_endpoint_1')
DB_ENDPOINT_2=$(echo "$SECRET_JSON" | jq -r '.db_endpoint_2')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.dbname')

export PGPASSWORD="$DB_PASSWORD"

echo "Node 1: $DB_ENDPOINT_1"
echo "Node 2: $DB_ENDPOINT_2"
echo "Database: $DB_NAME"
echo "User: $DB_USER"

# ============================================================
# HELPER FUNCTIONS
# ============================================================
run_psql_root() {
  local HOST=$1
  local SQL=$2
  psql "host=$HOST port=$DB_PORT dbname=postgres user=postgres" -c "$SQL" || true
}

run_psql_user() {
  local HOST=$1
  local SQL=$2
  psql "host=$HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER" -c "$SQL" || true
}

run_psql_file() {
  local HOST=$1
  local FILE=$2
  psql "host=$HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER" -f "$FILE" || true
}

# ============================================================
# NODE 1 — CREATE DB + USER + PRIVILEGES
# ============================================================
echo "=== Configuring Node 1 ==="

run_psql_root "$DB_ENDPOINT_1" "CREATE DATABASE $DB_NAME;"
run_psql_root "$DB_ENDPOINT_1" "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD' LOGIN;"
run_psql_root "$DB_ENDPOINT_1" "GRANT rds_replication, rds_superuser TO $DB_USER;"
run_psql_root "$DB_ENDPOINT_1" "ALTER DATABASE $DB_NAME OWNER TO $DB_USER;"

# Enable pgcrypto (required by pgactive)
run_psql_user "$DB_ENDPOINT_1" "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
run_psql_user "$DB_ENDPOINT_1" "CREATE EXTENSION IF NOT EXISTS pgactive;"

# Load schema
echo "=== Loading schema on Node 1 ==="
run_psql_file "$DB_ENDPOINT_1" "./docmp_tables.sql"

# ============================================================
# NODE 2 — CREATE DB + USER + PRIVILEGES
# ============================================================
echo "=== Configuring Node 2 ==="

run_psql_root "$DB_ENDPOINT_2" "CREATE DATABASE $DB_NAME;"
run_psql_root "$DB_ENDPOINT_2" "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD' LOGIN;"
run_psql_root "$DB_ENDPOINT_2" "GRANT rds_replication, rds_superuser TO $DB_USER;"
run_psql_root "$DB_ENDPOINT_2" "ALTER DATABASE $DB_NAME OWNER TO $DB_USER;"

# Enable pgcrypto + pgactive
run_psql_user "$DB_ENDPOINT_2" "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
run_psql_user "$DB_ENDPOINT_2" "CREATE EXTENSION IF NOT EXISTS pgactive;"

# Load schema
echo "=== Loading schema on Node 2 ==="
run_psql_file "$DB_ENDPOINT_2" "./docmp_tables.sql"

# ============================================================
# CREATE REPLICATION GROUP ON NODE 1
# ============================================================
echo "=== Creating pgactive replication group on Node 1 ==="

run_psql_user "$DB_ENDPOINT_1" "
SELECT pgactive.pgactive_create_group(
  node_name := '${DB_NAME}-node1',
  node_dsn  := 'host=$DB_ENDPOINT_1 dbname=$DB_NAME port=$DB_PORT user=$DB_USER password=$DB_PASSWORD'
);
"

# ============================================================
# JOIN NODE 2 TO THE GROUP
# ============================================================
echo "=== Node 2 joining pgactive replication group ==="

run_psql_user "$DB_ENDPOINT_2" "
SELECT pgactive.pgactive_join_group(
  node_name := '${DB_NAME}-node2',
  node_dsn  := 'host=$DB_ENDPOINT_2 dbname=$DB_NAME port=$DB_PORT user=$DB_USER password=$DB_PASSWORD',
  join_using_dsn := 'host=$DB_ENDPOINT_1 dbname=$DB_NAME port=$DB_PORT user=$DB_USER password=$DB_PASSWORD'
);
"

echo "=== Active-Active pgactive setup complete ==="
