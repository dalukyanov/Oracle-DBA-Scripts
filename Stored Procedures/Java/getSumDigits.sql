-- Пример хранимой функции на Java, возвращающей сумму всех цифр, встречающихся в передаваемой строке

CREATE OR REPLACE AND COMPILE JAVA SOURCE NAMED "getSumDigits" AS
public class SumDigits
{
    public static int getSumDigits(String arg)
    {
        char[] argArr = arg.toCharArray();
        int sum = 0;
        for(int i = 0; i < arg.length(); i++){
            try{
                if(Character.isDigit(argArr[i])) {
                    sum += Character.getNumericValue(argArr[i]);
                }
            }catch(Exception e){}
        }

        return sum;
    }
}
/


-- Создаём обёртку для функции с описанием входных и выходных значений.
-- На вход приходит VARCHAR2, на вход Java-функции передаст java.lang.String
-- На выходе имеем java.lang.Integer от Java, и возвращаем Number

CREATE OR REPLACE FUNCTION getSumDigits (text IN varchar2) RETURN Number
IS LANGUAGE JAVA
NAME 'SumDigits.getSumDigits(java.lang.String) return java.lang.Integer';
/


-- Пример использования

select GETSUMDIGITS('1a23bc45') as "Sum of digits" from dual;

-- Возвращает: 15
