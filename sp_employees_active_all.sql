-- DROP FUNCTION public.sp_employees_active_all(int4, int4);

CREATE OR REPLACE FUNCTION public.sp_employees_active_all(_year integer, _month integer)
 RETURNS SETOF company_setting
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR; -- FIX 1: Changed TEXT to VARCHAR
    _date DATE;      -- Changed from TEXT to DATE so it handles the math properly
    _financialyear bigint;
BEGIN
    _financialyear := 0;
    
    -- FIX 2: Replaced MySQL 'str_to_date' with PostgreSQL 'to_date' and proper format
    _date := to_date(concat(_year, '-', _month, '-01'), 'YYYY-MM-DD');
    
    SELECT 
        CASE 
            WHEN _date >= to_date(concat(financialyear, '-', declarationstartmonth, '-01'), 'YYYY-MM-DD')
             AND _date <= to_date(concat(financialyear+1, '-', declarationendmonth, '-01'), 'YYYY-MM-DD')
            THEN financialyear 
            ELSE financialyear - 1 
        END AS resultfinancialyear 
    INTO _financialyear
    FROM company_setting
    WHERE isprimary = true;

    BEGIN
        RETURN QUERY SELECT e.*, es.ctc, ed.employeecurrentregime , es.financialstartyear
        FROM employees e
        LEFT JOIN employee_salary_detail es ON es.employeeid = e.employeeuid
        LEFT JOIN employee_declaration ed ON ed.employeeid = e.employeeuid
        WHERE e.isactive = true
          AND es.financialstartyear = _financialyear
          AND ed.declarationfromyear = _financialyear
          AND es.ctc > 0;
    END;
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    -- FIX 3: Added the explicit ::varchar casts!
    CALL sp_logexception(_message, ''::varchar, 'sp_employees_active_all'::varchar, 1, 0, _result);
END;
$function$
;
