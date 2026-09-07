-- DROP FUNCTION public.sp_employee_getarcheivecompletedetail(int8);

CREATE OR REPLACE FUNCTION public.sp_employee_getarcheivecompletedetail(_employeeid bigint)
 RETURNS SETOF employee_archive
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result TEXT;
BEGIN
    begin
 
 
 RETURN QUERY select * from employee_archive
 where employeeid = _employeeid;
 
 
 
 end;
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    CALL sp_logexception(_message, '', 'sp_employee_getarcheivecompletedetail', 1, 0, _result);
END;
$function$
;
