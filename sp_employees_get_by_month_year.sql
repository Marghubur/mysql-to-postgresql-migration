DROP FUNCTION IF EXISTS public.sp_employees_get_by_month_year(int4, int4);

CREATE OR REPLACE FUNCTION public.sp_employees_get_by_month_year(_year integer, _month integer)
 RETURNS SETOF employees
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result TEXT;  -- FIXED: Changed to TEXT to match p_result perfectly
BEGIN
    RETURN QUERY 
    SELECT e.*                  
    FROM employees e
    LEFT JOIN employee_notice_period en ON en.employeeid = e.employeeuid
    WHERE (e.isactive = true
       OR (e.isactive = false AND (EXTRACT(YEAR FROM en.officiallastworkingday) * 100 + EXTRACT(MONTH FROM en.officiallastworkingday)) >= _year * 100 + _month)); 
       
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employees_get_by_month_year'::varchar, 1, 0, _result);
END;
$function$;
