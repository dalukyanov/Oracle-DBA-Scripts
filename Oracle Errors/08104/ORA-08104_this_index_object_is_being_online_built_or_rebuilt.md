# ORA-08104: this index object 3732956 is being online built or rebuilt

# Версия

```
Oracle 11.2.0.4
AIX 7.1
```

# Проблема

При перестроении индекса с опцией online сессия зависла и была убита через alter system kill session.
Далее при попытке удалить данный индекс возникает ошибка:

```
drop index SOME_INDEX;
ORA-08104: this index object 3732956 is being online built or rebuilt
```

# Решение

Мы можем избавиться от мусора следующей процедурой.

```
declare
lv_ret BOOLEAN;
begin
lv_ret := dbms_repair.online_index_clean(3732956);
end;
/
```