#!/bin/sh
#
# Usage: ./publish.sh [Version1] [Version2]...

set -e

cd "$(dirname "$0")"
TMPFILE=$(mktemp)
trap 'rm -vf "$TMPFILE"' EXIT

if [ -n "$@" ]; then
  export TAGS="$@"
  echo "Generate configuration for only this tags: $TAGS"
else
  echo "Generate configuration for all predefined tags."
fi
./generate.sh "$TMPFILE"
echo "Generated docker bake HCL script at: $TMPFILE"

echo "Starting building and publish..."
docker buildx bake --pull --set common.output=type=registry -f "$TMPFILE"
