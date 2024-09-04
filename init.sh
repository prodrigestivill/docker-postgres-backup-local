#!/usr/bin/env bash
set -Eeo pipefail

# Prevalidate configuration (don't source)
/env.sh

exec /usr/local/bin/go-cron -s "$SCHEDULE" -p "$HEALTHCHECK_PORT" -- /backup.sh
