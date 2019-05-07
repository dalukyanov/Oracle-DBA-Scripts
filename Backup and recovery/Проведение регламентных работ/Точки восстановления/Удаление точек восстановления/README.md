# Удаление точек восстановления

## На праймари

Проверка, что точка восстановления существует:

```sql
col name format a40
col SCN format 999999999999999
col TIME format a40
col DATABASE_INCARNATION# format 999
col GUARANTEE_FLASHBACK_DATABASE format a3
col STORAGE_SIZE format 9999999999999
SELECT NAME, SCN, TIME, DATABASE_INCARNATION#, GUARANTEE_FLASHBACK_DATABASE, STORAGE_SIZE FROM V$RESTORE_POINT WHERE GUARANTEE_FLASHBACK_DATABASE='YES';

NAME                                                  SCN TIME                                     DATABASE_INCARNATION# GUA   STORAGE_SIZE
---------------------------------------- ---------------- ---------------------------------------- --------------------- --- --------------
BEFORE_20190507_01                              120242924 07-MAY-19 10.51.36.000000000 AM                              2 YES      209715200
```

Удаление точки:

```sql
drop restore point BEFORE_20190507_01;

Restore point dropped.
```

## На стендбае

> До 12-ой версии удаление точек восстановления на стендбае требует его перезапуска. В 12-ой этот шаг можно пропустить, и сделать аналогично праймари.

Проверка, что точка восстановления существует:

```sql
col name format a40
col SCN format 999999999999999
col TIME format a40
col DATABASE_INCARNATION# format 999
col GUARANTEE_FLASHBACK_DATABASE format a3
col STORAGE_SIZE format 9999999999999
SELECT NAME, SCN, TIME, DATABASE_INCARNATION#, GUARANTEE_FLASHBACK_DATABASE, STORAGE_SIZE FROM V$RESTORE_POINT WHERE GUARANTEE_FLASHBACK_DATABASE='YES';

NAME                                                  SCN TIME                                     DATABASE_INCARNATION# GUA   STORAGE_SIZE
---------------------------------------- ---------------- ---------------------------------------- --------------------- --- --------------
BEFORE_20190507_01                              120242924 07-MAY-19 10.51.36.000000000 AM                              2 YES      209715200
```

Перезагружаем экземпляр.

```sql
SQL> shutdown immediate;
Database closed.
Database dismounted.
ORACLE instance shut down.
```

Запускаем в режиме MOUNT

```sql
SQL> set pagesize 999
SQL> set linesize 140
SQL> set numf 99999999999999999
SQL> startup nomount;
ORACLE instance started.

Total System Global Area        10956709888 bytes
Fixed Size                          2262976 bytes
Variable Size                    7482640448 bytes
Database Buffers                 3456106496 bytes
Redo Buffers                       15699968 bytes
SQL> alter database mount standby database;

Database altered.
```

Удаляем точку восстановления:

```sql
SQL> drop restore point BEFORE_20190507_01;

Restore point dropped.
```

Если стендбай работает в режиме Active Standby with log apply, то запускаем в режиме Read Only.

```sql
SQL> alter database open read only;

Database altered.
```

Запускаем накат логов.

```sql
SQL> alter database recover managed standby database using current logfile disconnect from session;
```

> Если настроен DataGuard Broker, то он, возможно, уже успел запустить процесс наката логов сам. Тогда ничего дополнительно делать не нужно.

```sql
SQL> alter database recover managed standby database using current logfile disconnect from session;
alter database recover managed standby database using current logfile disconnect from session
*
ERROR at line 1:
ORA-01153: an incompatible media recovery is active
```