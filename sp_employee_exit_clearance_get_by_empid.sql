-- DROP FUNCTION public.sp_employee_exit_clearance_get_by_empid(int8);

CREATE OR REPLACE FUNCTION public.sp_employee_exit_clearance_get_by_empid(_employeeid bigint)
 RETURNS SETOF employee_exit_clearance
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result TEXT;
BEGIN
    RETURN QUERY select * from employee_exit_clearance 
 where employeeid = _employeeid;
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    CALL sp_logexception(_message, '', 'sp_employee_exit_clearance_get_by_empid', 1, 0, _result);
END;
$function$
;
