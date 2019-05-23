-- Пример хранимой функции на Java, возвращающей число уникальных символов в строке

CREATE OR REPLACE AND COMPILE JAVA SOURCE NAMED "getUniqueCount" AS
public class StringCounters
{
    
    public static int getUniqueCount( String arg )
    {
        java.util.ArrayList<Character> unique = new java.util.ArrayList<Character>();
        for( int i = 0; i < arg.length(); i++)
            if( !unique.contains( arg.charAt( i ) ) )
                unique.add( arg.charAt( i ) );
        
        return unique.size();
    }
}
/


-- Создаём обёртку для функции с описанием входных и выходных значений.
-- На вход приходит VARCHAR2, на вход Java-функции передаст java.lang.String
-- На выходе имеем java.lang.Integer от Java, и возвращаем Number

CREATE OR REPLACE FUNCTION getUniqueCount (text IN varchar2) RETURN Number
IS LANGUAGE JAVA
NAME 'StringCounters.getUniqueCount(java.lang.String) return java.lang.Integer';
/


-- Пример использования

select GETUNIQUECOUNT('aaabbbccc') from dual;

-- Возвращает: 3