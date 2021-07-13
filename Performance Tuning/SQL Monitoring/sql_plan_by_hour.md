# Планы выполнения запросов по часам

В действительности по AWR-снапшотам. Могут быть чаще, чем раз в час.

```sql
SELECT instance_number AS inst
      , ( snap_id - 1 ) AS begin_snap_id
      ,TO_CHAR (sn.begin_interval_time,'dd.mm hh24:mi') AS begin_snap_time
      ,TO_CHAR (sn.end_interval_time,'dd.mm hh24:mi') AS end_snap_time
      ,round (st.executions_delta) AS execs
      ,trunc (st.executions_delta / 3600,1) AS execs_per_sec
      ,st.sql_id
      ,st.plan_hash_value AS plan
      ,st.optimizer_cost AS cost
      ,round (st.parse_calls_delta / DECODE (st.executions_delta,0,1,st.executions_delta),3) AS parse_per_exec
      ,round (st.elapsed_time_delta / DECODE (st.executions_delta,0,1,st.executions_delta) ) AS ela_per_exec_micro
      ,round (st.cpu_time_delta / DECODE (st.executions_delta,0,1,st.executions_delta) ) AS cpu_per_exec
      ,round (st.buffer_gets_delta / DECODE (st.executions_delta,0,1,st.executions_delta) ) AS gets_per_exec
      ,round (st.physical_read_bytes_delta / DECODE (st.executions_delta,0,1,st.executions_delta) / 1024 / 1024) AS read_mb_per_exec
      ,round (st.physical_read_requests_delta / DECODE (st.executions_delta,0,1,st.executions_delta) ) AS reads_per_exec
      ,round (st.physical_write_bytes_delta / DECODE (st.executions_delta,0,1,st.executions_delta) / 1024 / 1024) AS writes_mb_per_exec
      ,round (st.physical_write_requests_delta / DECODE (st.executions_delta,0,1,st.executions_delta) ) AS writes_per_exec
      ,round (st.direct_writes_delta / DECODE (st.executions_delta,0,1,st.executions_delta) ) AS direct_writes_per_exec
      ,round (st.rows_processed_delta / DECODE (st.executions_delta,0,1,st.executions_delta) ) AS rows_per_exec
      ,round (st.fetches_delta / DECODE (st.executions_delta,0,1,st.executions_delta) ) AS fetches_per_exec
      ,round (st.iowait_delta / DECODE (st.executions_delta,0,1,st.executions_delta) ) AS iowaits_per_exec
      ,round (st.clwait_delta / DECODE (st.executions_delta,0,1,st.executions_delta) ) AS clwaits_per_exec
      ,round (st.apwait_delta / DECODE (st.executions_delta,0,1,st.executions_delta) ) AS apwaits_per_exec
      ,round (st.ccwait_delta / DECODE (st.executions_delta,0,1,st.executions_delta) ) AS ccwaits_per_exec
      ,round (st.parse_calls_delta / DECODE (st.executions_delta,0,1,st.executions_delta) ) AS parse_per_exec
      ,round (st.plsexec_time_delta / DECODE (st.executions_delta,0,1,st.executions_delta) ) AS plsql_per_exec
      ,round (st.px_servers_execs_delta / DECODE (st.executions_delta,0,1,st.executions_delta) ) AS px_per_exec
FROM dba_hist_sqlstat st
JOIN dba_hist_snapshot sn
USING ( snap_id
,instance_number )
WHERE sql_id = '0kt89qhr8k31b' AND sn.begin_interval_time > SYSDATE - 7
ORDER BY snap_id DESC        
,instance_number;
```