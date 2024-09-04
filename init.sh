#!/usr/bin/env bash
set -Eeo pipefail

# Prevalidate configuration (don't source)
/env.sh

EXTRA_ARGS=""
# Initial background backup
if [ "${BACKUP_ON_START}" = "TRUE" ]; then
  EXTRA_ARGS="-i"
fi

echo "Starting go-cron ($SCHEDULE)..."
exec /usr/local/bin/go-cron -s "$SCHEDULE" -p "$HEALTHCHECK_PORT" $EXTRA_ARGS -- /backup.sh
