# Ошибки ORA-07445: exception encountered: core dump [ksm_mga_heap_alloc_cbk()+166] [SIGBUS] [ADDR:0x40000A000000] [PC:0xFC5B36] [Non-existent physical address] []

## Версия

12.2.0.1.0
SUSE Linux Enterprise Server 12 (x86_64)
VERSION = 12
PATCHLEVEL = 3

## Изменения

Проблема обнаружена после увеличения памяти сервера с 4 до 16 ГБ, и перенастройки экземпляра на использование новых значений.

## Диагностика

В алерт-логе БД имеем:

```
2019-08-08T00:58:03.057831+03:00
Exception [type: SIGBUS, Non-existent physical address] [ADDR:0x40000A000000] [PC:0xFC5B36, ksm_mga_heap_alloc_cbk()+166] [flags: 0x0, count: 1]
Errors in file /u01/app/oracle/diag/rdbms/gdes/GDES/trace/GDES_m000_7901.trc  (incident=65811) (PDBNAME=CDB$ROOT):
ORA-07445: exception encountered: core dump [ksm_mga_heap_alloc_cbk()+166] [SIGBUS] [ADDR:0x40000A000000] [PC:0xFC5B36] [Non-existent physical address] []
```

В /u01/app/oracle/diag/rdbms/gdes/GDES/trace/GDES_m000_7901.trc:

```
...
*** 2019-08-08T00:58:03.057619+03:00 (CDB$ROOT(1))
*** SESSION ID:(15.23571) 2019-08-08T00:58:03.057661+03:00
*** CLIENT ID:() 2019-08-08T00:58:03.057667+03:00
*** SERVICE NAME:(SYS$BACKGROUND) 2019-08-08T00:58:03.057674+03:00
*** MODULE NAME:(MMON_SLAVE) 2019-08-08T00:58:03.057680+03:00
*** ACTION NAME:(Automatic Report Flush) 2019-08-08T00:58:03.057686+03:00
*** CLIENT DRIVER:() 2019-08-08T00:58:03.057692+03:00
*** CONTAINER ID:(1) 2019-08-08T00:58:03.057699+03:00

Exception [type: SIGBUS, Non-existent physical address] [ADDR:0x40000A000000] [PC:0xFC5B36, ksm_mga_heap_alloc_cbk()+166] [flags: 0x0, count: 1]
DDE: Problem Key 'ORA 7445 [ksm_mga_heap_alloc_cbk]' was flood controlled (0x2) (incident: 65811)
ORA-07445: exception encountered: core dump [ksm_mga_heap_alloc_cbk()+166] [SIGBUS] [ADDR:0x40000A000000] [PC:0xFC5B36] [Non-existent physical address] []
Dumping swap information
Memory (Avail / Total) = 4317.56M / 16046.42M
Swap (Avail / Total) = 1332.00M /  1332.00M
ssexhd: crashing the process...
Shadow_Core_Dump = partial
ksdbgcra: writing core file to directory '/u01/app/oracle/diag/rdbms/gdes/GDES/cdump'

...
```

Нас в данном трейсе интересует только шапка. 
MODULE NAME:(MMON_SLAVE)
ACTION NAME:(Automatic Report Flush)

Видно, что проблема возникает лишь в работе процесса MMON и, собственно, его слейвов M000 и т.д., которые падают...
Падает на процессе Automatic Report Flush. Это часть нового механизма Automatic Report Capturing в 12с. Гугление показало, что он в принципе имеет баги по CPU, и многие его отключают.


## Решение:

Откючение механизма Automatic Report не помогло. Обнаружили, что имеется ошибка в настройках разделяемой памяти. /dev/shm выдано 16 байт вместо 14 ГБ планируемых.

```
more /etc/fstab
...
none                    /dev/shm        tmpfs   defaults,size=16  0 0
...
```

После изменения параметра перезагрузили сервер. Проблема ушла.