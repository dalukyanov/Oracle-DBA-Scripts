select * from dba_users;
select * from dba_profiles;

begin
DBMS_RESOURCE_MANAGER.CLEAR_PENDING_AREA;
end;
/

begin
 dbms_resource_manager.create_pending_area();
end;
/

select * from dict where table_name like '%RSRC%';

select * from DBA_RSRC_PLANS order by plan;
select * from DBA_RSRC_CONSUMER_GROUPS order by consumer_group;

BEGIN
  DBMS_RESOURCE_MANAGER.clear_pending_area();
  DBMS_RESOURCE_MANAGER.create_pending_area();
END;
/

begin
 dbms_resource_manager.create_plan(
  plan => 'HPSM_DB_RSRC_PLAN',
  comment => 'Resource manager plan for users in HPSM database',
  mgmt_mth => 'EMPHASIS');
end;
/

BEGIN
  DBMS_RESOURCE_MANAGER.create_consumer_group(
    consumer_group => 'HPSM_CONSUMER_GROUP',
    comment        => 'Consumer group for HPSM');

  DBMS_RESOURCE_MANAGER.create_consumer_group(
    consumer_group => 'KPISPI_CONSUMER_GROUP',
    comment        => 'Consumer group for KPISPI');
END;
/

BEGIN
  DBMS_RESOURCE_MANAGER.create_plan_directive (
    plan                     => 'HPSM_DB_RSRC_PLAN',
    group_or_subplan         => 'HPSM_CONSUMER_GROUP',
    comment                  => 'High Priority',
    mgmt_p1                  => 100,
    mgmt_p2                  => 0,
    parallel_degree_limit_p1 => 4,
    utilization_limit        => 70);

  DBMS_RESOURCE_MANAGER.create_plan_directive (
    plan                     => 'HPSM_DB_RSRC_PLAN',
    group_or_subplan         => 'KPISPI_CONSUMER_GROUP',
    comment                  => 'Low Priority',
    mgmt_p1                  => 0,
    mgmt_p2                  => 100,
    parallel_degree_limit_p1 => 4,
    utilization_limit        => 20);

  DBMS_RESOURCE_MANAGER.create_plan_directive(
    plan                     => 'HPSM_DB_RSRC_PLAN',
    group_or_subplan         => 'OTHER_GROUPS',
    comment                  => 'all other users - level 3',
    mgmt_p1                  => 0,
    mgmt_p2                  => 0,
    mgmt_p3                  => 100,
    utilization_limit        => 10);
END;
/

BEGIN
  DBMS_RESOURCE_MANAGER.validate_pending_area;
  DBMS_RESOURCE_MANAGER.submit_pending_area();
END;
/


BEGIN
  -- Assign users to consumer groups
  DBMS_RESOURCE_MANAGER_PRIVS.grant_switch_consumer_group(
    grantee_name   => 'HPSM',
    consumer_group => 'HPSM_CONSUMER_GROUP',
    grant_option   => FALSE);

  DBMS_RESOURCE_MANAGER_PRIVS.grant_switch_consumer_group(
    grantee_name   => 'KPISPI',
    consumer_group => 'KPISPI_CONSUMER_GROUP',
    grant_option   => FALSE);

  DBMS_RESOURCE_MANAGER.set_initial_consumer_group('HPSM', 'HPSM_CONSUMER_GROUP');

  DBMS_RESOURCE_MANAGER.set_initial_consumer_group('KPISPI', 'KPISPI_CONSUMER_GROUP');
END;
/

commit;

ALTER SYSTEM SET RESOURCE_MANAGER_PLAN = 'HPSM_DB_RSRC_PLAN' scope=both;