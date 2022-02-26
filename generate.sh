#!/bin/sh

set -e

DOCKER_BAKE_FILE=${1:-"docker-bake.hcl"}
TAGS=${TAGS:-"14 13 12 11 10"}
GOCRONVER=${GOCRONVER:-"v0.0.10"}
PLATFORMS=${PLATFORMS:-"linux/amd64 linux/arm64 linux/arm/v7 linux/s390x linux/ppc64le"}
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

variable "BUILDREV" {
	default = ""
}

target "common" {
	platforms = [$P]
	args = {"GOCRONVER" = "$GOCRONVER"}
}

target "debian" {
	inherits = ["common"]
	dockerfile = "debian.Dockerfile"
}

target "alpine" {
	inherits = ["common"]
	dockerfile = "alpine.Dockerfile"
}

target "debian-latest" {
	inherits = ["debian"]
	args = {"BASETAG" = "$MAIN_TAG"}
	tags = [
		"$IMAGE_NAME:latest",
		"$IMAGE_NAME:$MAIN_TAG",
		notequal("", BUILDREV) ? "$IMAGE_NAME:$MAIN_TAG-debian-\${BUILDREV}" : ""
	]
}

target "alpine-latest" {
	inherits = ["alpine"]
	args = {"BASETAG" = "$MAIN_TAG-alpine"}
	tags = [
		"$IMAGE_NAME:alpine",
		"$IMAGE_NAME:$MAIN_TAG-alpine",
		notequal("", BUILDREV) ? "$IMAGE_NAME:$MAIN_TAG-alpine-\${BUILDREV}" : ""
	]
}
EOF

for TAG in $TAGS_EXTRA; do cat >> "$DOCKER_BAKE_FILE" << EOF

target "debian-$TAG" {
	inherits = ["debian"]
	args = {"BASETAG" = "$TAG"}
	tags = [
		"$IMAGE_NAME:$TAG",
		notequal("", BUILDREV) ? "$IMAGE_NAME:$TAG-debian-\${BUILDREV}" : ""
	]
}

target "alpine-$TAG" {
	inherits = ["alpine"]
	args = {"BASETAG" = "$TAG-alpine"}
	tags = [
		"$IMAGE_NAME:$TAG-alpine",
		notequal("", BUILDREV) ? "$IMAGE_NAME:$TAG-alpine-\${BUILDREV}" : ""
	]
}
EOF
done
