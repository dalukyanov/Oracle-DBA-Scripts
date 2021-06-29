# Ошибки ORA-00600: internal error code, arguments: [qcisSetPlsqlCtx:tzi init]

## Версия

11.2.0.4.0
SUSE Linux Enterprise Server 12 (x86_64)
VERSION = 12
PATCHLEVEL = 3

## Изменения

Создание тестовой копии для продуктивной БД в отдельном контуре. Новая установка. Те же патчи.

```
ORA-00600: internal error code, arguments: [qcisSetPlsqlCtx:tzi init], [], [], [], [], [], [], [], [], [], [], []
```


## Диагностика

Патчи на проде и тесте совпадают

```
31219953;OJVM PATCH SET UPDATE 11.2.0.4.200714
31103343;Database Patch Set Update : 11.2.0.4.200714 (31103343)
27015449;
```

Но при запросе к v$timezone_file на тесет пусто:

```
SQL> SELECT version FROM v$timezone_file;

no rows selected

SQL> SELECT PROPERTY_NAME, SUBSTR(property_value, 1, 30) value
FROM DATABASE_PROPERTIES
WHERE PROPERTY_NAME LIKE 'DST_%'
ORDER BY PROPERTY_NAME;  2    3    4

PROPERTY_NAME
--------------------------------------------------------------------------------
VALUE
--------------------------------------------------------------------------------
DST_PRIMARY_TT_VERSION
25

DST_SECONDARY_TT_VERSION
0

DST_UPGRADE_STATE
NONE
```

На проде:

```
SQL> SELECT version FROM v$timezone_file;

   VERSION
----------
        25

SQL> SELECT PROPERTY_NAME, SUBSTR(property_value, 1, 30) value
FROM DATABASE_PROPERTIES
WHERE PROPERTY_NAME LIKE 'DST_%'
ORDER BY PROPERTY_NAME;  2    3    4

PROPERTY_NAME
--------------------------------------------------------------------------------
VALUE
--------------------------------------------------------------------------------
DST_PRIMARY_TT_VERSION
25

DST_SECONDARY_TT_VERSION
0

DST_UPGRADE_STATE
NONE

```


При проверке выяснилось, что в $ORACLE_HOME/oracore/zoneinfo разный набор патчей. На тесте отсутствует 25 версия файла. Хотя патч установлен для 31 версии.

## Решение:

Как оказалось, DST-патчи не куммулятивные. Ставится конкретная версия. На проде была промежуточная 25, а затем поставили 31. Но в БД не меняли. Там так и осталась 25.

Варианты решения:
1. Обновить на тесте в БД версию до 31, для которой есть патч
2. Если обновление не подходит по тем или иным причинам, то просто скопировать содержимое директории $ORACLE_HOME/oracore/zoneinfo с прода на тест.