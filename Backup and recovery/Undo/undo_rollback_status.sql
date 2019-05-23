col "Estimated time to complete" format a40
set linesize 100 
alter session set NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'; 
select usn, state, undoblockstotal "Total", undoblocksdone "Done", undoblockstotal-undoblocksdone "ToDo",
       decode(cputime,0,'unknown',sysdate+(((undoblockstotal-undoblocksdone) / (undoblocksdone / cputime)) / 86400)) "Estimated time to complete" 
from v$fast_start_transactions; 