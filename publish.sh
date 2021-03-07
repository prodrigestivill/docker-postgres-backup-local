#!/bin/sh
#
# Usage: ./publish.sh [Version1] [Version2]...

set -e

cd "$(dirname "$0")"
TMPFILE=$(mktemp)
trap 'rm -vf "$TMPFILE"' EXIT

if [ -n "$@" ]; then
  TAGS="$@"
  echo "Generate configuration for only this tags: $TAGS"
  export TAGS
else
  echo "Generate configuration for all predefined tags."
fi
./generate.sh "$TMPFILE"
echo "Generated docker bake HCL script at: $TMPFILE"

BUILDREV=$(git rev-parse --short HEAD)
echo "Starting building and publish revision $BUILDREV..."
export BUILDREV
docker buildx bake --pull --push -f "$TMPFILE"

echo "Successfully build and pushed."