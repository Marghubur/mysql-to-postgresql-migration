-- DROP FUNCTION public.sp_employee_and_declaration_get_byid(int8);

CREATE OR REPLACE FUNCTION public.sp_employee_and_declaration_get_byid(_employeeid bigint)
 RETURNS SETOF company_setting
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result TEXT;
    _currentfinancialyear bigint;
BEGIN
    _currentfinancialyear := 0;
 select financialyear into _currentfinancialyear from company_setting
 where isprimary;

 RETURN QUERY select e.*, ed.employeedeclarationid from employees e
 inner join employee_declaration ed on e.employeeuid = ed.employeeid
 and ed.declarationfromyear = _currentfinancialyear
 where e.employeeuid = _employeeid;
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    CALL sp_logexception(_message, '', 'sp_employee_and_declaration_get_byid', 1, 0, _result);
END;
$function$
;
