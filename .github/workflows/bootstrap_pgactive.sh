#!/bin/bash
set -euo pipefail

# ============================================================
# COLORS FOR OUTPUT
# ============================================================
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color

success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
fail()    { echo -e "${RED}[FAILED]${NC} $1"; exit 1; }
info()    { echo -e "${YELLOW}[INFO]${NC} $1"; }

# ============================================================
# CONFIGURATION
# ============================================================
SECRET_NAME="qa/docmp/db"
AWS_REGION="us-gov-west-1"
DB_PORT=5430

info "Installing required tools..."
sudo yum install -y postgresql17 jq awscli || fail "Failed to install required tools"
success "Tools installed"

# ============================================================
# RETRIEVE CREDS + ENDPOINTS FROM SECRETS MANAGER
# ============================================================
info "Pulling DB credentials + endpoints from Secrets Manager..."

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --region "$AWS_REGION" \
  --secret-id "$SECRET_NAME" \
  --query SecretString \
  --output text) || fail "Unable to retrieve secret: $SECRET_NAME"

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')
DB_ENDPOINT_1=$(echo "$SECRET_JSON" | jq -r '.db_endpoint_1')
DB_ENDPOINT_2=$(echo "$SECRET_JSON" | jq -r '.db_endpoint_2')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.dbname')

export PGPASSWORD="$DB_PASSWORD"

success "Secrets loaded successfully"
info "Node 1: $DB_ENDPOINT_1"
info "Node 2: $DB_ENDPOINT_2"

# ============================================================
# HELPER FUNCTIONS
# ============================================================
run_psql_root() {
  local HOST=$1
  local SQL=$2
  psql "host=$HOST port=$DB_PORT dbname=postgres user=postgres" -c "$SQL"
}

run_psql_user() {
  local HOST=$1
  local SQL=$2
  psql "host=$HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER" -c "$SQL"
}

run_psql_file() {
  local HOST=$1
  local FILE=$2
  psql "host=$HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER" -f "$FILE"
}

# ============================================================
# NODE 1 — SETUP
# ============================================================
info "Configuring Node 1..."

run_psql_root "$DB_ENDPOINT_1" "CREATE DATABASE $DB_NAME;" || info "DB already exists on Node 1"
run_psql_root "$DB_ENDPOINT_1" "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD' LOGIN;" || info "User already exists on Node 1"
run_psql_root "$DB_ENDPOINT_1" "GRANT rds_replication, rds_superuser TO $DB_USER;" || fail "Failed to grant privileges on Node 1"
run_psql_root "$DB_ENDPOINT_1" "ALTER DATABASE $DB_NAME OWNER TO $DB_USER;" || fail "Failed to assign DB ownership on Node 1"

run_psql_user "$DB_ENDPOINT_1" "CREATE EXTENSION IF NOT EXISTS pgcrypto;" || fail "Failed to enable pgcrypto on Node 1"
run_psql_user "$DB_ENDPOINT_1" "CREATE EXTENSION IF NOT EXISTS pgactive;" || fail "Failed to enable pgactive on Node 1"

run_psql_file "$DB_ENDPOINT_1" "./docmp_tables.sql" || fail "Schema load failed on Node 1"

success "Node 1 configured successfully"

# ============================================================
# NODE 2 — SETUP
# ============================================================
info "Configuring Node 2..."

run_psql_root "$DB_ENDPOINT_2" "CREATE DATABASE $DB_NAME;" || info "DB already exists on Node 2"
run_psql_root "$DB_ENDPOINT_2" "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD' LOGIN;" || info "User already exists on Node 2"
run_psql_root "$DB_ENDPOINT_2" "GRANT rds_replication, rds_superuser TO $DB_USER;" || fail "Failed to grant privileges on Node 2"
run_psql_root "$DB_ENDPOINT_2" "ALTER DATABASE $DB_NAME OWNER TO $DB_USER;" || fail "Failed to assign DB ownership on Node 2"

run_psql_user "$DB_ENDPOINT_2" "CREATE EXTENSION IF NOT EXISTS pgcrypto;" || fail "Failed to enable pgcrypto on Node 2"
run_psql_user "$DB_ENDPOINT_2" "CREATE EXTENSION IF NOT EXISTS pgactive;" || fail "Failed to enable pgactive on Node 2"

run_psql_file "$DB_ENDPOINT_2" "./docmp_tables.sql" || fail "Schema load failed on Node 2"

success "Node 2 configured successfully"

# ============================================================
# CREATE REPLICATION GROUP ON NODE 1
# ============================================================
info "Creating pgactive replication group on Node 1..."

run_psql_user "$DB_ENDPOINT_1" "
SELECT pgactive.pgactive_create_group(
  node_name := '${DB_NAME}-node1',
  node_dsn  := 'host=$DB_ENDPOINT_1 dbname=$DB_NAME port=$DB_PORT user=$DB_USER password=$DB_PASSWORD'
);" || info "Group may already exist on Node 1"

success "Replication group created on Node 1"

# ============================================================
# JOIN NODE 2 TO THE GROUP
# ============================================================
info "Node 2 joining replication group..."

run_psql_user "$DB_ENDPOINT_2" "
SELECT pgactive.pgactive_join_group(
  node_name := '${DB_NAME}-node2',
  node_dsn  := 'host=$DB_ENDPOINT_2 dbname=$DB_NAME port=$DB_PORT user=$DB_USER password=$DB_PASSWORD',
  join_using_dsn := 'host=$DB_ENDPOINT_1 dbname=$DB_NAME port=$DB_PORT user=$DB_USER password=$DB_PASSWORD'
);" || fail "Node 2 failed to join replication group"

success "Node 2 successfully joined replication group"

# ============================================================
# FINAL SUCCESS MESSAGE
# ============================================================
echo -e "${GREEN}"
echo "==============================================="
echo " ACTIVE-ACTIVE PGACTIVE SETUP COMPLETED SUCCESSFULLY "
echo "==============================================="
echo -e "${NC}"
