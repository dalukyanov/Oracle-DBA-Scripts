# UPLOAD SYSTEM Threshold (UploadMaxDiskUsedPct: 98) exceeded with 98.00839)

## Проблема

Получаем сообщения в OEM о том, что закончилось место на Upload System.

emctl status agent

```
Oracle Enterprise Manager Cloud Control 12c Release 4
Copyright (c) 1996, 2014 Oracle Corporation.  All rights reserved.
---------------------------------------------------------------
Agent Version          : 12.1.0.4.0
OMS Version            : 12.1.0.4.0
Protocol Version       : 12.1.0.1.0
...
Number of XML files pending upload           : 0
Size of XML files pending upload(MB)         : 0
Available disk space on upload filesystem    : 1,36%
Collection Status                            : [COLLECTIONS_HALTED(
  UPLOAD SYSTEM Threshold (UploadMaxDiskUsedPct: 98) exceeded with 98.00839)]
Heartbeat Status                             : Ok
...
```

Данная ошибка является предупреждение о превышении порога по месту, но не на OMS, а на самом таргете. Конфигурируется параметром агента UploadMaxDiskUsedPct

## Решение

```
emctl setproperty agent -name UploadMaxDiskUsedPct -value 99
Oracle Enterprise Manager Cloud Control 12c Release 4
Copyright (c) 1996, 2014 Oracle Corporation.  All rights reserved.
EMD setproperty succeeded

emctl stop agent
emctl start agent
```

После перезагрузки агент перестаёт ругаться.