DROP PROCEDURE IF EXISTS public.sp_employee_get_newjoinee_exiting(integer, integer, integer, jsonb);
DROP FUNCTION IF EXISTS public.sp_employee_get_newjoinee_exiting(integer, integer, integer);

CREATE OR REPLACE PROCEDURE public.sp_employee_get_newjoinee_exiting(
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
    _noticeperioddays bigint;
    _probationperioddays bigint;
BEGIN
    -- Fetch company configuration securely
    SELECT 
        COALESCE(probationperiodindays, 0), 
        COALESCE(noticeperiodindays, 0)
    INTO 
        _probationperioddays, 
        _noticeperioddays
    FROM company_setting 
    WHERE companyid = _companyid
    LIMIT 1;
    
    _probationperioddays := COALESCE(_probationperioddays, 0);
    _noticeperioddays    := COALESCE(_noticeperioddays, 0);

    -- Aggregate results into the INOUT parameter
    SELECT COALESCE(jsonb_agg(to_jsonb(sub)), '[]'::jsonb) INTO _response
    FROM (
        -- New Joinees (In Probation)
        SELECT 
            e.employeeuid AS employeeid, 
            e.firstname, 
            e.lastname, 
            e.mobile, 
            e.email,
            e.createdon,
            NULL::timestamp without time zone AS dol,
            s.ctc,
            EXTRACT(DAY FROM (timezone('utc', now()) - e.createdon))::bigint AS indays,
            FALSE AS isservingnotice,
            TRUE AS inprobation,
            4 AS resignationstatus,
            NULL::text AS reason,
            h.paymentactiontype,
            h.comments,
            COALESCE(h.salaryadhocid, 0) AS salaryadhocid
        FROM employees e
        INNER JOIN employee_salary_detail s ON e.employeeuid = s.employeeid
        LEFT JOIN hike_bonus_salary_adhoc h ON h.employeeid = e.employeeuid
          AND h.foryear = _foryear AND h.formonth = _formonth
        WHERE EXTRACT(DAY FROM (timezone('utc', now()) - e.createdon)) <= _probationperioddays
        
        UNION ALL
        
        -- Exiting Employees (Serving Notice)
        SELECT 
            e.employeeuid AS employeeid, 
            e.firstname, 
            e.lastname, 
            e.mobile, 
            e.email,
            e.createdon,
            n.officiallastworkingday AS dol,
            s.ctc,
            EXTRACT(DAY FROM (n.officiallastworkingday - timezone('utc', now())))::bigint AS indays,
            TRUE AS isservingnotice,
            (EXTRACT(DAY FROM (timezone('utc', now()) - e.createdon)) <= _probationperioddays) AS inprobation,
            n.resignationstatus,
            n.employeecomment AS reason,
            h.paymentactiontype,
            h.comments,
            COALESCE(h.salaryadhocid, 0) AS salaryadhocid
        FROM employees e
        INNER JOIN employee_salary_detail s ON e.employeeuid = s.employeeid
        INNER JOIN employee_notice_period n ON e.employeeuid = n.employeeid
        LEFT JOIN hike_bonus_salary_adhoc h ON h.employeeid = e.employeeuid 
          AND h.foryear = _foryear AND h.formonth = _formonth
        WHERE n.isexited = FALSE
    ) sub;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_get_newjoinee_exiting'::varchar, 1, 0, _result);
    _response := jsonb_build_object('error', _message);
END;
$procedure$;
