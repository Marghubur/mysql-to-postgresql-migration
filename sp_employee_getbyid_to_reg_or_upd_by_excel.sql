-- Drop existing routine variants to prevent conflicts
DROP FUNCTION IF EXISTS public.sp_employee_getbyid_to_reg_or_upd_by_excel(bigint, character varying, character varying, integer);
DROP PROCEDURE IF EXISTS public.sp_employee_getbyid_to_reg_or_upd_by_excel(bigint, character varying, character varying, integer);

CREATE OR REPLACE FUNCTION public.sp_employee_getbyid_to_reg_or_upd_by_excel(
    IN _employeeid bigint, 
    IN _mobile character varying, 
    IN _email character varying, 
    IN _companyid integer
)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;
    _employeecount bigint;
    _mobilecount bigint;
    _financialyear bigint;
    _emailcount bigint;
    _response jsonb;
BEGIN
    _emailcount := 0;
    _mobilecount := 0;
    _employeecount := 0;
    
    IF EXISTS (SELECT 1 FROM employees e WHERE e.employeeuid = _employeeid AND e.isactive = true) THEN 
        _employeecount := 1;
        
        SELECT count(e.employeeuid) INTO _emailcount 
        FROM employees e
        WHERE e.email = _email AND e.employeeuid <> _employeeid;
        
        SELECT count(e.employeeuid) INTO _mobilecount 
        FROM employees e
        WHERE e.mobile = _mobile AND e.employeeuid <> _employeeid;
    ELSE
        SELECT count(e.employeeuid) INTO _employeecount 
        FROM employees e
        WHERE e.employeeuid = _employeeid;
        
        SELECT count(e.employeeuid) INTO _emailcount 
        FROM employees e
        WHERE e.email = _email;
        
        SELECT count(e.employeeuid) INTO _mobilecount 
        FROM employees e
        WHERE e.mobile = _mobile; 
    END IF;

    _financialyear := 0;
    SELECT financialyear INTO _financialyear
    FROM company_setting
    WHERE CASE WHEN _companyid > 0 THEN companyid = _companyid ELSE isprimary = 1 END;
    
    IF _financialyear IS NULL THEN
        _financialyear := 0;
    END IF;

    -- Bundled all original result sets and metadata counts into a structured JSONB object
    SELECT jsonb_build_object(
        'employee', (
            SELECT COALESCE(jsonb_agg(to_jsonb(e)), '[]'::jsonb) 
            FROM employees e 
            WHERE e.employeeuid = _employeeid AND e.isactive = true
        ),
        'employee_declaration', (
            SELECT COALESCE(jsonb_agg(to_jsonb(d)), '[]'::jsonb) 
            FROM employee_declaration d 
            WHERE d.employeeid = _employeeid AND d.declarationfromyear = _financialyear
        ),
        'employee_salary_detail', (
            SELECT COALESCE(jsonb_agg(to_jsonb(s)), '[]'::jsonb) 
            FROM employee_salary_detail s 
            WHERE s.employeeid = _employeeid AND s.financialstartyear = _financialyear
        ),
        'counts', jsonb_build_object(
            'employeecount', _employeecount,
            'mobilecount', _mobilecount,
            'emailcount', _emailcount
        )
    ) INTO _response;

    RETURN _response;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_getbyid_to_reg_or_upd_by_excel'::varchar, 1, 0, _result);
    RETURN json_build_object('error', _message)::jsonb;
END;
$function$;
