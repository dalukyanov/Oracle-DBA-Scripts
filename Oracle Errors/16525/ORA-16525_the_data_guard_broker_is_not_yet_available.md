# ORA-16525: the Data Guard broker is not yet available

## Проблема

При попытке сделать что-либо в dgmgrl, ошибка ORA-16525: the Data Guard broker is not yet available

## Диагностика

Не запущен процесс Data Guard Broker (DMON)

```
SQL> show parameter dg_broker_start

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
dg_broker_start                      boolean     FALSE
```

## Решение

```
SQL> alter system set dg_broker_start=true scope=both;
```

Соответствующие процессы поднимутся в экземпляре.

```
Wed Jun 05 18:40:15 2019
DMON started with pid=40, OS id=24846
Starting Data Guard Broker (DMON)
Wed Jun 05 18:40:24 2019
INSV started with pid=44, OS id=24848
Wed Jun 05 18:40:55 2019
NSV1 started with pid=35, OS id=24863
Wed Jun 05 18:41:17 2019
RSM0 started with pid=49, OS id=24877
```