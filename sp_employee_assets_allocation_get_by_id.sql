CREATE OR REPLACE PROCEDURE public.sp_employee_assets_allocation_get_by_id(
    _employeeassetsallocationid bigint,
    INOUT _result_ref refcursor DEFAULT 'rs_asset_by_id'
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
        SELECT * FROM employee_assets_allocation 
        WHERE employeeassetsallocationid = _employeeassetsallocationid;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_assets_allocation_get_by_id'::varchar, 1, 0, _result);
END;
$procedure$;
