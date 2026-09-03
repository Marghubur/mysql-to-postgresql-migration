CREATE OR REPLACE PROCEDURE public.sp_employee_deactivate(
    IN _employeeid bigint, 
    IN _fullname character varying, 
    IN _mobile character varying, 
    IN _email character varying, 
    IN _package numeric, 
    IN _dateofjoining timestamp without time zone, 
    IN _dateofleaving timestamp without time zone, 
    IN _employeecompletedetailmodal jsonb, 
    IN _adminid bigint, 
    OUT _processingresult character varying
)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;
    _empid bigint;
BEGIN
    -- FIXED: Use MAX() with COALESCE so it safely defaults to 0 if employee_archive is empty
    SELECT COALESCE(MAX(employeeid), 0) INTO _empid 
    FROM employee_archive;
    
    _empid := _empid + 1;
    
    INSERT INTO employee_archive VALUES (
        _empid,
        _fullname,
        _mobile,
        _email,
        _package,
        _dateofjoining,
        _dateofleaving,
        _employeecompletedetailmodal,
        _adminid,
        timezone('utc', now())
    );
    
    DELETE FROM employeepersonaldetail WHERE employeeuid = _employeeid;
    DELETE FROM employeeprofessiondetail WHERE employeeuid = _employeeid;
    DELETE FROM employeelogin WHERE employeeid = _employeeid;
    DELETE FROM employee_declaration WHERE employeeid = _employeeid;
    DELETE FROM employee_leave_request WHERE employeeid = _employeeid;
    DELETE FROM employee_notice_period WHERE employeeid = _employeeid;
    DELETE FROM employee_salary_detail WHERE employeeid = _employeeid;
    DELETE FROM employee_timesheet WHERE employeeid = _employeeid;
    DELETE FROM employeemappedclients WHERE employeeuid = _employeeid;
    DELETE FROM employees WHERE employeeuid = _employeeid;
    
    _processingresult := 'updated';
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_deactivate'::varchar, 1, 0, _result);
    _processingresult := _message;
END;
$procedure$;
