#!/bin/sh

set -e

DOCKER_BAKE_FILE=${1:-"docker-bake.hcl"}
TAGS=${TAGS:-"12 11 10 9.6 9.5 9.4"}
GOCRONVER=${GOCRONVER:-"v0.0.9"}
PLATFORMS=${PLATFORMS:-"linux/amd64 linux/arm64 linux/arm/v7"}
IMAGE_NAME=${IMAGE_NAME:-"prodrigestivill/postgres-backup-local"}

cd "$(dirname "$0")"

MAIN_TAG=${TAGS%%" "*} # First tag
TAGS_EXTRA=${TAGS#*" "} # Rest of tags
P="\"$(echo $PLATFORMS | sed 's/ /", "/g')\""

T="\"debian-latest\", \"alpine-latest\", \"$(echo debian-$TAGS_EXTRA | sed 's/ /", "debian-/g')\", \"$(echo alpine-$TAGS_EXTRA | sed 's/ /", "alpine-/g')\""

cat > "$DOCKER_BAKE_FILE" << EOF
group "default" {
	targets = [$T]
}

target "common" {
	platforms = [$P]
	args = {"GOCRONVER" = "$GOCRONVER"}
}

target "debian" {
	inherits = ["common"]
	dockerfile = "Dockerfile-debian"
}

target "alpine" {
	inherits = ["common"]
	dockerfile = "Dockerfile-alpine"
}

target "debian-latest" {
	inherits = ["debian"]
	args = {"BASETAG" = "$MAIN_TAG"}
	tags = ["$IMAGE_NAME:latest", "$IMAGE_NAME:$MAIN_TAG"]
}

target "alpine-latest" {
	inherits = ["alpine"]
	args = {"BASETAG" = "$MAIN_TAG-alpine"}
	tags = ["$IMAGE_NAME:alpine", "$IMAGE_NAME:$MAIN_TAG-alpine"]
}
EOF

for TAG in $TAGS_EXTRA; do cat >> "$DOCKER_BAKE_FILE" << EOF

target "debian-$TAG" {
  inherits = ["debian"]
	args = {"BASETAG" = "$TAG"}
  tags = ["$IMAGE_NAME:$TAG"]
}

target "alpine-$TAG" {
  inherits = ["alpine"]
	args = {"BASETAG" = "$TAG-alpine"}
  tags = ["$IMAGE_NAME:$TAG-alpine"]
}
EOF
done
