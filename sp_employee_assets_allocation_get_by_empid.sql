CREATE OR REPLACE PROCEDURE public.sp_employee_assets_allocation_get_by_empid(
    _employeeid bigint,
    INOUT _result_ref refcursor DEFAULT 'rs_assets'
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
            ea.*, 
            concat(e.firstname, ' ', e.lastname)::text as allocatedbyname, 
            concat(es.firstname, ' ', es.lastname)::text as returnhandlebyname 
        FROM employee_assets_allocation ea
        LEFT JOIN employees e on e.employeeuid = ea.allocatedby
        LEFT JOIN employees es on es.employeeuid = ea.returnedhandledby
        WHERE ea.employeeid = _employeeid;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_assets_allocation_get_by_empid'::varchar, 1, 0, _result);
END;
$procedure$;
