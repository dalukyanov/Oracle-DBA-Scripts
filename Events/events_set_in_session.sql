-- Нужны права на SYS.DBMS_SYSTEM
set serveroutput on
declare
  event_level number;
  counter     number;
begin
  dbms_output.enable;
  counter := 0;
  for i in 10000 .. 10999 loop
    sys.dbms_system.read_ev(i, event_level); -- начиная с Oracle 11g показывает только цифровые события, соответствующие кодам ORA-10NNN
    if (event_level > 0) then
      dbms_output.put_line('Event ' || to_char(i) || ' set at level ' || to_char(event_level));
      counter := counter + 1;
    end if;
  end loop;
  if (counter = 0) then
    dbms_output.put_line('No events set for this session');
  end if;
end;
/