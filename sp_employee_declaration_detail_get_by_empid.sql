DROP PROCEDURE IF EXISTS public.sp_employee_declaration_detail_get_by_empid(bigint, integer, jsonb);

CREATE OR REPLACE PROCEDURE public.sp_employee_declaration_detail_get_by_empid(
    _employeeid bigint, 
    _financialstartyear integer,
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
        'declaration_details', (
            SELECT COALESCE(json_agg(
                json_build_object(
                    'declaration', row_to_json(d),
                    'email', e.email,
                    'isactive', e.isactive
                )
            ), '[]'::json)
            FROM employee_declaration d
            INNER JOIN employees e ON e.employeeuid = d.employeeid
            WHERE d.employeeid = _employeeid
              AND d.declarationfromyear = _financialstartyear
              AND e.isactive = true
        ),
        'salary_details', (
            SELECT COALESCE(json_agg(row_to_json(sd)), '[]'::json)
            FROM employee_salary_detail sd
            WHERE sd.employeeid = _employeeid
              AND sd.financialstartyear = _financialstartyear
        )
    ) INTO _response;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_declaration_detail_get_by_empid'::varchar, 1, 0, _result);
    _response := json_build_object('error', _message)::jsonb;
END;
$procedure$;
