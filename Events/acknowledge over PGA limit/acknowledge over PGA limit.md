# acknowledge over PGA limit

## Версия

12.2.0.1.0
SUSE Linux Enterprise Server 12 (x86_64)
VERSION = 12
PATCHLEVEL = 3

## Изменения

Проблема обнаружена после увеличения памяти сервера с 4 до 16 ГБ, и перенастройки экземпляра на использование новых значений.

## Диагностика

Имеются высокие ожидания acknowledge over PGA limit (до 50% от активных сессий).
acknowledge over PGA limit - это новое событие ожидание, введённое с появлением параметра PGA_AGGREGATE_LIMIT в 12.1
Вероятно, это BUG 26255710 - "ACKNOWLEDGE OVER PGA LIMIT" AFFECTS THE PERFORMANCE OF PL/SQL PROGRAM

## Решение:

1. Отключить параметр PGA_AGGREGATE_LIMIT
```
alter system set PGA_AGGREGATE_LIMIT=0 scope=both;
```

или

2. Установить Patch 24416451