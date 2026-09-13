DROP PROCEDURE IF EXISTS public.sp_employee_declaration_components_get_byid(bigint, jsonb);

CREATE OR REPLACE PROCEDURE public.sp_employee_declaration_components_get_byid(
    _employeedeclarationid bigint,
    INOUT _response jsonb DEFAULT NULL
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
    -- Aggregate multiple result sets into the JSON output parameter
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

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_declaration_components_get_byid'::varchar, 1, 0, _result);
    _response := json_build_object('error', _message)::jsonb;
END;
$procedure$;
