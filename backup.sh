#!/usr/bin/env bash

# Import variables from environment
export PGHOST="${POSTGRES_HOST}"
export PGPORT="${POSTGRES_PORT}"
KEEP_MINS=${BACKUP_KEEP_MINS}
KEEP_DAYS=${BACKUP_KEEP_DAYS}
KEEP_WEEKS=`expr $((${BACKUP_KEEP_WEEKS} * 7))`
KEEP_MONTHS=`expr $((${BACKUP_KEEP_MONTHS} * 31))`
  
setup () {

  set -Eeo pipefail

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

  FREQUENCY=( daily weekly monthly )

  for f in ${FREQUENCY[@]}
  do
  
    mkdir -p "${BACKUP_DIR}/${f}/"

  done

  MONTH_DAY=`date +%d`
  WEEK_DAY=`date +%A`

}

#Create Backups
create_backups () {

  for DB in ${POSTGRES_DBS}
  do

    FILE="${BACKUP_DIR}/daily/${DB}-`date +%Y%m%d`${BACKUP_SUFFIX}"

    create_dump

    if [ "${BACKUP_MONTH_DAY}" = "${MONTH_DAY}" ]
    then

      create_hardlinks "${FILE}" "monthly"

    elif [ "${BACKUP_WEEK_DAY}" = "${WEEK_DAY}" ]
    then

      create_hardlinks "${FILE}" "weekly"

    fi

    echo "SQL backup created successfully"

  done

}

# Create dump of postgres database
create_dump () {

  if [ "${POSTGRES_CLUSTER}" = "TRUE" ]; then
    echo "Creating cluster dump of ${DB} database from ${POSTGRES_HOST}..."
    pg_dumpall -l "${DB}" ${POSTGRES_EXTRA_OPTS} | gzip > "${FILE}"
  else
    echo "Creating dump of ${DB} database from ${POSTGRES_HOST}..."
    pg_dump -d "${DB}" -f "${FILE}" ${POSTGRES_EXTRA_OPTS}
  fi

}

# Create hardlinks from daily backup to monthly and weekly backups
create_hardlinks () {
  
  SRC=$1
  INCREMENT=$2

  if [ "${INCREMENT}" = "weekly" ]
  then

    echo "Creating Weekly Backup of ${DB} database from ${POSTGRES_HOST}..."
    FILENAME="${DB}-`date +%G%V`${BACKUP_SUFFIX}"

  elif [ "${INCREMENT}" = "monthly"]
  then

    echo "Creating Monthly Backup of ${DB} database from ${POSTGRES_HOST}..."
    FILENAME="${DB}-`date +%Y%m`${BACKUP_SUFFIX}"

  fi

  DEST="${BACKUP_DIR}/${INCREMENT}/${FILENAME}"

  #Copy (hardlink) for each entry
  if [ -d "${SRC}" ]
  then
    ln -f "${SRC}/"* "${DEST}/"
  else
    ln -vf "${SRC}" "${DEST}"
  fi
  # Update latest symlinks
  ln -svf "${DEST}" "${BACKUP_DIR}/${INCREMENT}/${DB}-latest"

}

#Clean up old backups
cleanup_backups () {
  
  for folder in "${FREQUENCY[@]}"
  do
    if [ $folder == "weekly" ]
    then
      KEEP=$BACKUP_KEEP_WEEKS
      DELETE=$BACKUP_DELETE_WEEKS
    elif [ $folder == 'monthly' ]
    then
      KEEP=$BACKUP_KEEP_MONTHS
      DELETE=$BACKUP_DELETE_MONTHS
    elif [ $folder == 'daily' ]
    then
      KEEP=$BACKUP_KEEP_DAYS
      DELETE=$BACKUP_DELETE_DAYS
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

        if [ $((${#all[@]}-${#files[@]})) -lt ${KEEP} ]
        then

          local number=$((${#all[@]}-${#files[@]}))

          local files=("${files[@]:0:$number}")

        fi

      fi

  	  if [ $((${#all[@]})) -lt ${KEEP} ]
      then
        
        echo "Only ${#all[@]} Backups exist for ${DB} and you want to keep $KEEP."
        echo "If you have just started taking backups you may ignore this"
        echo "Otherwise you may want to investigate why backups are not being taken"

      elif $DELETE
      then
        for file in "${files[@]}"
        do

          echo "Deleting $file"
  		    rm $file

        done
      else
        for file in "${files[@]}"
        do

          echo "Dry Run: Delete $file"

        done
      fi

    done

  done
}

listCommands () {

  echo "--create-backup -b  Create Daily, Weekly and Monthly backups"
  echo "--cleanup -c        Cleanup old backups"
  echo "--help -h           List commands"

}

case $1 in

  "--create-backup" | "-b")

    setup
    create_backups
    ;;

  "--cleanup" | "-c")

    setup
    cleanup_backups
    ;;

  "--help" | "-h")

    listCommands
    ;;

  *)

    setup
    create_backups
    cleanup_backups

esac
