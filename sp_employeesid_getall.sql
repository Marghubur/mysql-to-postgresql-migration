-- DROP FUNCTION public.sp_employeesid_getall();

CREATE OR REPLACE FUNCTION public.sp_employeesid_getall()
 RETURNS SETOF employees
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result TEXT;
BEGIN
    RETURN QUERY select * from employees;
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    CALL sp_logexception(_message, '', 'sp_employeesid_getall', 1, 0, _result);
END;
$function$
;
