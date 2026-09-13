DROP PROCEDURE IF EXISTS public.sp_employee_bonus_get_by_distinct_month(varchar, refcursor);

CREATE OR REPLACE PROCEDURE public.sp_employee_bonus_get_by_distinct_month(
    _distinctmonthyearkeys character varying,
    INOUT _result_ref refcursor DEFAULT 'rs_bonus_distinct_month'
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;
BEGIN
    OPEN _result_ref FOR 
        SELECT * 
        FROM employee_bonus 
        WHERE (foryear * 100 + formonth) = ANY(string_to_array(_distinctmonthyearkeys, ',')::int[]);
        
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_bonus_get_by_distinct_month'::varchar, 1, 0, _result);
END;
$procedure$;
