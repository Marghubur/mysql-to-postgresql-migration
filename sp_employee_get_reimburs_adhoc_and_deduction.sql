DROP PROCEDURE IF EXISTS public.sp_employee_get_reimburs_adhoc_and_deduction(integer, integer, integer, jsonb);
DROP FUNCTION IF EXISTS public.sp_employee_get_reimburs_adhoc_and_deduction(integer, integer, integer);

CREATE OR REPLACE PROCEDURE public.sp_employee_get_reimburs_adhoc_and_deduction(
    IN _companyid integer, 
    IN _formonth integer, 
    IN _foryear integer,
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
    -- Aggregate joined rows directly into the INOUT parameter
    SELECT COALESCE(jsonb_agg(to_jsonb(sub)), '[]'::jsonb) INTO _response
    FROM (
        SELECT 
            b.reimbursadhocanddeduction, 
            b.employeeid,
            b.isreimburs,
            b.isadhoc,
            b.isdeduction,
            b.foryear,
            b.formonth,
            b.companyid,
            b.organizationid,
            s.componentfullname, 
            e.firstname, 
            e.lastname, 
            h.paymentactiontype, 
            h.comments,
            b.amount,
            ct.componentdescription,
            COALESCE(h.salaryadhocid, 0) AS salaryadhocid
        FROM reimburs_adhoc_and_deduction b
        LEFT JOIN hike_bonus_salary_adhoc h ON h.employeeid = b.employeeid 
        LEFT JOIN salary_components s ON s.componentid = b.componentid
        LEFT JOIN employees e ON e.employeeuid = b.employeeid 
        LEFT JOIN component_type ct ON ct.componenttypeid = s.componenttypeid 
        WHERE b.foryear = _foryear 
          AND b.formonth = _formonth 
          AND b.companyid = _companyid
          AND e.isactive = true
    ) sub;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_get_reimburs_adhoc_and_deduction'::varchar, 1, 0, _result);
    _response := jsonb_build_object('error', _message);
END;
$procedure$;
