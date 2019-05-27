# Error in invoking target 'agent nmhs' of makefile

## Проблема

При установке 11.2.0.4 на SUSE Linux Enterprise Server 12 (проблеме подвержены и другие Linux-дистрибутивы)

Error in invoking target 'agent nmhs' of makefile '/u01/app/oracle/product/11.2.0.4/dbhome_1/sysman/lib/ins_emagent.mk'. See '/u01/app/oraInventory/logs/installActions2019-05-27_04-07-11PM.log' for details.

## Решение

Необходимо отредактировать следующий файл:

```
$ORACLE_HOME/sysman/lib/ins_emagent.mk
```

Находим следующую строку, и добавляем опцию "-lnnz11"
Меняем:
```
$(MK_EMAGENT_NMECTL)
```
на
```
$(MK_EMAGENT_NMECTL) -lnnz11
```