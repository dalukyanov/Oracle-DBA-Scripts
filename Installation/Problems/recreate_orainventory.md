# Пересоздание orainventory

## Проблема

По каким-либо причинам побилось/удалилось инвентори

## Решение

> Можно делать в онлайне

1. Создать новую папку /opt/oraInventory с правами 755 и oracle:oinstall
2. В /etc/oraInst.loc прописать путь к ней.
3. Выставляем окружение под нужный хомяк через oraenv или по другому
4. Аттачим Oracle Home
```
cd $ORACLE_HOME/oui/bin
./runInstaller -silent -ignoreSysPrereqs -attachHome ORACLE_HOME="/opt/oracle/product/db_19" ORACLE_HOME_NAME="Oracle19c_home"
```

Шаги 3-4 повторить для каждого хомяка