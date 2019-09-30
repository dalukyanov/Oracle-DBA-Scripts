# Ошибки ORA-07445: exception encountered: core dump [kestsaProcOldPlansTopSql()+481] [SIGSEGV] [ADDR:0x0] [PC:0x9879F21] [Address not mapped to object] []

## Версия

```
19.4.0.0.0
SUSE Linux Enterprise Server 12 (x86_64)
VERSION = 12
PATCHLEVEL = 3
```

## Изменения

Проблема обнаружена после апгрейда БД с 18 до 19 версии.

## Диагностика

В алерт-логе БД имеем:

```
2019-09-29T22:04:52.957867+03:00
Exception [type: SIGSEGV, Address not mapped to object] [ADDR:0x0] [PC:0x9879F21, kestsaProcOldPlansTopSql()+481] [flags: 0x0, count: 1]
Errors in file /u01/oracle/app/diag/rdbms/oemdb/OEMDB/trace/OEMDB_j004_2268.trc  (incident=245683) (PDBNAME=CDB$ROOT):
ORA-07445: exception encountered: core dump [kestsaProcOldPlansTopSql()+481] [SIGSEGV] [ADDR:0x0] [PC:0x9879F21] [Address not mapped to object] []
Incident details in: /u01/oracle/app/diag/rdbms/oemdb/OEMDB/incident/incdir_245683/OEMDB_j004_2268_i245683.trc
```

В /u01/oracle/app/diag/rdbms/oemdb/OEMDB/incident/incdir_245683/OEMDB_j004_2268_i245683.trc:

```
...
*** 2019-09-29T22:04:53.184000+03:00
*** SESSION ID:(2298.63646) 2019-09-29T22:04:53.184030+03:00
*** CLIENT ID:() 2019-09-29T22:04:53.184038+03:00
*** SERVICE NAME:(SYS$USERS) 2019-09-29T22:04:53.184046+03:00
*** MODULE NAME:(DBMS_SCHEDULER) 2019-09-29T22:04:53.184053+03:00
*** ACTION NAME:(ORA$AT_SQ_SQL_SW_32182) 2019-09-29T22:04:53.184060+03:00
*** CLIENT DRIVER:() 2019-09-29T22:04:53.184068+03:00
*** CONTAINER ID:(1) 2019-09-29T22:04:53.184075+03:00

[TOC00000]
Jump to table of contents
Dump continued from file: /u01/oracle/app/diag/rdbms/oemdb/OEMDB/trace/OEMDB_j004_2268.trc
[TOC00001]
ORA-07445: exception encountered: core dump [kestsaProcOldPlansTopSql()+481] [SIGSEGV] [ADDR:0x0] [PC:0x9879F21] [Address not mapped to object] []

[TOC00001-END]

[TOC00002]
========= Dump for incident 245683 (ORA 7445 [kestsaProcOldPlansTopSql]) ========
[TOC00003]
----- Beginning of Customized Incident Dump(s) -----
Dumping swap information
Memory (Avail / Total) = 214.50M / 24003.48M
Swap (Avail / Total) = 14884.68M /  16384.00M
Exception [type: SIGSEGV, Address not mapped to object] [ADDR:0x0] [PC:0x9879F21, kestsaProcOldPlansTopSql()+481] [flags: 0x0, count: 1]
Registers:
%rax: 0x0000000000000000 %rbx: 0x00007fff9295a960 %rcx: 0x000000000000f89e
%rdx: 0x0000000000000009 %rdi: 0x00007fff9295c8e0 %rsi: 0x00007fff92958798
%rsp: 0x00007fff92958080 %rbp: 0x00007fff929582c0  %r8: 0x0000000000000000
 %r9: 0x00007fff929581e8 %r10: 0x00007fff92958b88 %r11: 0x000236b49017e06c
%r12: 0x00007fff9295ce00 %r13: 0x00007fff92958798 %r14: 0x0000000000000000
%r15: 0x00007fff9295c8e0 %rip: 0x0000000009879f21 %efl: 0x0000000000010203
  kestsaProcOldPlansTopSql()+466 (0x9879f12) mov 0x18(%rbp),%r10
  kestsaProcOldPlansTopSql()+470 (0x9879f16) mov %r15,%rdi
  kestsaProcOldPlansTopSql()+473 (0x9879f19) mov %r13,%rsi
  kestsaProcOldPlansTopSql()+476 (0x9879f1c) mov $0x9,%edx
> kestsaProcOldPlansTopSql()+481 (0x9879f21) mov (%rax),%r11
  kestsaProcOldPlansTopSql()+484 (0x9879f24) lea -0x38(%rbp),%r9
  kestsaProcOldPlansTopSql()+488 (0x9879f28) mov 0x34(%r12),%ecx
  kestsaProcOldPlansTopSql()+493 (0x9879f2d) mov %r10,(%rsp)
  kestsaProcOldPlansTopSql()+497 (0x9879f31) mov 0x108(%r11),%r8

*** 2019-09-29T22:04:53.203663+03:00
dbkedDefDump(): Starting a non-incident diagnostic dump (flags=0x3, level=3, mask=0x0)
[TOC00004]
----- Current SQL Statement for this session (sql_id=4xm1ruvkx3awx) -----
DECLARE job BINARY_INTEGER := :job;  next_date TIMESTAMP WITH TIME ZONE := :mydate;  broken BOOLEAN := FALSE;  job_name VARCHAR2(128) := :job_name;  job_subname VARCHAR2(128) := :job_subname;  job_owner VARCHAR2(128) := :job_owner;  job_start TIMESTAMP WITH TIME ZONE := :job_start;  job_scheduled_start TIMESTAMP WITH TIME ZONE := :job_scheduled_start;  window_start TIMESTAMP WITH TIME ZONE := :window_start;  window_end TIMESTAMP WITH TIME ZONE := :window_end;  chain_id VARCHAR2(14) :=  :chainid;  credential_owner VARCHAR2(128) := :credown;  credential_name  VARCHAR2(128) := :crednam;  destination_owner VARCHAR2(128) := :destown;  destination_name VARCHAR2(128) := :destnam;  job_dest_id varchar2(14) := :jdestid;  log_id number := :log_id;  BEGIN  DECLARE
         ename             VARCHAR2(30);
         exec_task         BOOLEAN;
       BEGIN
         -- check if tuning pack is enabled
         exec_task := prvt_advisor.is_pack_enabled(
                        dbms_management_packs.TUNING_PACK);
         -- check if we are in a pdb,
         -- since auto sqltune is not run in a pdb
         IF (exec_task AND -- tuning pack enabled
         sys_context('userenv', 'con_id') <> 0 AND -- not in non-cdb
         sys_context('userenv', 'con_id') <> 1  ) THEN -- not in root
           exec_task := FALSE;
         END IF;
         -- execute auto sql tuning task
         IF (exec_task) THEN
           ename := dbms_sqltune.execute_tuning_task(
                      'SYS_AUTO_SQL_TUNING_TASK');
         END IF;
         -- check whether we are in non-CDB or a PDB
         -- auto SPM evolve only runs in a non-CDB or a PDB, not the root.
         IF (sys_context('userenv', 'con_id') = 0 OR
             sys_context('userenv', 'con_id') > 2) THEN
           exec_task := TRUE;
         ELSE
           exec_task := FALSE;
         END IF;
         -- execute auto SPM evolve task
         IF (exec_task) THEN
           ename := dbms_spm.execute_evolve_task('SYS_AUTO_SPM_EVOLVE_TASK');
         END IF;
       END;  :mydate := next_date; IF broken THEN :b := 1; ELSE :b := 0; END IF; END;
[TOC00005]
----- PL/SQL Stack -----
----- PL/SQL Call Stack -----
  object      line  object
  handle    number  name
0x6b3e91f8     14140  package body SYS.DBMS_SQLTUNE_INTERNAL.I_SUB_EXECUTE_CALLOUT
0x6b3e91f8     14167  package body SYS.DBMS_SQLTUNE_INTERNAL.I_SUB_EXECUTE
0xc4d572e0         8  type body SYS.WRI$_ADV_SQLTUNE.SUB_EXECUTE
0x7136fdd8       915  package body SYS.PRVT_ADVISOR.COMMON_SUB_EXECUTE
0x7136fdd8      3451  package body SYS.PRVT_ADVISOR.COMMON_EXECUTE_TASK
0x6b44bb38       276  package body SYS.DBMS_ADVISOR.EXECUTE_TASK
0x6b3b22e8      1217  package body SYS.DBMS_SQLTUNE.EXECUTE_TUNING_TASK
0xcec99b50        19  anonymous block
[TOC00005-END]
[TOC00004-END]
...
```

Ошибка не информативна.
```
> kestsaProcOldPlansTopSql()+481 (0x9879f21) mov (%rax),%r11 
```

Произошло обращение к области памяти, расположенной по адресу, который прописан в регистре RAX. При  этом в регистре RAX нули.
```
%rax: 0x0000000000000000
```

Вызвало "Address not mapped to object".

Видно, что выполняются регламентные внутренние процедуры DBMS_SQLTUNE, DBMS_ADVISOR. Насколько я понимаю, это всё часть джобов ADDM. Ошибки возникают раз в четыре часа.

## Решение:

Не уверень, что все из указанных действий необходимы, но что-то из этого решило проблему.

1. Согласно How To Reload the SYS.DBMS_STATS Package (Doc ID 1310365.1) перестроил пакет SYS.DBMS_STATS

Советую сразу записать инвалиды, если есть. У меня по нулям.

```
select object_name from dba_objects where status='INVALID';
```

Перестраиваем пакет SYS.DBMS_STATS

```
@?/rdbms/admin/dbmsstat.sql
@?/rdbms/admin/prvtstas.plb
@?/rdbms/admin/prvtstai.plb
@?/rdbms/admin/prvtstat.plb
```

Не забываем перестроить инвалидные объекты. Их много.

```
select object_name from dba_objects where status='INVALID';

@?/rdbms/admin/utlrp.sql
```

2. Перестроил системную статистику.

```
exec dbms_stats.gather_fixed_objects_stats;
exec dbms_stats.gather_schema_stats ('SYS');
exec dbms_stats.gather_schema_stats ('SYSTEM');
exec dbms_stats.gather_dictionary_stats;

alter system flush shared_pool;
alter system flush shared_pool;
alter system flush shared_pool;
```

Больше проблема не повторяется.
