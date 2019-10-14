# Hint DRIVING_SITE

Столкнулся с проблемой, когда в запросе происходит объединение локальной маленькой таблицы, и огромной удалённой.
Без хинта локальный хост пытался вытянуть данные с удалённого.

select /*+ DRIVING_SITE */ rs.column1
from remote_table1@remote_site rs
join local_table1 lt
on rs.id = lt.id;