# ORA-20200: Begin Snapshot Id 1 does not exist for this database/instance

## Версия

11.2.0.4

## Изменения

Нет

## Диагностика

При попытке построить AWR-отчёт через

```
@?/rdbms/admin/awrrpt
```

Появляются ошибки:

```
ORA-20200: Begin Snapshot Id 1 does not exist for this database/instance
ORA-06512: at line 22
```

Проверяем, включена ли статистика.

```
SQL> show parameter statistics_level

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
statistics_level                     string      TYPICAL
```

Проверяем расписание снятия снапшотов AWR.

```
SELECT
    EXTRACT(DAY FROM snap_interval) * 24 * 60 + EXTRACT(HOUR FROM snap_interval) * 60 + EXTRACT(MINUTE FROM snap_interval) snapshot_interval,
    EXTRACT(DAY FROM retention) * 24 * 60 + EXTRACT(HOUR FROM retention) * 60 + EXTRACT(MINUTE FROM retention) retention_interval
FROM
    dba_hist_wr_control;

SNAPSHOT_INTERVAL RETENTION_INTERVAL
----------------- ------------------
               60              11520
```

Всё в норме. Попробуем вручную снять снапшот.

```
EXEC dbms_workload_repository.create_snapshot;

ERROR at line 1:
ORA-13509: error encountered during updates to a AWR table
ORA-01683: unable to extend index ORA-01683: unable to extend index SYS.WRH$_LATCH_PK partition WRH$_LATCH_1152737313_0 by 1024 in tablespace SYSAUX
. partition by  in tablespace
ORA-06512: at "SYS.DBMS_WORKLOAD_REPOSITORY", line 99
ORA-06512: at "SYS.DBMS_WORKLOAD_REPOSITORY", line 122
ORA-06512: at line 1
```


## Решение

1. Забилось табличное пространство SYSAUX. Необходимо расширить существующий файл, либо добавить дополнительный.
2. Проверить, почему забилось место. Возможно, логами аудита в таблице SYS.AUD$