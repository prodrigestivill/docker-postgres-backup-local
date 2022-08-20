#!/bin/sh

set -e

# Possible actions: error, pre-backup, post-backup
ACTION="${1}"

if [ "${WEBHOOK_URL}" != "**None**" ]; then
  case "${ACTION}" in
    "error")
      echo "Execute error webhook call to ${WEBHOOK_URL}"
      curl --request POST \
        --url "${WEBHOOK_URL}" \
        --header 'Content-Type: application/json' \
        --data '{"status": "error"}' \
        --max-time 10 \
        --retry 5 \
        ${WEBHOOK_EXTRA_ARGS}
      ;;
#   "pre-backup")
#     echo "Nothing to do"
#     ;;
    "post-backup")
      echo "Execute post-backup webhook call to ${WEBHOOK_URL}"
      curl --request POST \
        --url "${WEBHOOK_URL}" \
        --header 'Content-Type: application/json' \
        --data '{"status": "post-backup"}' \
        --max-time 10 \
        --retry 5 \
        ${WEBHOOK_EXTRA_ARGS}
      ;;
  esac
fi
