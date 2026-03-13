#!/bin/bash
set -e

echo "=== pgactive automated setup starting ==="

# -----------------------------
# Required Environment Variables
# -----------------------------
: "${NODE1_HOST:?Need NODE1_HOST}"
: "${NODE2_HOST:?Need NODE2_HOST}"
: "${DB_NAME:?Need DB_NAME}"
: "${APP_USER1:?Need APP_USER1}"
: "${APP_PASS1:?Need APP_PASS1}"
: "${APP_USER2:?Need APP_USER2}"
: "${APP_PASS2:?Need APP_PASS2}"
: "${ADMIN_USER:?Need ADMIN_USER}"
: "${ADMIN_PASS:?Need ADMIN_PASS}"

PORT=5430

# -----------------------------
# Install PostgreSQL client
# -----------------------------
echo "Installing PostgreSQL client..."
sudo yum install -y postgresql15 || sudo apt-get install -y postgresql-client

# -----------------------------
# Test connectivity Node1 <-> Node2
# -----------------------------
echo "Testing connectivity to Node1..."
PGPASSWORD="$ADMIN_PASS" psql -h "$NODE1_HOST" -p $PORT -U "$ADMIN_USER" -d "$DB_NAME" -c "SELECT version();" || {
  echo "❌ Cannot connect to Node1"
  exit 1
}

echo "Testing connectivity to Node2..."
PGPASSWORD="$ADMIN_PASS" psql -h "$NODE2_HOST" -p $PORT -U "$ADMIN_USER" -d "$DB_NAME" -c "SELECT version();" || {
  echo "❌ Cannot connect to Node2"
  exit 1
}

echo "✔ Connectivity OK"

# -----------------------------
# Create pgactive extension
# -----------------------------
echo "Creating pgactive extension on both nodes..."

PGPASSWORD="$ADMIN_PASS" psql -h "$NODE1_HOST" -p $PORT -U "$ADMIN_USER" -d "$DB_NAME" -c "CREATE EXTENSION IF NOT EXISTS pgactive;"
PGPASSWORD="$ADMIN_PASS" psql -h "$NODE2_HOST" -p $PORT -U "$ADMIN_USER" -d "$DB_NAME" -c "CREATE EXTENSION IF NOT EXISTS pgactive;"

# -----------------------------
# Create group on Node1
# -----------------------------
echo "Creating pgactive group on Node1..."

PGPASSWORD="$ADMIN_PASS" psql -h "$NODE1_HOST" -p $PORT -U "$ADMIN_USER" -d "$DB_NAME" <<EOF
SELECT pgactive.pgactive_create_group(
    node_name := '${DB_NAME}-endpoint1-app',
    node_dsn  := 'host=${NODE1_HOST} port=${PORT} dbname=${DB_NAME} user=${APP_USER1} password=${APP_PASS1}'
);
EOF

# -----------------------------
# Join Node2 to the group
# -----------------------------
echo "Joining Node2 to pgactive group..."

PGPASSWORD="$ADMIN_PASS" psql -h "$NODE2_HOST" -p $PORT -U "$ADMIN_USER" -d "$DB_NAME" <<EOF
SELECT pgactive.pgactive_join_group(
    node_name      := '${DB_NAME}-endpoint2-app',
    node_dsn       := 'host=${NODE2_HOST} port=${PORT} dbname=${DB_NAME} user=${APP_USER2} password=${APP_PASS2}',
    join_using_dsn := 'host=${NODE1_HOST} port=${PORT} dbname=${DB_NAME} user=${APP_USER1} password=${APP_PASS1}'
);
EOF

# -----------------------------
# Validate replication
# -----------------------------
echo "Validating pgactive cluster status..."

PGPASSWORD="$ADMIN_PASS" psql -h "$NODE1_HOST" -p $PORT -U "$ADMIN_USER" -d "$DB_NAME" -c "SELECT * FROM pgactive.pgactive_node;"

echo "=== pgactive setup complete ==="






Before running the script, export these:
export NODE1_HOST="docmp-accumulator-qa-db-1.chvljaqaz19a.us-gov-west-1.rds.amazonaws.com"
export NODE2_HOST="docmp-accumulator-qa-db-2.chvljaqaz19a.us-gov-west-1.rds.amazonaws.com"

export DB_NAME="docmp_qa_db1"

export ADMIN_USER="masteruser"
export ADMIN_PASS="masterpassword"

export APP_USER1="docmpqauser1"
export APP_PASS1="docmpadmin"

export APP_USER2="docmpqauser2"
export APP_PASS2="docmpadmin"
