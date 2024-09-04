#!/usr/bin/env bash
set -Eeo pipefail

# Prevalidate configuration (don't source)
/env.sh

# Initial background backup
if [ "${BACKUP_ON_START}" = "TRUE" ]; then
  echo "Launching an startup backup as a background job..."
  /backup.sh &
fi

echo "Starting go-cron ($SCHEDULE)..."
exec /usr/local/bin/go-cron -s "$SCHEDULE" -p "$HEALTHCHECK_PORT" -- /backup.sh
