FROM alpine:3.4
MAINTAINER Pau Rodriguez-Estivill "prodrigestivill@gmail.com"

ADD install.sh install.sh
RUN sh install.sh && rm install.sh

ENV POSTGRES_DB **None**
ENV POSTGRES_HOST **None**
ENV POSTGRES_PORT 5432
ENV POSTGRES_USER **None**
ENV POSTGRES_PASSWORD **None**
ENV POSTGRES_EXTRA_OPTS '-Z9'
ENV SCHEDULE **None**
ENV BACKUP_DIR '/backups'
ENV BACKUP_KEEP_DAYS 7
ENV BACKUP_KEEP_WEEKS 4
ENV BACKUP_KEEP_MONTHS 6

ADD run.sh run.sh
ADD backup.sh backup.sh

CMD ["sh", "run.sh"]
