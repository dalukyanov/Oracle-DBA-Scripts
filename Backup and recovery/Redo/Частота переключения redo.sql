-- Частота переключения Redo-логов

  SELECT TRUNC (first_time) "дата",
         TO_CHAR (first_time, 'Dy', 'NLS_DATE_LANGUAGE = RUSSIAN') "день",
         COUNT (1) "общее",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '00', 1, 0)) "час 00",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '01', 1, 0)) "час 01",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '02', 1, 0)) "час 02",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '03', 1, 0)) "час 03",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '04', 1, 0)) "час 04",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '05', 1, 0)) "час 05",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '06', 1, 0)) "час 06",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '07', 1, 0)) "час 07",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '08', 1, 0)) "час 08",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '09', 1, 0)) "час 09",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '10', 1, 0)) "час 10",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '11', 1, 0)) "час 11",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '12', 1, 0)) "час 12",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '13', 1, 0)) "час 13",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '14', 1, 0)) "час 14",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '15', 1, 0)) "час 15",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '16', 1, 0)) "час 16",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '17', 1, 0)) "час 17",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '18', 1, 0)) "час 18",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '19', 1, 0)) "час 19",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '20', 1, 0)) "час 20",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '21', 1, 0)) "час 21",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '22', 1, 0)) "час 22",
         SUM (DECODE (TO_CHAR (first_time, 'hh24'), '23', 1, 0)) "час 23",
         DECODE (
            TRUNC (first_time),
            TRUNC (SYSDATE), ROUND (
                                  COUNT (1)
                                / (  24
                                   * TO_NUMBER (TO_CHAR (SYSDATE, 'sssss') + 1)
                                   / 86400),
                                2),
            ROUND (COUNT (1) / 24, 2))
            "среднее"
    FROM v$log_history
GROUP BY TRUNC (first_time), TO_CHAR (first_time, 'Dy', 'NLS_DATE_LANGUAGE = RUSSIAN')
ORDER BY 1 DESC;