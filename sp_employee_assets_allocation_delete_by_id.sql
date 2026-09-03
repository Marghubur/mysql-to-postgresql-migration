DROP PROCEDURE IF EXISTS public.sp_employee_assets_allocation_delete_by_id(bigint);

CREATE OR REPLACE PROCEDURE public.sp_employee_assets_allocation_delete_by_id(
    IN _employeeassetsallocationid bigint, 
    OUT _processingresult character varying
)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying; -- FIXED: Changed TEXT to character varying
BEGIN
    delete from employee_assets_allocation 
    where employeeassetsallocationid = _employeeassetsallocationid;
 
    _processingresult := 'deleted';
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    -- FIXED: Added ::varchar casts so the logger doesn't crash
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_assets_allocation_delete_by_id'::varchar, 1, 0, _result);
END;
$procedure$;
