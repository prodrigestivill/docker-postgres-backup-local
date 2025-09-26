group "default" {
	targets = ["debian-latest", "alpine-latest", "debian-17", "debian-16", "debian-15", "debian-14", "debian-13", "alpine-17", "alpine-16", "alpine-15", "alpine-14", "alpine-13"]
}

variable "REGISTRY_PREFIX" {
	default = ""
}

variable "IMAGE_NAME" {
	default = "postgres-backup-local"
}

variable "BUILD_REVISION" {
	default = ""
}

target "debian" {
	args = {"GOCRONVER" = "v0.0.11"}
	dockerfile = "debian.Dockerfile"
}

target "alpine" {
	args = {"GOCRONVER" = "v0.0.11"}
	dockerfile = "alpine.Dockerfile"
}

target "debian-latest" {
	inherits = ["debian"]
	platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7", "linux/s390x", "linux/ppc64le"]
	args = {"BASETAG" = "18"}
	tags = [
		"${REGISTRY_PREFIX}${IMAGE_NAME}:latest",
		"${REGISTRY_PREFIX}${IMAGE_NAME}:18",
		notequal("", BUILD_REVISION) ? "${REGISTRY_PREFIX}${IMAGE_NAME}:18-debian-${BUILD_REVISION}" : ""
	]
}

target "alpine-latest" {
	inherits = ["alpine"]
	platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7", "linux/s390x", "linux/ppc64le"]
	args = {"BASETAG" = "18-alpine"}
	tags = [
		"${REGISTRY_PREFIX}${IMAGE_NAME}:alpine",
		"${REGISTRY_PREFIX}${IMAGE_NAME}:18-alpine",
		notequal("", BUILD_REVISION) ? "${REGISTRY_PREFIX}${IMAGE_NAME}:18-alpine-${BUILD_REVISION}" : ""
	]
}

target "debian-17" {
	inherits = ["debian"]
	platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7", "linux/s390x", "linux/ppc64le"]
	args = {"BASETAG" = "17"}
	tags = [
		"${REGISTRY_PREFIX}${IMAGE_NAME}:17",
		notequal("", BUILD_REVISION) ? "${REGISTRY_PREFIX}${IMAGE_NAME}:17-debian-${BUILD_REVISION}" : ""
	]
}

target "alpine-17" {
	inherits = ["alpine"]
	platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7", "linux/s390x", "linux/ppc64le"]
	args = {"BASETAG" = "17-alpine"}
	tags = [
		"${REGISTRY_PREFIX}${IMAGE_NAME}:17-alpine",
		notequal("", BUILD_REVISION) ? "${REGISTRY_PREFIX}${IMAGE_NAME}:17-alpine-${BUILD_REVISION}" : ""
	]
}

target "debian-16" {
	inherits = ["debian"]
	platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7", "linux/s390x", "linux/ppc64le"]
	args = {"BASETAG" = "16"}
	tags = [
		"${REGISTRY_PREFIX}${IMAGE_NAME}:16",
		notequal("", BUILD_REVISION) ? "${REGISTRY_PREFIX}${IMAGE_NAME}:16-debian-${BUILD_REVISION}" : ""
	]
}

target "alpine-16" {
	inherits = ["alpine"]
	platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7", "linux/s390x", "linux/ppc64le"]
	args = {"BASETAG" = "16-alpine"}
	tags = [
		"${REGISTRY_PREFIX}${IMAGE_NAME}:16-alpine",
		notequal("", BUILD_REVISION) ? "${REGISTRY_PREFIX}${IMAGE_NAME}:16-alpine-${BUILD_REVISION}" : ""
	]
}

target "debian-15" {
	inherits = ["debian"]
	platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7", "linux/s390x", "linux/ppc64le"]
	args = {"BASETAG" = "15"}
	tags = [
		"${REGISTRY_PREFIX}${IMAGE_NAME}:15",
		notequal("", BUILD_REVISION) ? "${REGISTRY_PREFIX}${IMAGE_NAME}:15-debian-${BUILD_REVISION}" : ""
	]
}

target "alpine-15" {
	inherits = ["alpine"]
	platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7", "linux/s390x", "linux/ppc64le"]
	args = {"BASETAG" = "15-alpine"}
	tags = [
		"${REGISTRY_PREFIX}${IMAGE_NAME}:15-alpine",
		notequal("", BUILD_REVISION) ? "${REGISTRY_PREFIX}${IMAGE_NAME}:15-alpine-${BUILD_REVISION}" : ""
	]
}

target "debian-14" {
	inherits = ["debian"]
	platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7", "linux/s390x", "linux/ppc64le"]
	args = {"BASETAG" = "14"}
	tags = [
		"${REGISTRY_PREFIX}${IMAGE_NAME}:14",
		notequal("", BUILD_REVISION) ? "${REGISTRY_PREFIX}${IMAGE_NAME}:14-debian-${BUILD_REVISION}" : ""
	]
}

target "alpine-14" {
	inherits = ["alpine"]
	platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7", "linux/s390x", "linux/ppc64le"]
	args = {"BASETAG" = "14-alpine"}
	tags = [
		"${REGISTRY_PREFIX}${IMAGE_NAME}:14-alpine",
		notequal("", BUILD_REVISION) ? "${REGISTRY_PREFIX}${IMAGE_NAME}:14-alpine-${BUILD_REVISION}" : ""
	]
}

target "debian-13" {
	inherits = ["debian"]
	platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7", "linux/s390x", "linux/ppc64le"]
	args = {"BASETAG" = "13"}
	tags = [
		"${REGISTRY_PREFIX}${IMAGE_NAME}:13",
		notequal("", BUILD_REVISION) ? "${REGISTRY_PREFIX}${IMAGE_NAME}:13-debian-${BUILD_REVISION}" : ""
	]
}

target "alpine-13" {
	inherits = ["alpine"]
	platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7", "linux/s390x", "linux/ppc64le"]
	args = {"BASETAG" = "13-alpine"}
	tags = [
		"${REGISTRY_PREFIX}${IMAGE_NAME}:13-alpine",
		notequal("", BUILD_REVISION) ? "${REGISTRY_PREFIX}${IMAGE_NAME}:13-alpine-${BUILD_REVISION}" : ""
	]
}
