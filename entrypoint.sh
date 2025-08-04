#!/bin/sh
set -e

echo "--- Waiting for database to be ready ---"
# A simple wait loop could be added here if needed, but ECS depends_on is more robust.

echo "--- Running database migrations ---"
alembic upgrade head

echo "--- Starting application ---"
exec "$@"
