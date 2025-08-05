#!/bin/sh
# We are temporarily removing 'set -e' to ensure this script runs to completion for debugging.

echo "--- [DEBUG] Printing all environment variables to check secrets ---"
printenv
echo "--- [DEBUG] Finished printing environment variables ---"

echo "--- [DEBUG] Running database migrations and capturing all output ---"
# Execute the alembic command and redirect its standard error to standard output,
# then store it all in a variable.
migration_output=$(alembic upgrade head 2>&1)
migration_exit_code=$? # Capture the exit code of the alembic command

echo "--- [DEBUG] Alembic command finished with exit code: $migration_exit_code ---"
echo "--- [DEBUG] Alembic command output was: ---"
echo "$migration_output"
echo "------------------------------------------"

# If the migration failed, we print the error and then exit with the same error code.
# This ensures the task is marked as failed, but only after we've logged everything.
if [ $migration_exit_code -ne 0 ]; then
  echo "--- [FATAL] Migration failed. See output above. Exiting. ---"
  exit $migration_exit_code
fi

echo "--- [SUCCESS] Migrations completed. Starting application. ---"
exec "$@"
