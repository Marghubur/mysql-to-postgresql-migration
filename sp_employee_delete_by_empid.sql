-- DROP PROCEDURE public.sp_employee_delete_by_empid(int8);

CREATE OR REPLACE PROCEDURE public.sp_employee_delete_by_empid(IN _employeeid bigint)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result TEXT;
BEGIN
    delete from employee_pf_detail where employeeid = _employeeid;
 delete from employees where employeeuid = _employeeid;
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    CALL sp_logexception(_message, '', 'sp_employee_delete_by_empid', 1, 0, _result);
END;
$procedure$
;
