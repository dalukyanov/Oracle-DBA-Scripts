# Dummy SBT Tape

В некоторых случаях бывает, что нет возможности подключиться к ленте (её больше нет, БД переехала в изолированный сегмент сети и т.д.), но остаются записи в контрольном файле о бэкапах. Для их удаления необходимо подключить псевдо MML-библиотеку oracle.disksbt.

```
RMAN> allocate channel for maintenance device type sbt parms 'SBT_LIBRARY=oracle.disksbt, ENV=(BACKUP_DIR=/tmp)';

using target database control file instead of recovery catalog
allocated channel: ORA_MAINT_SBT_TAPE_1
channel ORA_MAINT_SBT_TAPE_1: SID=2278 device type=SBT_TAPE
channel ORA_MAINT_SBT_TAPE_1: WARNING: Oracle Test Disk API
```

Удаляем необходимый бэкапсет.

```
RMAN> delete backupset 73753;


List of Backup Pieces
BP Key  BS Key  Pc# Cp# Status      Device Type Piece Name
------- ------- --- --- ----------- ----------- ----------
73761   73753   1   1   UNAVAILABLE SBT_TAPE    9tqlcmvi_1_1

Do you really want to delete the above objects (enter YES or NO)? yes
deleted backup piece
backup piece handle=9tqlcmvi_1_1 RECID=73761 STAMP=894852082
Deleted 1 objects
```

Его больше нет.

```
RMAN> list backupset 73753;

RMAN-00571: ===========================================================
RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
RMAN-00571: ===========================================================
RMAN-03002: failure of list command at 09/13/2016 13:25:05
RMAN-20215: backup set not found
RMAN-06159: error while looking up backup set
```