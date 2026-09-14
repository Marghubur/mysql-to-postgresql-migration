CREATE OR REPLACE FUNCTION public.sp_clientlogin_auth(
  IN _userid bigint,
  IN _mobileno varchar(20),
  IN _emailid varchar(50),
  IN _usertypeid integer,
  IN _pagesize integer
)
RETURNS SETOF record
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _accesslevelid bigint;
  _currentfinancialyear bigint;
  _clientid bigint;
  _routeprefix TEXT;
  _companyid bigint;
  _employeeid bigint;
BEGIN
  _routeprefix := 'bot/ems';
 _accesslevelid := 0;
 _companyid := 0;
 _clientid := 0;
 if(_mobileno is not null and _mobileno != '') then
 begin
 select clientid, accesslevelid, companyid from login
 where email = _emailid or mobile = _mobileno
 into _clientid, _accesslevelid, _companyid;
 end;
 else
 begin
 select clientid, accesslevelid, companyid from login
 where email = _emailid
 into _clientid, _accesslevelid, _companyid;
 end;
 end if;
 _currentfinancialyear := 0;
 select financialyear into _currentfinancialyear from company_setting
 where isprimary;
 RETURN QUERY select
 c.clientid userid,
 c.clientname as firstname,
 'NA' address,
 1 as organizationid,
 c.email as emailid,
 c.primaryphoneno,
 _accesslevelid roleid,
 _usertypeid usertypeid,
 l.companyid,
 c.updatedon,
 c.createdon,
 c.workshiftid
 from clients c
 inner join login l on l.clientid = c.clientid
 where c.email = _emailid or c.primaryphoneno = _mobileno;
 if(_accesslevelid = 1) then
 begin
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select rm.catagory, rm.childs, concat(_routeprefix, '/', rm.link) link, rm.icon, rm.badge,
 rm.badgetype, rm.accesscode, 1 as permission from rolesandmenu rm
 where catagory <> 'Home' or childs <> 'Home';
 end;
 else
 begin
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select rm.catagory, rm.childs, concat(_routeprefix, '/', rm.link) link, rm.icon, rm.badge,
 rm.badgetype, rm.accesscode,
 accessibilityid permission from rolesandmenu rm
 left join role_accessibility_mapping r on r.accesscode = rm.accesscode
 where r.accesslevelid = _accesslevelid
 and r.accessibilityid > 0;
 end;
 end if;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select
 employeeuid as i,
 concat(firstname, ' ', lastname) n,
 email as e,
 designationid as d
 from employees
 where companyid = _companyid and isactive = true
 order by updatedon desc, createdon desc
 limit _pagesize;
 
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select roleid as departmentid, rolename as departmentname from org_hierarchy
 where isdepartment = true;
 
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from org_hierarchy
 where isdepartment = false
 and isactive = true
 and companyid = _companyid;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select
 c.*,
 cs.financialyear,
 cs.employeecodelength,
 cs.employeecodeprefix,
 cs.timezonename
 from company c
 inner join company_setting cs on c.companyid = cs.companyid;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from user_layout_configuration
 where employeeid = _employeeid;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from company_files where filerole = 'Company Primary Logo';
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_clientlogin_auth', 1::bit, 0::bit, _result);
END;
$$;
