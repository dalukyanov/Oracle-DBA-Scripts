# Пересоздание пользователя DBSNMP и роли OEM_MONITOR

## Проблема

Отсутствует пользователь DBSNMP в БД. Нет возможности добавить БД в мониторинг Cloud Control.

# Решение

Подключение / as sysdba

Удаление всего сущенствующего, что относится к данной схеме, если есть хвосты.

```
SQL> @?/rdbms/admin/catnsnmp.sql
```

Создание пользователя DBSNMP и роли OEM_MONITOR

```
SQL> @?/rdbms/admin/catsnmp.sql
```

Установка пароля для пользователя.
```
SQL> alter user dbsnmp identified by <password> account unlock;
```