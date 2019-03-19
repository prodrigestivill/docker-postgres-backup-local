# postgres-backup-local

Backup PostgresSQL to the local filesystem with periodic rotating backups, based on [schickling/postgres-backup-s3](https://hub.docker.com/r/schickling/postgres-backup-s3/).
Backup multiple databases from the same host by setting the database names in `POSTGRES_DB` separated by commas or spaces.

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
| POSTGRES_HOST | postgres connection parameter; postgres host to connect to. |
| POSTGRES_DB | comma or space separated list of postgres databases to backup. |
| POSTGRES_USER | postgres connection parameter; postgres user to connect with. |
| POSTGRES_PASSWORD | postgres connection parameter; postgres password to connect with. |
| POSTGRES_PASSWORD_FILE | alternative to POSTGRES_PASSWORD, useful with docker secrets. |
| POSTGRES_EXTRA_OPTS | additional options for `pg_dump`. |
| SCHEDULE | [cron-schedule](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules) specifying the interval between postgres backups. |
| BACKUP_KEEP_DAYS | number of daily backups to keep before removal. |
| BACKUP_KEEP_WEEKS | number of weekkly backups to keep before removal. |
| BACKUP_KEEP_MONTHS | number of monthly backups to keep before removal. |
| HEALTHCHECK_PORT | Port listening for cron-schedule health check. |

### Manual Backups

By default this container makes daily backups, but you can start a manual backup by running `/backup.sh`:

```sh
$ docker run -e POSTGRES_HOST=postgres -e POSTGRES_DB=dbname -e POSTGRES_USER=user -e POSTGRES_PASSWORD=password  prodrigestivill/postgres-backup-local /backup.sh
```

### Automatic Periodic Backups

You can change the `SCHEDULE` environment variable in `-e SCHEDULE="@daily"` to alter the default frequency. Default is `daily`.

More information about the scheduling can be found [here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).

Folders `daily`, `weekly` and `monthly` are created and populated using hard links to save disk space.
