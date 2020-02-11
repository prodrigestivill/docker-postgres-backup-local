![Docker Pulls](https://img.shields.io/docker/pulls/prodrigestivill/postgres-backup-local)

# postgres-backup-local

Backup PostgresSQL to the local filesystem with periodic rotating backups, based on [schickling/postgres-backup-s3](https://hub.docker.com/r/schickling/postgres-backup-s3/).
Backup multiple databases from the same host by setting the database names in `POSTGRES_DB` separated by commas or spaces.

Supports the following Docker architectures: `linux/amd64`, `linux/arm64`, `linux/arm/v7`.

## Usage

Docker:
```sh
$ docker run -e POSTGRES_HOST=postgres -e POSTGRES_DB=dbname -e POSTGRES_USER=user -e POSTGRES_PASSWORD=password  prodrigestivill/postgres-backup-local
```

Docker Compose:
```yaml
version: '2'
services:
    postgres:
        image: postgres
        restart: always
        environment:
            - POSTGRES_DB=database
            - POSTGRES_USER=username
            - POSTGRES_PASSWORD=password
         #  - POSTGRES_PASSWORD_FILE=/run/secrets/db_password <-- alternative for POSTGRES_PASSWORD (to use with docker secrets)
    pgbackups:
        image: prodrigestivill/postgres-backup-local
        restart: always
        volumes:
            - /var/opt/pgbackups:/backups
        links:
            - postgres
        depends_on:
            - postgres
        environment:
            - POSTGRES_HOST=postgres
            - POSTGRES_DB=database
            - POSTGRES_USER=username
            - POSTGRES_PASSWORD=password
         #  - POSTGRES_PASSWORD_FILE=/run/secrets/db_password <-- alternative for POSTGRES_PASSWORD (to use with docker secrets)
            - POSTGRES_EXTRA_OPTS=-Z9 --schema=public --blobs
            - SCHEDULE=@daily
            - BACKUP_KEEP_DAYS=7
            - BACKUP_KEEP_WEEKS=4
            - BACKUP_KEEP_MONTHS=6
            - HEALTHCHECK_PORT=80

```

### Environment Variables
Most variables are the same as in the [official postgres image](https://hub.docker.com/_/postgres/).

| env variable | description |
|--|--|
| BACKUP_DIR | Directory to save the backup at. Defaults to `/backups`. |
| BACKUP_KEEP_DAYS | Number of daily backups to keep before removal. Defaults to `7`. |
| BACKUP_KEEP_WEEKS | Number of weekkly backups to keep before removal. Defaults to `4`. |
| BACKUP_KEEP_MONTHS | Number of monthly backups to keep before removal. Defaults to `6`. |
| HEALTHCHECK_PORT | Port listening for cron-schedule health check. Defaults to `8080`. |
| POSTGRES_DB | Comma or space separated list of postgres databases to backup. Required. |
| POSTGRES_DB_FILE | Alternative to POSTGRES_DB, but with one database per line, for usage with docker secrets. |
| POSTGRES_EXTRA_OPTS | Additional options for `pg_dump`. Defaults to `-Z9`. |
| POSTGRES_HOST | Postgres connection parameter; postgres host to connect to. Required. |
| POSTGRES_PASSWORD | Postgres connection parameter; postgres password to connect with. Required. |
| POSTGRES_PASSWORD_FILE | Alternative to POSTGRES_PASSWORD, for usage with docker secrets. |
| POSTGRES_PORT | Postgres connection parameter; postgres port to connect to. Defaults to `5432`. |
| POSTGRES_USER | Postgres connection parameter; postgres user to connect with. Required. |
| POSTGRES_USER_FILE | Alternative to POSTGRES_USER, for usage with docker secrets. |
| SCHEDULE | [Cron-schedule](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules) specifying the interval between postgres backups. Defaults to `@daily`. |

#### Special Environment Variables
This variables are not intended to be used for normal deployment operations:

| env variable | description |
|--|--|
| POSTGRES_PORT_5432_TCP_ADDR | Sets the POSTGRES_HOST when the latter is not set. |
| POSTGRES_PORT_5432_TCP_PORT | Sets POSTGRES_PORT when POSTGRES_HOST is not set. |

### Manual Backups

By default this container makes daily backups, but you can start a manual backup by running `/backup.sh`:

```sh
$ docker run -e POSTGRES_HOST=postgres -e POSTGRES_DB=dbname -e POSTGRES_USER=user -e POSTGRES_PASSWORD=password  prodrigestivill/postgres-backup-local /backup.sh
```

### Automatic Periodic Backups

You can change the `SCHEDULE` environment variable in `-e SCHEDULE="@daily"` to alter the default frequency. Default is `daily`.

More information about the scheduling can be found [here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).

Folders `daily`, `weekly` and `monthly` are created and populated using hard links to save disk space.
