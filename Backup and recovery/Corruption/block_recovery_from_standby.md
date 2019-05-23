# Block recovery from standby

## Подготовительные настройки

Переводим передачу логов в режим LGWR SYNC.
Стендбай открываем в режиме READ ONLY WITH APPLY

## Как генерировать ROWID

Ошибки в V$DATABASE_BLOCK_CORRUPTION

```sql
SQL> select * from v$database_block_corruption;

     FILE#     BLOCK#     BLOCKS CORRUPTION_CHANGE# CORRUPTIO
---------- ---------- ---------- ------------------ ---------
        28    4013725          4         2.6362E+10 NOLOGGING
        17    3320404          1                  0 FRACTURED
        17    3320405          1                  0 ALL ZERO
        17    3320406          1                  0 FRACTURED
```

### Определяем битый объект

```sql
select owner, segment_type, segment_name 
from dba_extents 
where file_id = 17 
and 3320406 between block_id and block_id + blocks - 1;

OWNER                          SEGMENT_TYPE       SEGMENT_NAME
------------------------------ ------------------ ---------------------------------------------------------------------------------
RSBANK_EVS                     TABLE              DOPRDOCS_DBT
```

### ID объекта:

```sql
SQL> select DATA_OBJECT_ID from dba_objects where OWNER='RSBANK_EVS' and OBJECT_NAME='DOPRDOCS_DBT';

DATA_OBJECT_ID
--------------
      12648237
```

### Относительный номер файла данных

```sql
SQL> select RELATIVE_FNO from dba_data_files where FILE_ID=17;

RELATIVE_FNO
------------
          17
```

### Генерируем ROWID по полученным данным

```sql
set serveroutput on
declare
my_rowid varchar2(30);
begin
DBMS_OUTPUT.ENABLE;
my_rowid := DBMS_ROWID.ROWID_CREATE(1, 12648237, 17, 3320406, 1); 
DBMS_OUTPUT.PUT_LINE('ROWID: ' || my_rowid);
end;
/
```

### Обращаемся к битому блоку по ROWID

```sql
SQL> select count(*) from RSBANK_EVS.DOPRDOCS_DBT where rowid='AAwP8tAARAAMqpWAAB';
select count(*) from RSBANK_EVS.DOPRDOCS_DBT where rowid='AAwP8tAARAAMqpWAAB'
                                *
ERROR at line 1:
ORA-01578: ORACLE data block corrupted (file # 17, block # 3320406)
ORA-01110: data file 17: '/EV_prim/oradata/users09.dbf'
```

### После автоматического восстановления блока делаем BACKUP VALIDATE.

```sql
RMAN> backup validate check logical datafile 17;
```

# PROFIT!!!
