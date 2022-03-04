# postgres-backup-local build instructions

To build and push all images to it's own repository.

## Prepare environment

* Configure you system to use [Docker Buildx](https://docs.docker.com/buildx/working-with-buildx/).
* Prepare crosscompile environment (see below).

### Prepare crosscompile environment

In order to work in Arch Linux the following initialization commands will be required:

```sh
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx rm multibuilder
docker buildx create --name multibuilder --platform linux/amd64,linux/arm64,linux/arm/v7,linux/s390x,linux/ppc64le --driver docker-container --use
docker buildx inspect --bootstrap
```

## Generate the images

### Generate build configuration

In order to modify the image name or any other configurable parameter run the `generate.sh` script.

```sh
IMAGE_NAME="postgres-backup-local" ./generate.sh config.hcl
```

### Build the images

In order to only build the images locally run the following command:

```sh
docker buildx bake --pull -f config.hcl
```

In order to publish directly to the repository run this command instead:

```sh
REGISTRY_PREFIX="dockerhub_username/" docker buildx bake --pull --push -f config.hcl
```

Also, optionally, it can also generate build revision tags from last git commit:

```sh
REGISTRY_PREFIX="dockerhub_username/" BUILD_REVISION=$(git rev-parse --short HEAD) docker buildx bake --pull --push -f config.hcl
```
