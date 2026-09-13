DROP PROCEDURE IF EXISTS public.sp_employee_by_role_id(integer, integer, refcursor);

CREATE OR REPLACE PROCEDURE public.sp_employee_by_role_id(
    _roleid integer, 
    _projectid integer,
    INOUT _result_ref refcursor DEFAULT 'rs_emp_by_role'
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
            p.fullname::text AS name, 
            p.employeeid AS employeeuid, 
            p.email, 
            p.designationid::bigint 
        FROM project_members_detail p 
        WHERE p.projectid = _projectid 
          AND p.membertype = _roleid;
          
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_by_role_id'::varchar, 1, 0, _result);
END;
$procedure$;
