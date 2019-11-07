# Как включить и выключить EM Express 12c

## Проверить статус EM Express

```
select dbms_xdb.getHttpPort() from dual; 
select dbms_xdb_config.getHttpsPort() from dual;
```

## Включить EM Express через HTTPS

```
exec dbms_xdb_config.sethttpsport(5500);
```

## Включить EM Express через HTTP

```
exec dbms_xdb_config.sethttpport(8080);
```

## Отключение EM Express

Для отключения выставляем значение в 0.

```
exec dbms_xdb_config.sethttpsport(0); 
exec dbms_xdb_config.sethttpport(0);
```