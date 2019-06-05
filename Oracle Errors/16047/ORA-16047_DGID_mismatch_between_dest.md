# ORA-16047 - DGID mismatch between destination setting and target database.

## Проблема

Wed Jun 05 18:12:55 2019
PING[ARC1]: Heartbeat failed to connect to standby 'inf_stb'. Error is 16047.

## Диагностика

Необходимо сверить конфигурацию, прописанную в log_archive_config

```
SQL> show parameter log_archive_config

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
log_archive_config                   string      dg_config=(inf_prd,inf_stb)
```

И значения, которые прописаны в db_unique_name на обоих экземплярах (прод и стендбай).

```
SQL> show parameter db_unique_name

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_unique_name                       string      inf_prd
```

В данном случае на стендбае была неправильная конфигурация. Был прописан inf_prd.


## Решение

Меняем на inf_stb. Перезапускаем стендбай.