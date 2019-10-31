# Определение, какие события (events) установлены в другой сессии


## Пример

1. В первой сессии ставим sql_trace
```
ALTER SESSION SET EVENTS '10046 trace name context forever, level 8';
```

2. В другой сессии определяем её pid
```
select p.pid
     from v$process p, v$session s 
     where p.addr = s.paddr
     and s.username = 'YOUR_USER';
```

3. В sqlplus запускаем oradebug и получаем результат
```
SQL> oradebug setorapid 112
Oracle pid: 112, Unix process pid: 26139, image: oracle@srv-cls-ora01
SQL> oradebug eventdump session
sql_trace level=8
```