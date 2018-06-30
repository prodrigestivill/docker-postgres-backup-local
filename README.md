# postgres-backup-local

Backup PostgresSQL to local filesystem with periodic backups and rotate backups.
Based on [schickling/postgres-backup-s3](https://hub.docker.com/r/schickling/postgres-backup-s3/).
It can backup multiple databases from the same host by setting all databases in `POSTGRES_DB` separated by comas or spaces.

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
            - POSTGRES_EXTRA_OPTS=-Z9 --schema=public --blobs
            - SCHEDULE=@daily
            - BACKUP_KEEP_DAYS=7
            - BACKUP_KEEP_WEEKS=4
            - BACKUP_KEEP_MONTHS=6
```

### Manual Backups

By default it makes daily backups but you can start a manual one by running the command `/backup.sh`.

Example running only manual backup on Docker:
```sh
$ docker run -e POSTGRES_HOST=postgres -e POSTGRES_DB=dbname -e POSTGRES_USER=user -e POSTGRES_PASSWORD=password  prodrigestivill/postgres-backup-local /backup.sh
```

### Automatic Periodic Backups

You can change the `SCHEDULE` environment variable like `-e SCHEDULE="@daily"` to change its default frequency, by default is daily.

More information about the scheduling can be found [here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).

Folders daily, weekly and monthly are created and populated using hard links to save disk space.
