CREATE OR REPLACE FUNCTION public.sp_employee_assets_allocation_get_by_empid(_employeeid bigint)
 RETURNS TABLE (
    EmployeeAssetsAllocationId bigint,
    EmployeeId bigint,
    AssetStatus character varying,   -- FIXED: Added the missing comma right here!
    AllocatedByName text,            
    ReturnHandleByName text
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
$function$;
