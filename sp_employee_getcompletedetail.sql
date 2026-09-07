-- Drop existing routine variants to prevent conflicts
DROP FUNCTION IF EXISTS public.sp_employee_getcompletedetail(bigint);
DROP PROCEDURE IF EXISTS public.sp_employee_getcompletedetail(bigint);

CREATE OR REPLACE FUNCTION public.sp_employee_getcompletedetail(
    IN _employeeid bigint
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
    _currentfinancialyear bigint;
    _response jsonb;
BEGIN
    _currentfinancialyear := 0;
    SELECT financialyear INTO _currentfinancialyear 
    FROM company_setting
    WHERE isprimary = 1 OR isprimary = true;
    
    IF _currentfinancialyear IS NULL THEN
        _currentfinancialyear := 0;
    END IF;

    -- Bundled all individual queries and result sets into a single unified JSONB structure
    SELECT jsonb_build_object(
        'employee', (
            SELECT COALESCE(jsonb_agg(to_jsonb(e)), '[]'::jsonb) 
            FROM employees e 
            WHERE e.employeeuid = _employeeid
        ),
        'employee_personal_detail', (
            SELECT COALESCE(jsonb_agg(to_jsonb(ep)), '[]'::jsonb) 
            FROM employeepersonaldetail ep 
            WHERE ep.employeeuid = _employeeid
        ),
        'employee_profession_detail', (
            SELECT COALESCE(jsonb_agg(to_jsonb(ef)), '[]'::jsonb) 
            FROM employeeprofessiondetail ef 
            WHERE ef.employeeuid = _employeeid
        ),
        'employee_login', (
            SELECT COALESCE(jsonb_agg(to_jsonb(el)), '[]'::jsonb) 
            FROM employeelogin el 
            WHERE el.employeeid = _employeeid
        ),
        'employee_declaration', (
            SELECT COALESCE(jsonb_agg(to_jsonb(ed)), '[]'::jsonb) 
            FROM employee_declaration ed 
            WHERE ed.employeeid = _employeeid AND ed.declarationfromyear = _currentfinancialyear
        ),
        'employee_leave_request', (
            SELECT COALESCE(jsonb_agg(to_jsonb(elr)), '[]'::jsonb) 
            FROM employee_leave_request elr 
            WHERE elr.employeeid = _employeeid
        ),
        'employee_notice_period', (
            SELECT COALESCE(jsonb_agg(to_jsonb(enp)), '[]'::jsonb) 
            FROM employee_notice_period enp 
            WHERE enp.employeeid = _employeeid
        ),
        'employee_salary_detail', (
            SELECT COALESCE(jsonb_agg(to_jsonb(esd)), '[]'::jsonb) 
            FROM employee_salary_detail esd 
            WHERE esd.employeeid = _employeeid AND esd.financialstartyear = _currentfinancialyear
        ),
        'employee_timesheet', (
            SELECT COALESCE(jsonb_agg(to_jsonb(ets)), '[]'::jsonb) 
            FROM employee_timesheet ets 
            WHERE ets.employeeid = _employeeid
        ),
        'employee_mapped_clients', (
            SELECT COALESCE(jsonb_agg(to_jsonb(emc)), '[]'::jsonb) 
            FROM employeemappedclients emc 
            WHERE emc.employeeuid = _employeeid
        )
    ) INTO _response;

    RETURN _response;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_getcompletedetail'::varchar, 1, 0, _result);
    RETURN json_build_object('error', _message)::jsonb;
END;
$function$;
