# Включение Flashback Database.

## Проверяем, включён ли Flashback.

```sql
SQL> select flashback_on from v$database;

FLASHBACK_ON
------------------
NO
```

Смотрим, сконфигурирована ли Fast Recovery Area, и достаточно ли в ней места.

```sql
SQL> show parameter db_re

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_recovery_file_dest                string      /u01/oracle/app/fast_recovery_
                                                 area
db_recovery_file_dest_size           big integer 35G
```

Проверка, что в разделе достаточно места

```bash
df -h /u01/oracle/app/fast_recovery_area
Filesystem           Size  Used Avail Use% Mounted on
/dev/mapper/data-01  493G  312G  181G  64% /u01
```

Проверяем, что время удержания flashback-логов равно сутки или 1440 минут (по умолчанию).

```sql
SQL> show parameter db_flashback_retention_target

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_flashback_retention_target        integer     1440
```

Проверяем, включен ли режим Archivelog.

```sql
SQL> archive log list
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            USE_DB_RECOVERY_FILE_DEST
Oldest online log sequence     7869
Next log sequence to archive   7872
Current log sequence           7872
```

Проверяем, что включена политика удаления архивных логов только после бэкапа на ленту и перименения на стендбае в случае прода. И применении на стендбае в случае стендбая.

Прод:
```sql
RMAN> CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL STANDBY BACKED UP 1 TIMES TO 'SBT_TAPE';
```

Стендбай:
```sql
RMAN> CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL STANDBY;
```

## Включение Flashback database.

На проде:
```sql
SQL> alter database flashback on;

Database altered.
```

На стендбае:

```sql
SQL> alter database recover managed standby database cancel;

Database altered.

SQL> alter database flashback on;

Database altered.

SQL> select flashback_on from v$database;

FLASHBACK_ON
------------------
YES

SQL> alter database recover managed standby database using current logfile disconnect from session;

Database altered.
```