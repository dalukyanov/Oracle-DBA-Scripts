# Загрузка планов запросов из AWR в SQL Plan Baseline

1. Определение, для каких запросов имеется статистика выполнения

```sql
SELECT DISTINCT PLAN_HASH_VALUE,SQL_ID  FROM DBA_HIST_SQLSTAT WHERE SQL_ID='43h973m25jv68';
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

begin_snap и end_snap можно взять из запроса:

```sql
select min(snap_id) "begin_snap", max(snap_id) "end_snap" from dba_hist_snapshot;
```

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

Также, как вариант, загрузить можно не из AWR, и из CURSOR_CACHE, если нас интересуют лишь те запросы, которые находятся там.

```sql
DECLARE
  cur sys_refcursor;
BEGIN
  OPEN cur FOR
    SELECT VALUE(p)
    FROM TABLE(DBMS_SQLTUNE.SELECT_CURSOR_CACHE(basic_filter=>'sql_id = ''43h973m25jv68''',attribute_list=>'ALL')
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

На данном этапе в SQL Tuning Set'е может находиться довольно много запросов. И, если загрузить все из них в качестве SQL Plan Baseline, то все автоматически получат статус Accepted. Я так и не нашёл способ, как на это повлиять.
Поэтому, грузим лишь тот план запроса, который выполняется в данный момент. Примем его за базовый (условно хороший, если хоть как-то выполняется). Для этого вычистим из STS все планы, кроме него.

```sql
BEGIN
  DBMS_SQLTUNE.DELETE_SQLSET (
      sqlset_name  => 'STS_43h973m25jv68'
,     basic_filter => 'plan_hash_value != 150806729'
);
END;
/
```

Можно проверить содержимое STS запросом выше.

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

7. Evolve Baseline

Если всё ок, один базовый план загружен, работает, и Oracle AUTO-CAPTURE нашёл и добавил ещё некоторые планы. Они будут не Accepted. Для их использования их необходимо верифицировать.
Проводим процедуру верификации так

```sql
SET LONG 100000
SELECT DBMS_SPM.evolve_sql_plan_baseline(sql_handle => 'SQL_a9fb2c232750c314') FROM dual;
```

Либо так

```sql
DECLARE
  res  varchar(32767);
BEGIN
  res := DBMS_SPM.evolve_sql_plan_baseline(sql_handle => 'SQL_a9fb2c232750c314');
  DBMS_OUTPUT.put_line('Evolved: ' || res);
END;
/
```

Если один из имеющихся планов имеет лучшую производительность, чем базовый план, он будет принят (Accepted), и начнёт использоваться в запросах.


**P.S.** Если что-то пошло не так

Посмотреть загруженную информацию по запросу можно:

```sql
select * from dba_sql_plan_baselines order by created desc;
```

Если уже знаем название плана, и надо узнать лишь SQL_HANDLE, то так:

```sql
select * from dba_sql_plan_baselines where plan_name = 'SQL_PLAN_amytc4cmp1hsn268d3985';
select * from dba_sql_plan_baselines where sql_handle = 'SQL_a9fb2c232750c314' order by accepted desc;
```

Удалить отдельный план из бейзлайна, либо весь бейзлайн:

```sql
SET SERVEROUTPUT ON
DECLARE
  l_plans_dropped  PLS_INTEGER;
BEGIN
  l_plans_dropped := DBMS_SPM.drop_sql_plan_baseline (
    sql_handle => 'SQL_a9fb2c232750c314',
    plan_name  => 'SQL_PLAN_amytc4cmp1hsn268d3985');
    
  DBMS_OUTPUT.put_line(l_plans_dropped);
END;
/
```

**P.P.S.** В случае, если требуется зафиксировать какой-то конкретный план:

```sql
SET SERVEROUTPUT ON
DECLARE
  l_plans_altered  PLS_INTEGER;
BEGIN
  l_plans_altered := DBMS_SPM.alter_sql_plan_baseline(
    sql_handle      => 'SQL_d4ab20f5c5a232b7',
    plan_name       => 'SQL_PLAN_d9at0yr2u4cpr217cac12',
    attribute_name  => 'fixed',
    attribute_value => 'YES');

  DBMS_OUTPUT.put_line('Plans Altered: ' || l_plans_altered);
END;
/
```