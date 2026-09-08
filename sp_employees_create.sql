CREATE OR REPLACE PROCEDURE public.sp_employees_create(
    IN _employeeuid bigint, IN _firstname character varying, IN _lastname character varying, 
    IN _mobile character varying, IN _email character varying, IN _leaveplanid integer, 
    IN _payrollgroupid integer, IN _salarygroupid integer, IN _reportingmanagerid bigint, 
    IN _designationid integer, IN _registrationdate timestamp without time zone, 
    IN _companyid integer, IN _noticeperiodid integer, IN _workshiftid integer, 
    IN _usertypeid integer, IN _adminid bigint, 
    IN _isemployeeeligibleforpf boolean,      -- FIXED: Changed from bit to boolean
    IN _isexistingmemberofpf boolean,         -- FIXED: Changed from bit to boolean
    IN _pfnumber character varying, 
    IN _universalaccountnumber character varying, IN _esiserialnumber character varying, 
    IN _isemployeeeligibleforesi boolean,     -- FIXED: Changed from bit to boolean
    IN _pfjoindate timestamp without time zone, 
    OUT _processingresult character varying
)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _empid bigint;
    _employeepfdetailid bigint;
BEGIN
    _empid := 0;
    if(_usertypeid = 0) then
        _usertypeid := 2;
    end if;

    _processingresult := '0';
    
    if (_employeeuid = 0) then
        select coalesce(employeeuid, 0) from employees order by employeeuid desc limit 1 into _empid ;
        _empid := _empid + 1;
    else
        _empid := _employeeuid;
    end if;
 
    _processingresult := _empid::varchar; 
    
    insert into employees (
        employeeuid, firstname, lastname, mobile, email, isactive, 
        createdby, updatedby, createdon, updatedon, reportingmanagerid, designationid, 
        usertypeid, leaveplanid, companyid, payrollgroupid, salarygroupid, noticeperiodid, 
        workshiftid, projectid
    ) values (
        _empid, _firstname, _lastname, _mobile, _email, true, 
        _adminid, null, _registrationdate, null, _reportingmanagerid, _designationid,
        _usertypeid, _leaveplanid, _companyid, _payrollgroupid, _salarygroupid, _noticeperiodid,
        _workshiftid, 0
    );
 
    _employeepfdetailid := 0;
    select coalesce(employeepfdetailid, 0) into _employeepfdetailid from employee_pf_detail 
    order by employeepfdetailid desc limit 1;
    _employeepfdetailid := _employeepfdetailid + 1;

    insert into employee_pf_detail values(
        _employeepfdetailid, _empid, _isemployeeeligibleforpf, _isexistingmemberofpf,
        _pfnumber, _universalaccountnumber, _esiserialnumber, _isemployeeeligibleforesi,
        _pfjoindate, true
    );
END;
$procedure$;
