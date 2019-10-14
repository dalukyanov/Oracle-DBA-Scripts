# TNS-01189: The listener could not authenticate the user

## Проблема

В мониторинге OEM получаем слудующую ошибку:
```
TNS-1189. Please check log for details.
```

В логе лисенера на соответствующем сервере наблюдаем следующее.
```
Tue Oct 08 16:41:37 2019
08-OCT-2019 16:41:37 * (CONNECT_DATA=(COMMAND=version)) * version * 1189
TNS-01189: The listener could not authenticate the user
```

## Диагностика

Данных в логе недостаточно. Непонятно, откуда приходит запрос.
Необходимо включить трассировку лисенера.

```
lsnrctl

LSNRCTL for Linux: Version 11.2.0.4.0 - Production on 11-OCT-2019 00:11:03

Copyright (c) 1991, 2013, Oracle.  All rights reserved.

Welcome to LSNRCTL, type "help" for information.

LSNRCTL> help trace
trace OFF | USER | ADMIN | SUPPORT [<listener_name>] : set tracing to the specified level

LSNRCTL> trace support                                                                   <<<<<<<<<<<<<<<<  Включение трассировки 
Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
Opened trace file: /oracle/diag/tnslsnr/o7/listener/trace/ora_27745_140057668736832.trc  <<<<<<<<< файл трассировки Listener
The command completed successfully
LSNRCTL> trace off                                                                       <<<<<<<<<<<<<<<<  Отключение трассировки 
Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
The command completed successfully
LSNRCTL> exit      
```

В папке, где находится listener.log, будет создан дополнительно трейс с расширенной иноформацией.


## Решение

Ошибка разовая. Так и не удалось воспроизвести для детального анализа.