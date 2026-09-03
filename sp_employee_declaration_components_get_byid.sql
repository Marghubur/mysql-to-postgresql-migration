DROP FUNCTION IF EXISTS public.sp_employee_declaration_components_get_byid(bigint);
CREATE OR REPLACE FUNCTION public.sp_employee_declaration_components_get_byid(_employeedeclarationid bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;
    _response jsonb;
BEGIN
    -- Aggregate multiple result sets into a single JSON object to bypass 
    -- PostgreSQL's single-result-set restriction for functions
    SELECT json_build_object(
        'employee_declaration', (
            SELECT COALESCE(json_agg(row_to_json(d)), '[]'::json) 
            FROM employee_declaration d 
            WHERE d.employeedeclarationid = _employeedeclarationid
        ),
        'salary_components', (
            SELECT COALESCE(json_agg(row_to_json(sc)), '[]'::json) 
            FROM salary_components sc
        )
    ) INTO _response;

    RETURN _response;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_declaration_components_get_byid'::varchar, 1, 0, _result);
    RETURN json_build_object('error', _message)::jsonb;
END;
$function$;
