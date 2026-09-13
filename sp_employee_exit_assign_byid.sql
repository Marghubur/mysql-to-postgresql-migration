DROP PROCEDURE IF EXISTS public.sp_employee_exit_assign_byid(bigint, bigint, jsonb);

CREATE OR REPLACE PROCEDURE public.sp_employee_exit_assign_byid(
    _employeeid bigint, 
    _assigneid bigint,
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
    _departmentid bigint;
    _rolename TEXT;
BEGIN
    _departmentid := 0;
    SELECT departmentid INTO _departmentid 
    FROM employeeprofessiondetail 
    WHERE employeeuid = _assigneid;
    
    _rolename := '';
    SELECT rolename INTO _rolename 
    FROM employee_exit_configuration 
    WHERE departmentid = _departmentid;

    -- Aggregate clearance rows directly into the INOUT parameter
    SELECT COALESCE(jsonb_agg(to_jsonb(t)), '[]'::jsonb) INTO _response
    FROM (
        SELECT * 
        FROM employee_exit_clearance 
        WHERE employeeid = _employeeid 
          AND clearancebyname = _rolename
    ) t;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_exit_assign_byid'::varchar, 1, 0, _result);
    _response := json_build_object('error', _message)::jsonb;
END;
$procedure$;
