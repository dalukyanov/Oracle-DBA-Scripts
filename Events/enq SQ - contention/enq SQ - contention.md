# enq: SQ - contention

## Версия

```
11.2.0.4.0
SUSE Linux Enterprise Server 12 (x86_64)
VERSION = 12
PATCHLEVEL = 3
```

## Изменения

Нет

## Диагностика

В БД периодически наблюдаются всплески ожиданий enq: SQ - contention
В топе по данным ожиданиям несколько запросов.

```sql
SELECT
    sql_id,
    COUNT(*)
FROM
    v$active_session_history
WHERE
    event = 'enq: SQ - contention'
GROUP BY
    sql_id
ORDER BY 2 DESC;
```

Смотрим текст запроса, и последовательности (sequence), которые в них используются.

```
SELECT * FROM TABLE(dbms_xplan.display_cursor('0g5w81yq3b22f'));
```

Смотрим, каков размер кэша у последовательности.

```sql
SELECT
    sequence_owner,
    sequence_name,
    cache_size
FROM
    dba_sequences
WHERE
    sequence_owner = 'TEST'
    AND sequence_name = 'SEQ_RN';
```

## Решение:

Увеличиваем размер кэша последовательности.

```
alter sequence TEST.SEQ_RN cache 1000;
```