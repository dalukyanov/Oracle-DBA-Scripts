# ORA-00600: internal error code, arguments: [ksnpost:ksnigb], [], [], [], [], [], [], [], [], [], [], []

## Проблема.

В alert-логе наблюдаем следующие ошибки:

```
Errors in file /opt/oracle/diag/rdbms/orcl_prd_new/orcl/trace/orcl_ora_1317.trc  (incident=161942):
ORA-00600: internal error code, arguments: [ksnpost:ksnigb], [], [], [], [], [], [], [], [], [], [], []
ORA-27102: out of memory
Linux-x86_64 Error: 12: Cannot allocate memory
Additional information: 108
Additional information: 3342336
```

## Диагностика.

В трейсе /opt/oracle/diag/rdbms/orcl_prd_new/orcl/trace/orcl_ora_1317.trc:

```
...
*** 2019-07-26 10:38:05.266
*** SESSION ID:(4983.27015) 2019-07-26 10:38:05.266
*** CLIENT ID:() 2019-07-26 10:38:05.266
*** SERVICE NAME:(orcl) 2019-07-26 10:38:05.266
*** MODULE NAME:(SOME$BudgSomeBalance) 2019-07-26 10:38:05.266
*** ACTION NAME:(Execute) 2019-07-26 10:38:05.266

mmap(offset=240381952, len=8192) failed with errno=12 for the file oracleORCL
mmap(offset=240381952, len=8192) failed with errno=12 for the file oracleORCL
mmap(offset=240381952, len=8192) failed with errno=12 for the file oracleORCL
mmap(offset=240381952, len=8192) failed with errno=12 for the file oracleORCL
mmap(offset=240381952, len=8192) failed with errno=12 for the file oracleORCL
...
```

Видим, что есть проблемы с выделением памяти.
Смотрим текущее потребление.

```
SELECT
    s.sid,
    s.username,
    s.program,
    s.sql_id,
    s.prev_sql_id,
    s.module,
    s.machine,
    s.event,
    p.pga_used_mem
FROM
    v$session   s
    JOIN v$process   p ON s.paddr = p.addr
ORDER BY
    p.pga_used_mem DESC;
```

Смотрим размер pga_aggregate_target.
```
select name,value from v$parameter where name = 'pga_aggregate_target';
```

В ОС смотрим текущее потребление. Видим, что скушался своп.
```
top - 11:24:09 up 181 days, 13:52,  4 users,  load average: 17.38, 16.51, 16.63
Tasks: 2609 total,  20 running, 2589 sleeping,   0 stopped,   0 zombie
%Cpu(s): 40.1 us,  8.7 sy,  0.0 ni, 42.4 id,  8.4 wa,  0.0 hi,  0.5 si,  0.0 st
KiB Mem:  13192270+total, 13143004+used,   492656 free,     9268 buffers
KiB Swap: 22495228 total, 21795368 used,   699860 free.  4127684 cached Mem
...
```


## Решение.

Данные анализа направлены ответственным лицам. Запущена бизнес-задача. Мониторят.