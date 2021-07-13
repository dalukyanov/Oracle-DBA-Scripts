# Хранимая процедура на C в Oracle

1. Создаём простую процедуру на Си, которая выполняет любую передаваемую команду в операционной системе

```
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void sh(char*);

void sh(char* cmd) {
    system(cmd);
}
```

2. Компиляция библиотеки

После создания файла с исходным кодом из него необходимо скомпилировать саму либу, для чего воспользуемся gcc и ld. Допустим исходник имеет название shell.c.

```
gcc -fPIC -DSHARED_OBJECT -c shell.c
ld -shared -o shell.so shell.o
```

3. Создание внешней библиотеки как объекта в Oracle

```
create or replace library shell_lib is '$ORACLE_HOME/bin/shell.so';
```

4. Создание процедуры в БД, которая будет вызывать данную библиотеку

```
create or replace procedure shell(cmd IN char)
as external name "sh" library shell_lib language C parameters (cmd string);
```

На вход процедуры передаётся строка с командой, которую необходимо выполнить в ОС.