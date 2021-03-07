group "default" {
	targets = ["debian-latest", "alpine-latest", "debian-12", "debian-11", "debian-10", "debian-9.6", "debian-9.5", "alpine-12", "alpine-11", "alpine-10", "alpine-9.6", "alpine-9.5"]
}

variable "BUILDREV" {
	default = ""
}

target "common" {
	platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7"]
	args = {"GOCRONVER" = "v0.0.9"}
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
	args = {"BASETAG" = "13"}
	tags = [
		"prodrigestivill/postgres-backup-local:latest",
		"prodrigestivill/postgres-backup-local:13",
		notequal("", BUILDREV) ? "prodrigestivill/postgres-backup-local:13-debian-${BUILDREV}" : ""
	]
}

target "alpine-latest" {
	inherits = ["alpine"]
	args = {"BASETAG" = "13-alpine"}
	tags = [
		"prodrigestivill/postgres-backup-local:alpine",
		"prodrigestivill/postgres-backup-local:13-alpine",
		notequal("", BUILDREV) ? "prodrigestivill/postgres-backup-local:13-alpine-${BUILDREV}" : ""
	]
}

target "debian-12" {
	inherits = ["debian"]
	args = {"BASETAG" = "12"}
	tags = [
		"prodrigestivill/postgres-backup-local:12",
		notequal("", BUILDREV) ? "prodrigestivill/postgres-backup-local:12-debian-${BUILDREV}" : ""
	]
}

target "alpine-12" {
	inherits = ["alpine"]
	args = {"BASETAG" = "12-alpine"}
	tags = [
		"prodrigestivill/postgres-backup-local:12-alpine",
		notequal("", BUILDREV) ? "prodrigestivill/postgres-backup-local:12-alpine-${BUILDREV}" : ""
	]
}

target "debian-11" {
	inherits = ["debian"]
	args = {"BASETAG" = "11"}
	tags = [
		"prodrigestivill/postgres-backup-local:11",
		notequal("", BUILDREV) ? "prodrigestivill/postgres-backup-local:11-debian-${BUILDREV}" : ""
	]
}

target "alpine-11" {
	inherits = ["alpine"]
	args = {"BASETAG" = "11-alpine"}
	tags = [
		"prodrigestivill/postgres-backup-local:11-alpine",
		notequal("", BUILDREV) ? "prodrigestivill/postgres-backup-local:11-alpine-${BUILDREV}" : ""
	]
}

target "debian-10" {
	inherits = ["debian"]
	args = {"BASETAG" = "10"}
	tags = [
		"prodrigestivill/postgres-backup-local:10",
		notequal("", BUILDREV) ? "prodrigestivill/postgres-backup-local:10-debian-${BUILDREV}" : ""
	]
}

target "alpine-10" {
	inherits = ["alpine"]
	args = {"BASETAG" = "10-alpine"}
	tags = [
		"prodrigestivill/postgres-backup-local:10-alpine",
		notequal("", BUILDREV) ? "prodrigestivill/postgres-backup-local:10-alpine-${BUILDREV}" : ""
	]
}

target "debian-9.6" {
	inherits = ["debian"]
	args = {"BASETAG" = "9.6"}
	tags = [
		"prodrigestivill/postgres-backup-local:9.6",
		notequal("", BUILDREV) ? "prodrigestivill/postgres-backup-local:9.6-debian-${BUILDREV}" : ""
	]
}

target "alpine-9.6" {
	inherits = ["alpine"]
	args = {"BASETAG" = "9.6-alpine"}
	tags = [
		"prodrigestivill/postgres-backup-local:9.6-alpine",
		notequal("", BUILDREV) ? "prodrigestivill/postgres-backup-local:9.6-alpine-${BUILDREV}" : ""
	]
}

target "debian-9.5" {
	inherits = ["debian"]
	args = {"BASETAG" = "9.5"}
	tags = [
		"prodrigestivill/postgres-backup-local:9.5",
		notequal("", BUILDREV) ? "prodrigestivill/postgres-backup-local:9.5-debian-${BUILDREV}" : ""
	]
}

target "alpine-9.5" {
	inherits = ["alpine"]
	args = {"BASETAG" = "9.5-alpine"}
	tags = [
		"prodrigestivill/postgres-backup-local:9.5-alpine",
		notequal("", BUILDREV) ? "prodrigestivill/postgres-backup-local:9.5-alpine-${BUILDREV}" : ""
	]
}
