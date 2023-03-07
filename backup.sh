#!/usr/bin/env bash

export PGHOST="${POSTGRES_HOST}"
export PGPORT="${POSTGRES_PORT}"
KEEP_MINS=${BACKUP_KEEP_MINS}
KEEP_DAYS=${BACKUP_KEEP_DAYS}
KEEP_WEEKS=`expr $(((${BACKUP_KEEP_WEEKS} * 7) + 1))`
KEEP_MONTHS=`expr $(((${BACKUP_KEEP_MONTHS} * 31) + 1))`

set -Eeo pipefail

HOOKS_DIR="/hooks"
if [ -d "${HOOKS_DIR}" ]; then
  on_error(){
    run-parts -a "error" "${HOOKS_DIR}"
  }
  trap 'on_error' ERR
fi

if [ "${POSTGRES_DB}" = "**None**" -a "${POSTGRES_DB_FILE}" = "**None**" ]; then
  echo "You need to set the POSTGRES_DB or POSTGRES_DB_FILE environment variable."
  exit 1
fi

if [ "${POSTGRES_HOST}" = "**None**" ]; then
  if [ -n "${POSTGRES_PORT_5432_TCP_ADDR}" ]; then
    POSTGRES_HOST=${POSTGRES_PORT_5432_TCP_ADDR}
    POSTGRES_PORT=${POSTGRES_PORT_5432_TCP_PORT}
  else
    echo "You need to set the POSTGRES_HOST environment variable."
    exit 1
  fi
fi

if [ "${POSTGRES_USER}" = "**None**" -a "${POSTGRES_USER_FILE}" = "**None**" ]; then
  echo "You need to set the POSTGRES_USER or POSTGRES_USER_FILE environment variable."
  exit 1
fi

if [ "${POSTGRES_PASSWORD}" = "**None**" -a "${POSTGRES_PASSWORD_FILE}" = "**None**" -a "${POSTGRES_PASSFILE_STORE}" = "**None**" ]; then
  echo "You need to set the POSTGRES_PASSWORD or POSTGRES_PASSWORD_FILE or POSTGRES_PASSFILE_STORE environment variable or link to a container named POSTGRES."
  exit 1
fi

#Process vars
if [ "${POSTGRES_DB_FILE}" = "**None**" ]; then
  POSTGRES_DBS=$(echo "${POSTGRES_DB}" | tr , " ")
elif [ -r "${POSTGRES_DB_FILE}" ]; then
  POSTGRES_DBS=$(cat "${POSTGRES_DB_FILE}")
else
  echo "Missing POSTGRES_DB_FILE file."
  exit 1
fi
if [ "${POSTGRES_USER_FILE}" = "**None**" ]; then
  export PGUSER="${POSTGRES_USER}"
elif [ -r "${POSTGRES_USER_FILE}" ]; then
  export PGUSER=$(cat "${POSTGRES_USER_FILE}")
else
  echo "Missing POSTGRES_USER_FILE file."
  exit 1
fi
if [ "${POSTGRES_PASSWORD_FILE}" = "**None**" -a "${POSTGRES_PASSFILE_STORE}" = "**None**" ]; then
  export PGPASSWORD="${POSTGRES_PASSWORD}"
elif [ -r "${POSTGRES_PASSWORD_FILE}" ]; then
  export PGPASSWORD=$(cat "${POSTGRES_PASSWORD_FILE}")
elif [ -r "${POSTGRES_PASSFILE_STORE}" ]; then
  export PGPASSFILE="${POSTGRES_PASSFILE_STORE}"
else
  echo "Missing POSTGRES_PASSWORD_FILE or POSTGRES_PASSFILE_STORE file."
  exit 1
fi

# Pre-backup hook
if [ -d "${HOOKS_DIR}" ]; then
  run-parts -a "pre-backup" --exit-on-error "${HOOKS_DIR}"
fi

#Initialize dirs
FREQUENCY=( last daily weekly monthly )

for f in ${FREQUENCY[@]}
do

  mkdir -p "${BACKUP_DIR}/${f}/"

done

#Create Backups
links=( "daily" "monthly" "weekly" )
for DB in ${POSTGRES_DBS}
do

  LAST_FILENAME="${DB}-`date +%Y%m%d-%H%M%S`${BACKUP_SUFFIX}"
  FILE="${BACKUP_DIR}/last/${LAST_FILENAME}"

  #Create dump
  if [ "${POSTGRES_CLUSTER}" = "TRUE" ]; then
    echo "Creating cluster dump of ${DB} database from ${POSTGRES_HOST}..."
    pg_dumpall -l "${DB}" ${POSTGRES_EXTRA_OPTS} | gzip > "${FILE}"
  else
    echo "Creating dump of ${DB} database from ${POSTGRES_HOST}..."
    pg_dump -d "${DB}" -f "${FILE}" ${POSTGRES_EXTRA_OPTS}
  fi

  echo "Point last backup file to this last backup..."
  ln -svf "${LAST_FILENAME}" "${BACKUP_DIR}/last/${DB}-latest${BACKUP_SUFFIX}"

  for link in ${links}
  do
  
    if [ "${link}" == "daily" ]
    then

      FILENAME="${DB}-`date +%Y%m%d`${BACKUP_SUFFIX}"

    elif [ "${link}" == "weekly" ]
    then

      FILENAME="${DB}-`date +%G%V`${BACKUP_SUFFIX}"

    elif [ "${link}" == "monthly"]
    then

      FILENAME="${DB}-`date +%Y%m`${BACKUP_SUFFIX}"

    fi

    DEST="${BACKUP_DIR}/${link}/${FILENAME}"

    #Copy (hardlink) for each entry
    if [ -d "${FILE}" ]
    then
      DESTNEW="${DEST}-new"
      rm -rf "${DESTNEW}"
      mkdir "${DESTNEW}"
      ln -f "${FILE}/"* "${DESTNEW}/"
      rm -rf "${DEST}"
      echo "Replacing ${link} backup ${DEST} file this last backup..."
      mv "${DESTNEW}" "${DEST}"
    else
      echo "Replacing ${link} backup ${DEST} file this last backup..."
      ln -vf "${FILE}" "${DEST}"
    fi
    # Update latest symlinks
    echo "Replacing lastest ${link} backup to this last backup..."
    ln -svf "${DEST}" "${BACKUP_DIR}/${link}/${DB}-latest"

  done

  echo "SQL backup created successfully"

done

# Post-backup hook
if [ -d "${HOOKS_DIR}" ]; then
  run-parts -a "post-backup" --reverse --exit-on-error "${HOOKS_DIR}"
fi

#Clean up old backups
for folder in "${FREQUENCY[@]}"
do
  if [ $folder == 'last' ]
  then
    KEEP=$KEEP_MINS
  elif [ $folder == 'daily' ]
  then
    KEEP=$KEEP_DAYS
  elif [ $folder == "weekly" ]
  then
    KEEP=$KEEP_WEEKS
  elif [ $folder == 'monthly' ]
  then
    KEEP=$KEEP_MONTHS
  fi

  for DB in ${POSTGRES_DBS}
  do

    #Clean old files
    local all=( `find "${BACKUP_DIR}/${folder}" -maxdepth 1 -name "${DB}-*"` )
    local files=()

    if [ $KEEP -gt 0 ]
    then
    
      echo "Cleaning older files in ${folder} for ${DB} database from ${POSTGRES_HOST}..."
      local files=( `find "${BACKUP_DIR}/${folder}" -maxdepth 1 -mtime "+$((${KEEP}-1))" -name "${DB}-*"` )
      local files=( `printf "%s\n" "${files[@]}" | sort -t/ -k3` )

    fi

	  for file in "${files[@]}"
    do

      echo "Deleting $file"
		  rm -r $file

    done

  done

done
