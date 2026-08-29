-- DROP FUNCTION public.sp_employeelogin_auth(int8, varchar, varchar, int4, int4);

CREATE OR REPLACE FUNCTION public.sp_employeelogin_auth(_userid bigint, _mobileno character varying, _emailid character varying, _usertypeid integer, _pagesize integer)
 RETURNS SETOF employeelogin
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR;
    _accesslevelid bigint;
    _currentfinancialyear bigint;
    _routeprefix TEXT;
    _companyid bigint;
    _employeeid bigint;
BEGIN
    _routeprefix := 'bot/ems';
 _accesslevelid := 0;
 _companyid := 0;
 _employeeid := 0;
 
 if(_mobileno is not null and _mobileno != '') then
 begin
 select employeeid, accesslevelid, companyid from employeelogin
 where email = _emailid or mobile = _mobileno
 into _employeeid, _accesslevelid, _companyid;
 end;
 else
 begin
 select employeeid, accesslevelid, companyid from employeelogin
 where email = _emailid
 into _employeeid, _accesslevelid, _companyid;
 end;
 end if;
 
 
 
 
 
 
 
 
 
 
 
 
 _currentfinancialyear := 0;
 select financialyear into _currentfinancialyear from company_setting
 where isprimary;
 

 RETURN QUERY select
 e.employeeuid userid,
 e.firstname,
 e.lastname,
 'NA' address,
 e.email as emailid,
 e.mobile,
 e.reportingmanagerid,
 (
 select concat(firstname, ' ', lastname) from employees
 where 
 case
 when e.reportingmanagerid != 0 
 then employeeuid = e.reportingmanagerid
 else employeeuid = 1
 end
 ) managername,
 (
 select email from employees
 where 
 case
 when e.reportingmanagerid != 0 
 then employeeuid = e.reportingmanagerid
 else employeeuid = 1
 end
 ) manageremailid,
 e.designationid,
 _accesslevelid roleid,
 _usertypeid usertypeid,
 l.organizationid,
 l.companyid,
 (select employeecurrentregime from employee_declaration where employeeid = e.employeeuid and declarationfromyear = _currentfinancialyear) as employeecurrentregime,
 (select dob from employeepersonaldetail where employeeuid = e.employeeuid) as dob,
 e.updatedon,
 e.createdon,
 e.workshiftid
 from employees e
 inner join employeelogin l on l.employeeid = e.employeeuid
 where e.email = _emailid or e.mobile = _mobileno
 and e.isactive = true; 
 
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
    CALL sp_logexception(_message, '', 'sp_employeelogin_auth', 1, 0, _result);
END;
$function$
;
