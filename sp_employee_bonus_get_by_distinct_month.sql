DROP FUNCTION IF EXISTS public.sp_employee_bonus_get_by_distinct_month(varchar);

CREATE OR REPLACE FUNCTION public.sp_employee_bonus_get_by_distinct_month(_distinctmonthyearkeys character varying)
 RETURNS SETOF employee_bonus
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying; -- FIXED: Logger variable compatibility
BEGIN
    -- FIXED: In PostgreSQL, a comma-separated string passed to an IN clause must be converted 
    -- into an integer array using string_to_array and evaluated with = ANY()
    RETURN QUERY 
    SELECT * 
    FROM employee_bonus 
    WHERE (foryear * 100 + formonth) = ANY(string_to_array(_distinctmonthyearkeys, ',')::int[]);
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    -- FIXED: Added ::varchar casts to prevent logger crashes
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_bonus_get_by_distinct_month'::varchar, 1, 0, _result);
END;
$function$;
