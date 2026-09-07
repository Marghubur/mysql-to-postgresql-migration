-- Drop existing routine variants to prevent conflicts
DROP FUNCTION IF EXISTS public.sp_employee_get_bonus_shift_overtime(integer, integer, integer);
DROP PROCEDURE IF EXISTS public.sp_employee_get_bonus_shift_overtime(integer, integer, integer);

CREATE OR REPLACE FUNCTION public.sp_employee_get_bonus_shift_overtime(
    IN _companyid integer, 
    IN _formonth integer, 
    In _foryear integer
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
    _financialyear bigint;
    _response jsonb;
BEGIN
    _financialyear := 0;
    SELECT financialyear INTO _financialyear 
    FROM company_setting
    WHERE companyid = _companyid;
    
    IF _financialyear IS NULL THEN
        _financialyear := 0;
    END IF;

    -- Aggregated rows into a JSONB array to return structured data cleanly
    SELECT COALESCE(jsonb_agg(to_jsonb(sub)), '[]'::jsonb) INTO _response
    FROM (
        SELECT 
            b.bonusshiftovertimeid, 
            b.employeeid,
            b.isbonus,
            b.isshift,
            b.isovertime,
            b.foryear,
            b.formonth,
            b.companyid,
            b.organizationid,
            s.componentfullname, 
            b.amount,
            b.totalminutes,
            e.firstname, 
            e.lastname, 
            h.paymentactiontype, 
            h.comments,
            h.iscompoff,
            h.otcalculatedon,
            p.paycalculationid,
            es.completesalarydetail,
            CASE
                WHEN h.salaryadhocid IS NULL THEN 0
                ELSE h.salaryadhocid
            END AS salaryadhocid
        FROM bonus_shift_overtime b
        LEFT JOIN hike_bonus_salary_adhoc h ON h.employeeid = b.employeeid 
        LEFT JOIN salary_components s ON s.componentid = b.componentid
        LEFT JOIN employee_salary_detail es ON es.employeeid = b.employeeid
        LEFT JOIN payroll_cycle_setting p ON p.companyid = b.companyid
        LEFT JOIN employees e ON e.employeeuid = b.employeeid
        WHERE es.financialstartyear = _financialyear
          AND b.foryear = _foryear 
          AND b.formonth = _formonth 
          AND b.companyid = _companyid
          AND e.isactive = true
    ) sub;

    RETURN _response;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_get_bonus_shift_overtime'::varchar, 1, 0, _result);
    RETURN json_build_object('error', _message)::jsonb;
END;
$function$;
