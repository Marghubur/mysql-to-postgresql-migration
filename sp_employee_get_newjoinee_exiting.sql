-- Drop existing routine variants to prevent conflicts
DROP FUNCTION IF EXISTS public.sp_employee_get_newjoinee_exiting(integer, integer, integer);
DROP PROCEDURE IF EXISTS public.sp_employee_get_newjoinee_exiting(integer, integer, integer);

CREATE OR REPLACE FUNCTION public.sp_employee_get_newjoinee_exiting(
    IN _companyid integer, 
    IN _formonth integer, 
    IN _foryear integer
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
    _noticeperioddays bigint;
    _probationperioddays bigint;
    _response jsonb;
BEGIN
    _noticeperioddays := 0;
    _probationperioddays := 0;
    
    SELECT probationperiodindays, noticeperiodindays 
    INTO _probationperioddays, _noticeperioddays
    FROM company_setting 
    WHERE companyid = _companyid;
    
    IF _probationperioddays IS NULL THEN 
        _probationperioddays := 0; 
    END IF;
    IF _noticeperioddays IS NULL THEN 
        _noticeperioddays := 0; 
    END IF;

    -- Aggregated rows into a JSONB array, translating datediff to standard PostgreSQL day extractions
    SELECT COALESCE(jsonb_agg(to_jsonb(sub)), '[]'::jsonb) INTO _response
    FROM (
        SELECT e.employeeuid as employeeid, 
            e.firstname, 
            e.lastname, 
            e.mobile, 
            e.email,
            e.createdon,
            NULL::timestamp without time zone as dol,
            s.ctc,
            EXTRACT(DAY FROM (timezone('utc', now()) - e.createdon))::bigint AS indays,
            FALSE as isservingnotice,
            TRUE as inprobation,
            4 as resignationstatus,
            NULL::text as reason,
            h.paymentactiontype,
            h.comments,
            CASE
                WHEN h.salaryadhocid IS NULL THEN 0
                ELSE h.salaryadhocid
            END AS salaryadhocid
        FROM employees e
        INNER JOIN employee_salary_detail s ON e.employeeuid = s.employeeid
        LEFT JOIN hike_bonus_salary_adhoc h ON h.employeeid = e.employeeuid
          AND h.foryear = 2024 AND h.formonth = 3
        WHERE EXTRACT(DAY FROM (timezone('utc', now()) - e.createdon)) <= _probationperioddays 
        
        UNION ALL
        
        SELECT e.employeeuid as employeeid, 
            e.firstname, 
            e.lastname, 
            e.mobile, 
            e.email,
            e.createdon,
            n.officiallastworkingday as dol,
            s.ctc,
            EXTRACT(DAY FROM (n.officiallastworkingday - timezone('utc', now())))::bigint AS indays,
            TRUE as isservingnotice,
            CASE
                WHEN EXTRACT(DAY FROM (timezone('utc', now()) - e.createdon)) <= _probationperioddays 
                THEN TRUE 
                ELSE FALSE
            END as inprobation,
            n.resignationstatus,
            n.employeecomment as reason,
            h.paymentactiontype,
            h.comments,
            CASE
                WHEN h.salaryadhocid IS NULL THEN 0
                ELSE h.salaryadhocid
            END AS salaryadhocid
        FROM employees e
        INNER JOIN employee_salary_detail s ON e.employeeuid = s.employeeid
        INNER JOIN employee_notice_period n ON e.employeeuid = n.employeeid
        LEFT JOIN hike_bonus_salary_adhoc h ON h.employeeid = e.employeeuid 
          AND h.foryear = _foryear AND h.formonth = _formonth
        WHERE n.isexited = false
    ) sub;

    RETURN _response;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_get_newjoinee_exiting'::varchar, 1, 0, _result);
    RETURN json_build_object('error', _message)::jsonb;
END;
$function$;
