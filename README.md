# postgres-backup-local

Backup PostgresSQL to local filesystem with periodic backups and rotate backups.
Based on [schickling/postgres-backup-s3](https://hub.docker.com/r/schickling/postgres-backup-s3/).

## Usage

Docker:
```sh
$ docker run -e BACKUP_DIR=/backups -e POSTGRES_DATABASE=dbname -e POSTGRES_USER=user -e POSTGRES_PASSWORD=password -e POSTGRES_HOST=localhost schickling/postgres-backup-local
```

Docker Compose:
```yaml
postgres:
  image: postgres
  environment:
    POSTGRES_USER: user
    POSTGRES_PASSWORD: password

pgbackups:
  image: prodrigestivill/postgres-backup-local
  links:
    - postgres
  volumes:
    - /var/opt/pgbackups:/backups
  environment:
    SCHEDULE: '@daily'
    BACKUP_DIR: /backups
    BACKUP_KEEP_DAYS: 7
    BACKUP_KEEP_WEEKS: 4
    BACKUP_KEEP_MONTHS: 6
    POSTGRES_DATABASE: dbname
    POSTGRES_USER: user
    POSTGRES_PASSWORD: password
    POSTGRES_EXTRA_OPTS: '-Z9 --schema=public --blobs'
```

### Automatic Periodic Backups

You can additionally set the `SCHEDULE` environment variable like `-e SCHEDULE="@daily"` to run the backup automatically.

More information about the scheduling can be found [here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).

Folders daily, weekly and monthly are created and populated using hard links to save disk space.
