DROP FUNCTION IF EXISTS public.sp_employee_declaration_detail_get(bigint);

CREATE OR REPLACE FUNCTION public.sp_employee_declaration_detail_get(_employeeid bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;
    _currentfinancialyear bigint;
    _response jsonb;
BEGIN
    _currentfinancialyear := 0;
    
    -- FIXED: Fetch current financial year safely
    SELECT financialyear INTO _currentfinancialyear 
    FROM company_setting 
    WHERE isprimary 
    LIMIT 1;
    
    IF _currentfinancialyear IS NULL THEN
        _currentfinancialyear := 0;
    END IF;

    -- FIXED: Using jsonb aggregation to return dynamic/mixed table attributes cleanly
    SELECT COALESCE(json_agg(
        json_build_object(
            'declaration', row_to_json(d),
            'email', e.email,
            'isactive', e.isactive
        )
    ), '[]'::json) INTO _response
    FROM employee_declaration d
    INNER JOIN employees e ON e.employeeuid = d.employeeid
    WHERE d.employeeid = _employeeid
      AND e.isactive = true
      AND d.declarationfromyear = _currentfinancialyear;

    RETURN _response;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_declaration_detail_get'::varchar, 1, 0, _result);
    RETURN json_build_object('error', _message)::jsonb;
END;
$function$;
