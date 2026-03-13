export NODE1_HOST="your-node1-endpoint"
export NODE2_HOST="your-node2-endpoint"

export PORT=5430
export DB_NAME="docmp_qa_db"

# RDS master credentials
export ADMIN_USER1="masteruser1"
export ADMIN_PASS1="password1"

export ADMIN_USER2="masteruser2"
export ADMIN_PASS2="password2"

# App users (for replication + app)
export APP_USER1="docmpqauser1"
export APP_PASS1="docmpadmin"

export APP_USER2="docmpqauser2"
export APP_PASS2="docmpadmin"



sudo rpm --import https://download.postgresql.org/pub/repos/yum/RPM-GPG-KEY-PGDG
sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo yum install -y postgresql17






#!/bin/bash
set -e

echo "=== Starting FULL pgactive + DB setup (Version A: recreate DB) ==="

# -----------------------------
# Required Environment Variables
# -----------------------------
: "${NODE1_HOST:?Missing NODE1_HOST}"
: "${NODE2_HOST:?Missing NODE2_HOST}"
: "${DB_NAME:?Missing DB_NAME}"
: "${PORT:?Missing PORT}"

: "${ADMIN_USER1:?Missing ADMIN_USER1}"
: "${ADMIN_PASS1:?Missing ADMIN_PASS1}"

: "${ADMIN_USER2:?Missing ADMIN_USER2}"
: "${ADMIN_PASS2:?Missing ADMIN_PASS2}"

: "${APP_USER1:?Missing APP_USER1}"
: "${APP_PASS1:?Missing APP_PASS1}"

: "${APP_USER2:?Missing APP_USER2}"
: "${APP_PASS2:?Missing APP_PASS2}"

# -----------------------------
# Helper function
# -----------------------------
run_psql() {
  local PASS=$1
  local HOST=$2
  local USER=$3
  local DB=$4
  shift 4
  PGPASSWORD="$PASS" psql -h "$HOST" -p "$PORT" -U "$USER" -d "$DB" "$@"
}

# -----------------------------
# Connectivity Tests
# -----------------------------
echo "Testing connectivity to Node1 (admin)..."
run_psql "$ADMIN_PASS1" "$NODE1_HOST" "$ADMIN_USER1" postgres -c "SELECT version();"

echo "Testing connectivity to Node2 (admin)..."
run_psql "$ADMIN_PASS2" "$NODE2_HOST" "$ADMIN_USER2" postgres -c "SELECT version();"

echo "✔ Connectivity OK"

# -----------------------------
# Create app users on both nodes (if not exists)
# -----------------------------
echo "Ensuring app user '$APP_USER1' exists on Node1..."
run_psql "$ADMIN_PASS1" "$NODE1_HOST" "$ADMIN_USER1" postgres <<EOF
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '$APP_USER1') THEN
      CREATE ROLE $APP_USER1 LOGIN PASSWORD '$APP_PASS1';
   END IF;
END\$\$;
EOF

echo "Ensuring app user '$APP_USER2' exists on Node2..."
run_psql "$ADMIN_PASS2" "$NODE2_HOST" "$ADMIN_USER2" postgres <<EOF
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '$APP_USER2') THEN
      CREATE ROLE $APP_USER2 LOGIN PASSWORD '$APP_PASS2';
   END IF;
END\$\$;
EOF

# -----------------------------
# DROP + RECREATE DATABASE WITH CORRECT OWNER
# -----------------------------
echo "Dropping and recreating database '$DB_NAME' on Node1..."
run_psql "$ADMIN_PASS1" "$NODE1_HOST" "$ADMIN_USER1" postgres <<EOF
DROP DATABASE IF EXISTS $DB_NAME;
CREATE DATABASE $DB_NAME OWNER $APP_USER1;
EOF

echo "Dropping and recreating database '$DB_NAME' on Node2..."
run_psql "$ADMIN_PASS2" "$NODE2_HOST" "$ADMIN_USER2" postgres <<EOF
DROP DATABASE IF EXISTS $DB_NAME;
CREATE DATABASE $DB_NAME OWNER $APP_USER2;
EOF

# -----------------------------
# Grant privileges + roles
# -----------------------------
echo "Granting privileges on Node1..."
run_psql "$ADMIN_PASS1" "$NODE1_HOST" "$ADMIN_USER1" postgres <<EOF
GRANT CONNECT ON DATABASE $DB_NAME TO $APP_USER1;
GRANT rds_superuser TO $APP_USER1;
GRANT rds_replication TO $APP_USER1;
EOF

echo "Granting privileges on Node2..."
run_psql "$ADMIN_PASS2" "$NODE2_HOST" "$ADMIN_USER2" postgres <<EOF
GRANT CONNECT ON DATABASE $DB_NAME TO $APP_USER2;
GRANT rds_superuser TO $APP_USER2;
GRANT rds_replication TO $APP_USER2;
EOF

# -----------------------------
# Enable pgcrypto + pgactive on both nodes
# -----------------------------
echo "Enabling pgcrypto and pgactive on Node1..."
run_psql "$ADMIN_PASS1" "$NODE1_HOST" "$ADMIN_USER1" "$DB_NAME" <<EOF
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pgactive;
EOF

echo "Enabling pgcrypto and pgactive on Node2..."
run_psql "$ADMIN_PASS2" "$NODE2_HOST" "$ADMIN_USER2" "$DB_NAME" <<EOF
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pgactive;
EOF

# -----------------------------
# Create pgactive group on Node1
# -----------------------------
echo "Creating pgactive group on Node1..."
run_psql "$ADMIN_PASS1" "$NODE1_HOST" "$ADMIN_USER1" "$DB_NAME" <<EOF
SELECT pgactive.pgactive_create_group(
    node_name := '${DB_NAME}-endpoint1-app',
    node_dsn  := 'host=${NODE1_HOST} port=${PORT} dbname=${DB_NAME} user=${APP_USER1} password=${APP_PASS1}'
);
EOF

# -----------------------------
# Join Node2 to the group
# -----------------------------
echo "Joining Node2 to pgactive group..."
run_psql "$ADMIN_PASS2" "$NODE2_HOST" "$ADMIN_USER2" "$DB_NAME" <<EOF
SELECT pgactive.pgactive_join_group(
    node_name      := '${DB_NAME}-endpoint2-app',
    node_dsn       := 'host=${NODE2_HOST} port=${PORT} dbname=${DB_NAME} user=${APP_USER2} password=${APP_PASS2}',
    join_using_dsn := 'host=${NODE1_HOST} port=${PORT} dbname=${DB_NAME} user=${APP_USER1} password=${APP_PASS1}'
);
EOF

# -----------------------------
# Validate replication
# -----------------------------
echo "Validating pgactive cluster status on Node1..."
run_psql "$ADMIN_PASS1" "$NODE1_HOST" "$ADMIN_USER1" "$DB_NAME" -c "SELECT * FROM pgactive.pgactive_node;"

echo "=== FULL pgactive + DB setup complete (Version A) ==="


