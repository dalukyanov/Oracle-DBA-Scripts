# Ошибки ORA-00600: internal error code, arguments: [krccacp_badfile], [10150310067047], [10150310065594], [], [], [], [], [], [], [], [], []

## Версия

11.2.0.4.0
SUSE Linux Enterprise Server 12 (x86_64)
VERSION = 12
PATCHLEVEL = 3

## Изменения

БД является новой копией БД, находящейся на том же сервере. Сам запустился нормально, но при запуске изсходного экземпляра упал с ошибкой:

```
Errors in file /u01/app/oracle/diag/rdbms/stndcopy/STNDCOPY/trace/STNDCOPY_ctwr_31324.trc  (incident=36153):
ORA-00600: internal error code, arguments: [krccacp_badfile], [10150310067047], [10150310065594], [], [], [], [], [], [], [], [], []
Incident details in: /u01/app/oracle/diag/rdbms/stndcopy/STNDCOPY/incident/incdir_36153/STNDCOPY_ctwr_31324_i36153.trc
```


## Диагностика

Из инцидент-трейса видно, что экземпляр упал из-за проблем у процесса CTWR (Change Tracking Writer), который отвечает за работу block change tracking файла.

```
...
Instance name: STNDCOPY
Redo thread mounted by this instance: 1
Oracle process number: 19
Unix process pid: 31324, image: oracle@srv-test-ora05 (CTWR)
...

Dump continued from file: /u01/app/oracle/diag/rdbms/stndcopy/STNDCOPY/trace/STNDCOPY_ctwr_31324.trc
ORA-00600: internal error code, arguments: [krccacp_badfile], [10150310067047], [10150310065594], [], [], [], [], [], [], [], [], []
...
```


## Решение:

Забыл переименовать или отключить Block Change Tracking файл в скопированной БД. Произошёл конфликт процессов CTWR.
Отключение Block Change Tracking.

```
SQL> startup mount;

SQL> select filename from v$block_change_tracking;

SQL> alter database disable block change tracking;

Database altered.

SQL> select status from v$block_change_tracking;

STATUS
------------------------------
DISABLED

```

