# Ресинхронизация RMAN каталога зависает на неопределённый срок.

## Проблема

Ресинхронизация RMAN каталога повисает на неопределённый срок.
В трейсе RMAN наблюдаются в цикле сообщения вида:

```
…
DBGRPC:          krmxrpc - channel default kpurpc2 err=0 db=rcvcat proc=RMAN.DBMS_RCVCAT.CHECKRMANSTATUS excl: 0
     DBGRCVCAT: checkRmanStatus - inserting into rsr
     DBGRCVCAT: checkRmanStatus - this_dbinc_key:779077
     DBGRCVCAT: checkRmanStatus - recid:         164495
     DBGRCVCAT: checkRmanStatus - stamp:         807429602
     DBGRCVCAT: checkRmanStatus - srecid:        164495
     DBGRCVCAT: checkRmanStatus - sstamp:        807429602
DBGRESYNC:       channel default: Calling checkRmanStatus for 164496 with status COMPLETED [15:59:05.131] (resync)
…
```

## Диагностика

Никаких нот на металинке явно указывающих на данную проблему я не нашёл. Однако, есть подозрения, что зависание связано с огромным размером секции RMAN_STATUS в контрольном файле базы. В данном случае она имеет порядка 960000 записей. Для сравнения, аналогичная секция в другой базе, которая была добавлена в каталог, имеет всего 30000 записей.

Посмотреть текущий размер секции можно запросом:

```sql
SQL> select TYPE,RECORD_SIZE,RECORDS_TOTAL,RECORDS_USED from V$CONTROLFILE_RECORD_SECTION where TYPE='RMAN STATUS';

TYPE                         RECORD_SIZE RECORDS_TOTAL RECORDS_USED
---------------------------- ----------- ------------- ------------
RMAN STATUS                          116        960512       960512
```

## Решение

> Применять на свой риск!!!

Можно очистить данную секцию следующей процедурой:

```sql
exec SYS.DBMS_BACKUP_RESTORE.resetCfileSection(28);
```

> Я пробовал проводить подобные операции с секциями RMAN STATUS, ARCHIVED LOG и некоторыми другими, касающимися бэкапов BACKUP*
> Однако, следует быть крайне внимательным, чтобы не очистить секцию, например, с файлами данных.


> NOTE: 
> 
> If you clear a controlfile section using undocumented event, then you also need to update high_al_recid in the node table for that database to 0 in 
> recovery catalog.
> 
> For 11g recovery catalog schema and above:
> 
> update node set high_al_recid = 0 where db_unique_name = '<your target database db_unique_name'.
> 
> For 10gR2 recovery catalog schema and below:
> 
> update dbinc set high_al_recid = 0 where db_name = '<your target database db_name>';




