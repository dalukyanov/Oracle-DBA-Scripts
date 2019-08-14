# Загрузка планов запросов из AWR в SQL Plan Baseline

1. Определение, какие планы существуют для запроса.

```sql
SELECT DISTINCT PLAN_HASH_VALUE,SQL_ID  FROM DBA_HIST_SQLSTAT
WHERE SQL_ID='43h973m25jv68';
```

2. Вывод различных статистик для планов выполнения.

```sql
SELECT SS.SNAP_ID,
     SS.INSTANCE_NUMBER,
     BEGIN_INTERVAL_TIME,
     SQL_ID,
     PLAN_HASH_VALUE,OPTIMIZER_COST,
     DISK_READS_TOTAL,
     BUFFER_GETS_TOTAL,
     ROWS_PROCESSED_TOTAL,
     CPU_TIME_TOTAL,
     ELAPSED_TIME_TOTAL,
     IOWAIT_TOTAL,
     NVL (EXECUTIONS_DELTA, 0) EXECS,
       (  ELAPSED_TIME_DELTA
        / DECODE (NVL (EXECUTIONS_DELTA, 0), 0, 1, EXECUTIONS_DELTA))
     / 1000000
        AVG_ETIME,
     (  BUFFER_GETS_DELTA
      / DECODE (NVL (BUFFER_GETS_DELTA, 0), 0, 1, EXECUTIONS_DELTA))
        AVG_LIO
FROM DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
WHERE     SQL_ID = '43h973m25jv68'
     AND SS.SNAP_ID = S.SNAP_ID
     AND SS.INSTANCE_NUMBER = S.INSTANCE_NUMBER
     AND EXECUTIONS_DELTA > 0
ORDER BY 1, 2, 3;
```

Пример группировки по CPU_TIME_TOTAL.

```sql
select round(plan_hash_value),avg(cpu_time_total) from (
SELECT SS.SNAP_ID,
     SS.INSTANCE_NUMBER,
     BEGIN_INTERVAL_TIME,
     SQL_ID,
     PLAN_HASH_VALUE,OPTIMIZER_COST,
     DISK_READS_TOTAL,
     BUFFER_GETS_TOTAL,
     ROWS_PROCESSED_TOTAL,
     CPU_TIME_TOTAL,
     ELAPSED_TIME_TOTAL,
     IOWAIT_TOTAL,
     NVL (EXECUTIONS_DELTA, 0) EXECS,
       (  ELAPSED_TIME_DELTA
        / DECODE (NVL (EXECUTIONS_DELTA, 0), 0, 1, EXECUTIONS_DELTA))
     / 1000000
        AVG_ETIME,
     (  BUFFER_GETS_DELTA
      / DECODE (NVL (BUFFER_GETS_DELTA, 0), 0, 1, EXECUTIONS_DELTA))
        AVG_LIO
FROM DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
WHERE     SQL_ID = '43h973m25jv68'
     AND SS.SNAP_ID = S.SNAP_ID
     AND SS.INSTANCE_NUMBER = S.INSTANCE_NUMBER
     AND EXECUTIONS_DELTA > 0
ORDER BY 1, 2, 3
) group by round(plan_hash_value)
order by 2;
```

3. Создание SQL Tuning Set для хранения планов данного запроса.

```sql
BEGIN
  DBMS_SQLTUNE.CREATE_SQLSET(
    sqlset_name => 'STS_43h973m25jv68',
    description => 'SQL Tuning Set for 43h973m25jv68');
END;
/
```

4. Загрузка планов запросов из AWR в SQL Tuning Set

```sql
DECLARE
  cur sys_refcursor;
BEGIN
  OPEN cur FOR
    SELECT VALUE(p)
    FROM TABLE(DBMS_SQLTUNE.SELECT_WORKLOAD_REPOSITORY(begin_snap=>7913, end_snap=>8113,basic_filter=>'sql_id = ''43h973m25jv68''',attribute_list=>'ALL')
              ) p;
     DBMS_SQLTUNE.LOAD_SQLSET( sqlset_name=> 'STS_43h973m25jv68', populate_cursor=>cur);
  CLOSE cur;
END;
/
```

5. Посмотреть загруженную информацию

```sql
SELECT
  first_load_time          ,
  executions as execs              ,
  parsing_schema_name      ,
  elapsed_time  / 1000000 as elapsed_time_secs  ,
  cpu_time / 1000000 as cpu_time_secs           ,
  buffer_gets              ,
  disk_reads               ,
  direct_writes            ,
  rows_processed           ,
  fetches                  ,
  optimizer_cost           ,
  sql_plan                ,
  plan_hash_value          ,
  sql_id                   ,
  sql_text
   FROM TABLE(DBMS_SQLTUNE.SELECT_SQLSET(sqlset_name => 'STS_43h973m25jv68')
             );
```

6. Загрузка планов из SQL Tuning Set в SQL Plan Baseline.

```sql
DECLARE
my_plans pls_integer;
BEGIN
  my_plans := DBMS_SPM.LOAD_PLANS_FROM_SQLSET(
    sqlset_name => 'STS_43h973m25jv68'
    );
END;
/
```
