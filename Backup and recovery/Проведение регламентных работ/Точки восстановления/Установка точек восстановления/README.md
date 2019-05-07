# Установка точек восстановления

> Точки восстановления устанавливаются сперва на стендбае, затем на основной базе.

## На стендбае

Проверяем роль БД, включён ли режим Flashback.

```sql
SQL> select name,database_role,open_mode,flashback_on,log_mode from v$database;

NAME      DATABASE_ROLE    OPEN_MODE            FLASHBACK_ON       LOG_MODE
--------- ---------------- -------------------- ------------------ ------------
PCAREEVE  PRIMARY          READ WRITE           YES                ARCHIVELOG
```

Проверяем, существуют ли уже другие точки восстановления.

```sql
SQL> SELECT NAME, SCN, TIME, DATABASE_INCARNATION#, GUARANTEE_FLASHBACK_DATABASE, STORAGE_SIZE FROM V$RESTORE_POINT WHERE GUARANTEE_FLASHBACK_DATABASE='YES';

no rows selected
```

Проверка, запущен ли процесс Recover.

```sql
SQL> select process,status from V$MANAGED_STANDBY where process='MRP0';

PROCESS   STATUS
--------- ------------
MRP0      APPLYING_LOG

```

Если попытаться создать точку при включённом процессе наката, ругается:

```sql
SQL> CREATE RESTORE POINT before_20190507_01 GUARANTEE FLASHBACK DATABASE;
CREATE RESTORE POINT before_20190507_01 GUARANTEE FLASHBACK DATABASE
*
ERROR at line 1:
ORA-38784: Cannot create restore point 'BEFORE_20190507_01'.
ORA-01153: an incompatible media recovery is active
```

Останавливаем процесс наката:

```sql
SQL> alter database recover managed standby database cancel;

Database altered.
```

Устанавливаем точку восстановления:

```sql
SQL> CREATE RESTORE POINT before_20190507_01 GUARANTEE FLASHBACK DATABASE;

Restore point created.
```

Проверяем, что точка установлена:

```sql
SQL> SELECT NAME, SCN, TIME, DATABASE_INCARNATION#, GUARANTEE_FLASHBACK_DATABASE, STORAGE_SIZE FROM V$RESTORE_POINT WHERE GUARANTEE_FLASHBACK_DATABASE='YES';

NAME
--------------------------------------------------------------------------------------------------------------------------------
               SCN TIME                                                                        DATABASE_INCARNATION# GUA       STORAGE_SIZE
------------------ --------------------------------------------------------------------------- --------------------- --- ------------------
BEFORE_20190507_01
         120242243 07-MAY-19 10.51.13.000000000 AM                                                                 2 YES          104857600

```


## На праймари

Проверяем роль БД, включён ли режим Flashback.

```sql
SQL> select name,database_role,open_mode,flashback_on,log_mode from v$database;

NAME      DATABASE_ROLE    OPEN_MODE            FLASHBACK_ON       LOG_MODE
--------- ---------------- -------------------- ------------------ ------------
PCAREEVE  PRIMARY          READ WRITE           YES                ARCHIVELOG
```

Проверяем, существуют ли уже другие точки восстановления.

```sql
SQL> SELECT NAME, SCN, TIME, DATABASE_INCARNATION#, GUARANTEE_FLASHBACK_DATABASE, STORAGE_SIZE FROM V$RESTORE_POINT WHERE GUARANTEE_FLASHBACK_DATABASE='YES';

no rows selected
```

Устанавливаем точку восстановления:

```sql
SQL> CREATE RESTORE POINT before_20190507_01 GUARANTEE FLASHBACK DATABASE;

Restore point created.
```

Проверяем, что точка установлена:

```sql
SQL> SELECT NAME, SCN, TIME, DATABASE_INCARNATION#, GUARANTEE_FLASHBACK_DATABASE, STORAGE_SIZE FROM V$RESTORE_POINT WHERE GUARANTEE_FLASHBACK_DATABASE='YES';

NAME
--------------------------------------------------------------------------------------------------------------------------------
              SCN TIME                                                                        DATABASE_INCARNATION# GUA      STORAGE_SIZE
----------------- --------------------------------------------------------------------------- --------------------- --- -----------------
BEFORE_20190507_01
        120242924 07-MAY-19 10.51.36.000000000 AM                                                                 2 YES         104857600
```

