DROP PROCEDURE IF EXISTS public.sp_employee_basic_info_by_emp_id(bigint, refcursor);

CREATE OR REPLACE PROCEDURE public.sp_employee_basic_info_by_emp_id(
    _employeeid bigint,
    INOUT _result_ref refcursor DEFAULT 'rs_emp_basic_info'
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
    OPEN _result_ref FOR 
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
$procedure$;
