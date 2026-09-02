CREATE OR REPLACE FUNCTION public.sp_discover_workflow_detail(
  IN _employeeid bigint,
  IN _approvalworkflowid integer,
  IN _projectid integer
)
RETURNS SETOF "project_members_detail"
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _team TEXT;
BEGIN
  _team := '';
 select team into _team from project_members_detail p
 where p.employeeid = _employeeid
 and p.projectid = _projectid;
 RETURN QUERY select 
 t.employeeid, 
 t.designationid,
 t.fullname,
 t.email,
 t.team
 from approval_work_flow w
 inner join approval_chain_detail c on w.approvalworkflowid = c.approvalworkflowid
 inner join project_members_detail t on t.designationid = c.assignieid
 where w.approvalworkflowid = _approvalworkflowid 
 and c.empordesignation = 0 
 and t.projectid = _projectid
 and t.isactive = true
 and t.team = _team
 union
 select 
 tm.employeeid, 
 tm.designationid,
 tm.fullname,
 tm.email,
 tm.team
 from approval_work_flow w
 inner join approval_chain_detail c on w.approvalworkflowid = c.approvalworkflowid
 inner join project_members_detail tm on tm.employeeid = c.assignieid
 where w.approvalworkflowid = _approvalworkflowid 
 and c.empordesignation = true
 and tm.projectid = _projectid
 and tm.isactive = true
 and tm.team = _team;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_discover_workflow_detail', 1::bit, 0::bit, _result);
END;
$$;
