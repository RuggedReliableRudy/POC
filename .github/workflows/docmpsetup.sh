#!/bin/bash
set -e

echo "=== Starting automated pgactive setup ==="

# -----------------------------
# Required Environment Variables
# -----------------------------
: "${NODE1_HOST:?Missing NODE1_HOST}"
: "${NODE2_HOST:?Missing NODE2_HOST}"
: "${DB_NAME:?Missing DB_NAME}"

: "${ADMIN_USER1:?Missing ADMIN_USER1}"
: "${ADMIN_PASS1:?Missing ADMIN_PASS1}"

: "${ADMIN_USER2:?Missing ADMIN_USER2}"
: "${ADMIN_PASS2:?Missing ADMIN_PASS2}"

: "${APP_USER1:?Missing APP_USER1}"
: "${APP_PASS1:?Missing APP_PASS1}"

: "${APP_USER2:?Missing APP_USER2}"
: "${APP_PASS2:?Missing APP_PASS2}"

PORT=5430

# -----------------------------
# Install PostgreSQL 17 client
# -----------------------------
echo "Installing PostgreSQL 17 client..."
if command -v yum >/dev/null 2>&1; then
  sudo yum install -y postgresql17
elif command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y postgresql-client-17
fi

# -----------------------------
# Connectivity Tests
# -----------------------------
echo "Testing connectivity to Node1..."
PGPASSWORD="$ADMIN_PASS1" psql -h "$NODE1_HOST" -p $PORT -U "$ADMIN_USER1" -d "$DB_NAME" -c "SELECT version();" || {
  echo "❌ Cannot connect to Node1"
  exit 1
}

echo "Testing connectivity to Node2..."
PGPASSWORD="$ADMIN_PASS2" psql -h "$NODE2_HOST" -p $PORT -U "$ADMIN_USER2" -d "$DB_NAME" -c "SELECT version();" || {
  echo "❌ Cannot connect to Node2"
  exit 1
}

echo "✔ Connectivity OK"

# -----------------------------
# Create pgactive extension
# -----------------------------
echo "Ensuring pgactive extension exists..."

PGPASSWORD="$ADMIN_PASS1" psql -h "$NODE1_HOST" -p $PORT -U "$ADMIN_USER1" -d "$DB_NAME" -c "CREATE EXTENSION IF NOT EXISTS pgactive;"
PGPASSWORD="$ADMIN_PASS2" psql -h "$NODE2_HOST" -p $PORT -U "$ADMIN_USER2" -d "$DB_NAME" -c "CREATE EXTENSION IF NOT EXISTS pgactive;"

# -----------------------------
# Create group on Node1
# -----------------------------
echo "Creating pgactive group on Node1..."

PGPASSWORD="$ADMIN_PASS1" psql -h "$NODE1_HOST" -p $PORT -U "$ADMIN_USER1" -d "$DB_NAME" <<EOF
SELECT pgactive.pgactive_create_group(
    node_name := '${DB_NAME}-endpoint1-app',
    node_dsn  := 'host=${NODE1_HOST} port=${PORT} dbname=${DB_NAME} user=${APP_USER1} password=${APP_PASS1}'
);
EOF

# -----------------------------
# Join Node2 to the group
# -----------------------------
echo "Joining Node2 to pgactive group..."

PGPASSWORD="$ADMIN_PASS2" psql -h "$NODE2_HOST" -p $PORT -U "$ADMIN_USER2" -d "$DB_NAME" <<EOF
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

PGPASSWORD="$ADMIN_PASS1" psql -h "$NODE1_HOST" -p $PORT -U "$ADMIN_USER1" -d "$DB_NAME" -c "SELECT * FROM pgactive.pgactive_node;"

echo "=== pgactive setup complete ==="
