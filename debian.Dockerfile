ARG BASETAG=latest
FROM postgres:$BASETAG

ARG GOCRONVER=v0.0.10
ARG TARGETOS
ARG TARGETARCH

# FIX Debian cross build
ARG DEBIAN_FRONTEND=noninteractive
RUN set -x \
	&& ln -s /usr/bin/dpkg-split /usr/sbin/dpkg-split \
	&& ln -s /usr/bin/dpkg-deb /usr/sbin/dpkg-deb \
	&& ln -s /bin/tar /usr/sbin/tar \
	&& ln -s /bin/rm /usr/sbin/rm \
	&& ln -s /usr/bin/dpkg-split /usr/local/sbin/dpkg-split \
	&& ln -s /usr/bin/dpkg-deb /usr/local/sbin/dpkg-deb \
	&& ln -s /bin/tar /usr/local/sbin/tar \
	&& ln -s /bin/rm /usr/local/sbin/rm
#

RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends ca-certificates curl && rm -rf /var/lib/apt/lists/* \
	&& curl -o /usr/local/bin/go-cron.gz -L https://github.com/prodrigestivill/go-cron/releases/download/$GOCRONVER/go-cron-$TARGETOS-$TARGETARCH.gz \
	&& gzip -vnd /usr/local/bin/go-cron.gz && chmod a+x /usr/local/bin/go-cron \
	&& apt-get purge -y --auto-remove ca-certificates && apt-get clean

ENV SCHEDULE="@daily" HEALTHCHECK_PORT=8080

COPY backup.sh /backup.sh

VOLUME /backups

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["exec /usr/local/bin/go-cron -s \"$SCHEDULE\" -p \"$HEALTHCHECK_PORT\" -- /backup.sh"]

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f "http://localhost:$HEALTHCHECK_PORT/" || exit 1
