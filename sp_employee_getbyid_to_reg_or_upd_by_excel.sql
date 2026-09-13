DROP PROCEDURE IF EXISTS public.sp_employee_getbyid_to_reg_or_upd_by_excel(bigint, character varying, character varying, integer, jsonb);
DROP FUNCTION IF EXISTS public.sp_employee_getbyid_to_reg_or_upd_by_excel(bigint, character varying, character varying, integer);

CREATE OR REPLACE PROCEDURE public.sp_employee_getbyid_to_reg_or_upd_by_excel(
    IN _employeeid bigint, 
    IN _mobile character varying, 
    IN _email character varying, 
    IN _companyid integer,
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
    _employeecount bigint := 0;
    _mobilecount bigint := 0;
    _emailcount bigint := 0;
    _financialyear bigint := 0;
    _is_active_employee boolean := FALSE;
BEGIN
    -- Single query check to establish existence and active status
    SELECT EXISTS (
        SELECT 1 FROM employees 
        WHERE employeeuid = _employeeid AND isactive = true
    ) INTO _is_active_employee;

    IF _is_active_employee THEN 
        _employeecount := 1;
        
        -- Combined count queries into a single scan over filtered rows
        SELECT 
            COUNT(1) FILTER (WHERE email = _email AND employeeuid <> _employeeid),
            COUNT(1) FILTER (WHERE mobile = _mobile AND employeeuid <> _employeeid)
        INTO _emailcount, _mobilecount
        FROM employees
        WHERE email = _email OR mobile = _mobile;
    ELSE
        SELECT 
            COUNT(1) FILTER (WHERE employeeuid = _employeeid),
            COUNT(1) FILTER (WHERE email = _email),
            COUNT(1) FILTER (WHERE mobile = _mobile)
        INTO _employeecount, _emailcount, _mobilecount
        FROM employees
        WHERE employeeuid = _employeeid OR email = _email OR mobile = _mobile;
    END IF;

    -- Fetch financial year setting with fallback
    SELECT COALESCE(financialyear, 0) INTO _financialyear
    FROM company_setting
    WHERE CASE WHEN _companyid > 0 THEN companyid = _companyid ELSE isprimary = 1 END
    LIMIT 1;

    _financialyear := COALESCE(_financialyear, 0);

    -- Construct JSONB output payload
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
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_getbyid_to_reg_or_upd_by_excel'::varchar, 1, 0, _result);
    _response := jsonb_build_object('error', _message);
END;
$procedure$;
