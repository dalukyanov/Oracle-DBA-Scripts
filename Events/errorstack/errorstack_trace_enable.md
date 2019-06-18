# Включение errorstack-трассировки на уровне БД

```
alter system set events '1013 trace name errorstack level 3';
```

Выключить можно, поставив уровень 0.

```
alter system set events '1013 trace name errorstack level 0';
```