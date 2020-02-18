# DGMGRL: Physical standby database (disabled)

## Версии

```
SUSE Linux Enterprise Server 12 (x86_64)
VERSION = 12
PATCHLEVEL = 3

Oracle 11.2.0.4
```

## Проблема

Вывод команды dgmgrl show configuration показывает статус стендбая как disabled при общем статусе SUCCESS

```
DGMGRL> show configuration;

Configuration - ap_dg_config

  Protection Mode: MaxPerformance
  Databases:
    prod     - Primary database
    prod_stb - Physical standby database (disabled)

Fast-Start Failover: DISABLED

Configuration Status:
SUCCESS
```

## Диагностика

db_unique_name на нодах отличались регистрами.

```
PRD:

db_unique_name = PROD
log_archive_config = dg_config=(PROD,prod_stb)

STB:
db_unique_name = prod_stb
log_archive_config = dg_config=(PROD,prod_stb)
```

Конфигурация DataGuard регистрозависимая. Но при создании конфига было указано всё в нижнем регистре.

```
CREATE CONFIGURATION ap_dg_config AS PRIMARY DATABASE IS prod CONNECT IDENTIFIER IS prod_prd;
```

## Решение

Конфигурация пересоздана в корректном регистре.

```
REMOVE CONFIGURATION;
CREATE CONFIGURATION ap_dg_config AS PRIMARY DATABASE IS PROD CONNECT IDENTIFIER IS prod_prd;
ADD DATABASE prod_stb AS CONNECT IDENTIFIER IS prod_stb MAINTAINED AS PHYSICAL;
ENABLE CONFIGURATION;
```

