-- DROP FUNCTION public.sp_employee_declaration_get_byid(int8);

CREATE OR REPLACE FUNCTION public.sp_employee_declaration_get_byid(_employeedeclarationid bigint)
 RETURNS SETOF employee_declaration
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
 
 
 RETURN QUERY select 
 *
 from employee_declaration
 where employeedeclarationid = _employeedeclarationid;
 end;
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    CALL sp_logexception(_message, '', 'sp_employee_declaration_get_byid', 1, 0, _result);
END;
$function$
;
