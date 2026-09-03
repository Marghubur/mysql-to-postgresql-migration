--DROP FUNCTION IF EXISTS public.sp_employee_declaration_get_byemployeeid(bigint, integer);

CREATE OR REPLACE FUNCTION public.sp_employee_declaration_get_byemployeeid(_employeeid bigint, _usertypeid integer)
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
    
    SELECT financialyear INTO _currentfinancialyear 
    FROM company_setting 
    WHERE isprimary 
    LIMIT 1;
    
    IF _currentfinancialyear IS NULL THEN
        _currentfinancialyear := 0;
    END IF;

    -- Aggregate multiple result sets into a single JSON object to bypass 
    -- PostgreSQL's single-result-set restriction for functions
    SELECT json_build_object(
        'declarations', (
            SELECT COALESCE(json_agg(
                json_build_object(
                    'declaration', row_to_json(d),
                    'email', e.email,
                    'dob', e.dob
                )
            ), '[]'::json)
            FROM employee_declaration d
            INNER JOIN employeepersonaldetail e ON e.employeeuid = d.employeeid
            WHERE d.employeeid = _employeeid
              AND d.declarationfromyear = _currentfinancialyear
        ),
        'user_files', (
            SELECT COALESCE(json_agg(row_to_json(uf)), '[]'::json)
            FROM userfiledetail uf
            WHERE uf.fileownerid = _employeeid 
              AND uf.usertypeid = _usertypeid
        )
    ) INTO _response;

    RETURN _response;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_declaration_get_byemployeeid'::varchar, 1, 0, _result);
    RETURN json_build_object('error', _message)::jsonb;
END;
$function$;
