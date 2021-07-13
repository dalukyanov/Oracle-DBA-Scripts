# Копирование плана запроса из одного sql_id в другой sql_id

Такой подход может быть полезен, если у одного запроса план плохой, но у такого же, но отличающегося в незначительных деталях, хороший.
Таким образом можно создать также новый план на основе Bind-переменных.

1. Находим необходимый sql_id

```sql
select sql_id, sql_text, plan_hash_value 
  from v$sql 
 where sql_text like '%I_DIR1%' 
 order by last_active_time;
```

Его также можно найти в AWR отчёте, OEM и в прочих местах

2. Загрузка плана настроенного запроса

```sql
declare
  l_sql_id_src varchar2(13)    :='4wu5ab1df1cak';   -- sql_id с хорошим планом. Тот, что хотим закрепить
  l_plan_hash_value_src number := 1357081020;       -- plan_hash_value тот самый хороший план
  l_sql_id_trg  varchar2(13)   :='ck30v97vj5n5z';   -- sql_id с плохим планом, куда мы хотим прикрепить хороший
  l_sql_text_trg clob;  
  l_res number;  
begin
  -- текст запроса для настройки
  select a.sql_fulltext into l_sql_text_trg
    from v$sqlarea a 
   where a.sql_id = l_sql_id_trg;
  -- загрузка плана и создание SQL plan baseline
  l_res := dbms_spm.load_plans_from_cursor_cache( 
              sql_id => l_sql_id_src, 
              plan_hash_value => l_plan_hash_value_src, 
              sql_text => l_sql_text_trg);
  dbms_output.put_line(l_res);  
end; 
/
```

План загружается в SQL Plan Baseline.
Посмотреть созданный бейзлайн можно так:

```sql
select * from dba_sql_plan_baselines order by created desc;
```

