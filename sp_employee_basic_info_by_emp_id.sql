DROP FUNCTION IF EXISTS public.sp_employee_basic_info_by_emp_id(bigint);

CREATE OR REPLACE FUNCTION public.sp_employee_basic_info_by_emp_id(_employeeid bigint)
 RETURNS TABLE (
    employeeuid bigint,
    firstname character varying,
    lastname character varying,
    mobile character varying,
    email character varying,
    reportingmanager text,
    designation character varying,
    dateofjoining timestamp without time zone
 )
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying; 
BEGIN
    RETURN QUERY 
    SELECT 
        e.employeeuid,
        e.firstname,
        e.lastname,
        e.mobile,
        e.email,
        concat(emp.firstname, ' ', emp.lastname)::text as reportingmanager,
        o.rolename as designation,
        e.createdon as dateofjoining
    FROM employees e
    LEFT JOIN employees emp on emp.employeeuid = e.reportingmanagerid
    LEFT JOIN org_hierarchy o on o.roleid = e.designationid
    WHERE e.employeeuid = _employeeid;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_basic_info_by_emp_id'::varchar, 1, 0, _result);
END;
$function$;
