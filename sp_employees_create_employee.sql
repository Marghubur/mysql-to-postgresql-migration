DROP PROCEDURE IF EXISTS public.sp_employees_create_employee(in varchar, in varchar, in varchar, in varchar, in int4, in int4, in int4, in int8, in int4, in timestamp, in int4, in int4, in int4, in int4, in int8, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_employees_create_employee(
    IN _firstname character varying, IN _lastname character varying, 
    IN _mobile character varying, IN _email character varying, 
    IN _leaveplanid integer, IN _payrollgroupid integer, 
    IN _salarygroupid integer, IN _reportingmanagerid bigint, 
    IN _designationid integer, IN _registrationdate timestamp without time zone, 
    IN _companyid integer, IN _noticeperiodid integer, 
    IN _workshiftid integer, IN _usertypeid integer, 
    IN _adminid bigint, OUT _processingresult character varying
)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;  -- FIXED: Changed TEXT to varchar
    _empid bigint;
BEGIN
    _empid := 0;
    if(_usertypeid = 0) then
        _usertypeid := 2;
    end if;

    _processingresult := '0';
    
    -- FIXED: Added coalesce to prevent null errors
    select coalesce(employeeuid, 0) from employees order by employeeuid desc limit 1 into _empid ;
    _empid := _empid + 1;
 
    _processingresult := _empid::varchar; 

    insert into employees (
        employeeuid, firstname, lastname, mobile, email, leaveplanid, payrollgroupid, 
        isactive, createdby, updatedby, createdon, updatedon, reportingmanagerid, 
        designationid, usertypeid, salarygroupid, companyid, noticeperiodid, workshiftid, projectid
    ) values (
        _empid, _firstname, _lastname, _mobile, _email, _leaveplanid, _payrollgroupid,
        true,   -- FIXED: Changed 1 to true
        _adminid, null, _registrationdate, null, _reportingmanagerid, _designationid,
        _usertypeid, _salarygroupid, _companyid, _noticeperiodid, _workshiftid, 0
    );
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    -- FIXED: Added ::varchar casts so the logger doesn't crash
    CALL sp_logexception(_message, ''::varchar, 'sp_employees_create_employee'::varchar, 1, 0, _result);
END;
$procedure$;
