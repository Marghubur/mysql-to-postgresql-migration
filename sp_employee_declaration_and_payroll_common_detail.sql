CREATE OR REPLACE FUNCTION public.sp_employee_declaration_and_payroll_common_detail()
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;
    _statename TEXT;
    _response jsonb;
BEGIN
    -- Fetch state from company table
    SELECT state INTO _statename FROM company LIMIT 1;
    IF _statename IS NULL THEN
        _statename := '';
    END IF;

    -- Aggregate multiple result sets into a single JSON object to bypass 
    -- PostgreSQL's single-result-set restriction for functions
    SELECT json_build_object(
        'salary_components', (SELECT COALESCE(json_agg(row_to_json(sc)), '[]'::json) FROM salary_components sc),
        'company_settings', (SELECT COALESCE(json_agg(row_to_json(cs)), '[]'::json) FROM company_setting cs),
        'ptax_slab', (SELECT COALESCE(json_agg(row_to_json(pt)), '[]'::json) FROM ptax_slab pt WHERE lower(pt.statename) = lower(_statename)),
        'surcharge_slab', (SELECT COALESCE(json_agg(row_to_json(ss)), '[]'::json) FROM surcharge_slab ss)
    ) INTO _response;

    RETURN _response;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_declaration_and_payroll_common_detail'::varchar, 1, 0, _result);
    RETURN json_build_object('error', _message)::jsonb;
END;
$function$;
