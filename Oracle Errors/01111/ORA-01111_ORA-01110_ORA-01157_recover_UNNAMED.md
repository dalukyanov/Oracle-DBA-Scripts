# ORA-01111: name for data file 62 is unknown - rename to correct file

## Проблема

```sql
ORA-01111: name for data file 62 is unknown - rename to correct file
ORA-01110: data file 62: '/opt/oracle/product/11.2.0.3/dbhome_1/dbs/UNNAMED00062'
ORA-01157: cannot identify/lock data file 62 - see DBWR trace file
```

После добавления файла данных на проде, он не создан на стендбае.
Это происходит, когда пути на проде нет соответствующего пути на стендбае.

## Решение

Файла не существует. Необходимо его досоздать.

```sql
SQL> ALTER DATABASE CREATE DATAFILE '/opt/oracle/product/11.2.0.3/dbhome_1/dbs/UNNAMED00062' as '/u02/oracle/prod/owfin_d/owfin_d04.dbf';

Database altered.

SQL> !ls -la /u02/oracle/prod/owfin_d/owfin_d04.dbf
-rw-r-----    1 oracle   oinstall 628717312 Aug 16 17:05 /u02/oracle/prod/owfin_d/owfin_d04.dbf

SQL> alter database recover managed standby database using current logfile disconnect from session;

Database altered.
```