# ORA-1652: unable to extend temp segment by 128 in tablespace TEMP

## Версия

11.2.0.4.0
SUSE Linux Enterprise Server 12 (x86_64)
VERSION = 12
PATCHLEVEL = 3

## Проблема

В алерт-логе БД имеются ошибки вида:
```
Tue Aug 13 09:58:45 2019
ORA-1652: unable to extend temp segment by 128 in tablespace TEMP
```

## Диагностика

Если случай единичный, как правило, можно просто игнорировать.
Для порядка можно проверить размер TEMP. Может, он действительно мал.

```
select sum(bytes)/1024/1024/1024 "SIZE_GB" from dba_temp_files where tablespace_name = 'TEMP';
```

На всякий случай можно включить трассировку errorstack по событию 1652. Тогда при следующей подобной ошибке мы получим подробный трейс с кодом проблемного запроса.

```
alter system set events '1652 trace name errorstack level 3';
```

## Решение

После генерации errorstack trace выявить проблемный запрос, и оптимизировать его.