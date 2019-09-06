# Oracle XML. Extract value from CLOB column.

Имеем некоторый XML документ в поле CLOB в таблице. Пример:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<ns2:attachmentEvent xmlns:ns2="http://some.addr.com/cont/event/type/attachment/" xmlns:ns3="http://some.addr.com/cont/event/type/subscribe/">
    <event>
        <id>ce3ea3c3-3fdf-4641-98c5-d90ff534256b</id>
        <type>12345</type>
        <time>2019-06-10T15:51:13.183+03:00</time>
        <system>ContAtt</system>
    </event>
    <pat>
        <id>6840159228036</id>
        <phone>1234567890</phone>
        <email>1234567890@somedomain.com</email>
    </pat>
    <attachment>
        <id>17341657178036</id>
        <arMainMeSpeciality>Специальность</arMainMeSpeciality>
    </attachment>
</ns2:attachmentEvent>
```

Необходимо достать из него pat/id

```
with mytest as (
select XMLType(message) as xml from lukyanov.ESU_OUTPUT
)
select t.xml.extract('//pat/id/text()').getStringVal() from
mytest t;
```

Если нужно встроить обращение к полю в условие запроса, то так:

```
select * from lukyanov.ESU_OUTPUT where XMLType(message).extract('//pat/id/text()').getStringVal() in (6840159228036);
```

Для ускорения выполнения запроса можно создать функциональный индекс на поле.

```
drop index lukyanov.FUN_ESU_OUTPUT;
create index lukyanov.FUN_ESU_OUTPUT on lukyanov.ESU_OUTPUT(to_number(XMLType(message).extract('//pat/id/text()').getStringVal()));
```