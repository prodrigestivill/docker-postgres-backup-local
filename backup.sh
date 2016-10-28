#! /bin/sh

set -e
set -o pipefail

if [ "${POSTGRES_DB}" = "**None**" ]; then
  echo "You need to set the POSTGRES_DB environment variable."
  exit 1
fi

if [ "${POSTGRES_HOST}" = "**None**" ]; then
  if [ -n "${POSTGRES_PORT_5432_TCP_ADDR}" ]; then
    POSTGRES_HOST=$POSTGRES_PORT_5432_TCP_ADDR
    POSTGRES_PORT=$POSTGRES_PORT_5432_TCP_PORT
  else
    echo "You need to set the POSTGRES_HOST environment variable."
    exit 1
  fi
fi

if [ "${POSTGRES_USER}" = "**None**" ]; then
  echo "You need to set the POSTGRES_USER environment variable."
  exit 1
fi

if [ "${POSTGRES_PASSWORD}" = "**None**" ]; then
  echo "You need to set the POSTGRES_PASSWORD environment variable or link to a container named POSTGRES."
  exit 1
fi

#Proces vars
export PGPASSWORD=$POSTGRES_PASSWORD
POSTGRES_HOST_OPTS="-h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER $POSTGRES_EXTRA_OPTS"
KEEP_DAYS=$BACKUP_KEEP_DAYS
KEEP_WEEKS=`expr $((($BACKUP_KEEP_WEEKS * 7) + 1))`
KEEP_MONTHS=`expr $((($BACKUP_KEEP_MONTHS * 31) + 1))`

#Initialize filename vers and dirs
DFILE="$BACKUP_DIR/daily/$POSTGRES_DB-`date +%Y%m%d-%H%M%S`.sql.gz"
WFILE="$BACKUP_DIR/weekly/$POSTGRES_DB-`date +%G%V`.sql.gz"
MFILE="$BACKUP_DIR/monthly/$POSTGRES_DB-`date +%Y%m`.sql.gz"
mkdir -p "$BACKUP_DIR/daily/" "$BACKUP_DIR/weekly/" "$BACKUP_DIR/monthly/"

#Create dump
echo "Creating dump of ${POSTGRES_DB} database from ${POSTGRES_HOST}..."
pg_dump -f "$DFILE" $POSTGRES_HOST_OPTS $POSTGRES_DB

#Copy (hardlink) for each entry
ln -vf "$DFILE" "$WFILE"
ln -vf "$DFILE" "$MFILE"

#Clean old files
find "$BACKUP_DIR/daily" -maxdepth 1 -mtime +$KEEP_DAYS -name "$POSTGRES_DB-*.sql*" -exec rm -rf '{}' ';'
find "$BACKUP_DIR/weekly" -maxdepth 1 -mtime +$KEEP_WEEKS -name "$POSTGRES_DB-*.sql*" -exec rm -rf '{}' ';'
find "$BACKUP_DIR/monthly" -maxdepth 1 -mtime +$KEEP_MONTHS -name "$POSTGRES_DB-*.sql*" -exec rm -rf '{}' ';'

echo "SQL backup uploaded successfully"
