-- Drop existing routine variants to prevent routine kind conflicts
DROP PROCEDURE IF EXISTS public.sp_employee_get_bonus_shift_overtime_filter(character varying, character varying, integer, integer);
DROP FUNCTION IF EXISTS public.sp_employee_get_bonus_shift_overtime_filter(character varying, character varying, integer, integer);

CREATE OR REPLACE FUNCTION public.sp_employee_get_bonus_shift_overtime_filter(
    IN _searchstring character varying, 
    IN _sortby character varying, 
    IN _pageindex integer, 
    IN _pagesize integer
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
    _selectquery TEXT;
    _financialyear bigint;
    _response jsonb;
BEGIN
    _financialyear := 0;
    SELECT financialyear INTO _financialyear 
    FROM company_setting 
    LIMIT 1;
    
    IF _financialyear IS NULL THEN
        _financialyear := 0;
    END IF;

    IF _sortby IS NULL OR _sortby = '' THEN
        _sortby := 'b.ForYear DESC';
    END IF;

    IF _searchstring IS NULL OR _searchstring = '' THEN
        _searchstring := '1=1';
    END IF;

    -- Converted procedure into a JSONB-returning function with proper variable interpolation 
    -- for _financialyear (replacing the placeholder @financialYear) and JSON aggregation.
    _selectquery := concat(
        'SELECT COALESCE(jsonb_agg(to_jsonb(sub)), ''[]''::jsonb) FROM (',
        'SELECT * FROM (',
        'SELECT ',
        'ROW_NUMBER() OVER(ORDER BY ', _sortby, ') AS RowIndex, ',
        'b.BonusShiftOvertimeId, ',
        'b.EmployeeId, ',
        'b.IsBonus, ',
        'b.IsShift, ',
        'b.IsOvertime, ',
        'b.ForYear, ',
        'b.ForMonth, ',
        'b.CompanyId, ',
        'b.OrganizationId, ',
        's.ComponentFullName, ',
        'b.Amount, ',
        'b.TotalMinutes, ',
        'e.FirstName, ',
        'e.LastName, ',
        'h.PaymentActionType, ',
        'h.Comments, ',
        'h.IsCompOff, ',
        'h.OTCalculatedOn, ',
        'p.PayCalculationId, ',
        'es.CompleteSalaryDetail, ',
        'CASE WHEN h.SalaryAdhocId IS NULL THEN 0 ELSE h.SalaryAdhocId END AS SalaryAdhocId, ',
        'COUNT(1) OVER() AS Total ',
        'FROM bonus_shift_overtime b ',
        'LEFT JOIN hike_bonus_salary_adhoc h ON h.EmployeeId = b.EmployeeId ',
        'LEFT JOIN salary_components s ON s.ComponentId = b.ComponentId ',
        'LEFT JOIN employee_salary_detail es ON es.EmployeeId = b.EmployeeId ',
        'LEFT JOIN payroll_cycle_setting p ON p.CompanyId = b.CompanyId ',
        'LEFT JOIN employees e ON e.EmployeeUid = b.EmployeeId ',
        'WHERE es.FinancialStartYear = ', _financialyear, ' ',
        '  AND e.IsActive = TRUE AND (', _searchstring, ')',
        ') T ',
        'WHERE RowIndex BETWEEN ', ((_pageindex - 1) * _pagesize + 1), ' AND ', (_pageindex * _pagesize),
        ') sub'
    );
 
    EXECUTE _selectquery INTO _response;
    
    RETURN _response;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_get_bonus_shift_overtime_filter'::varchar, 1, 0, _result);
    RETURN json_build_object('error', _message)::jsonb;
END;
$function$;
