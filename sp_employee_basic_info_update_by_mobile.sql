CREATE OR REPLACE PROCEDURE public.sp_employee_basic_info_update_by_mobile(
    IN _employeeid bigint, 
    IN _firstname character varying, 
    IN _lastname character varying, 
    IN _admin bigint, 
    OUT _processingresult character varying
)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying; -- FIXED: Logger variable compatibility
BEGIN
    UPDATE employees SET 
        firstname = _firstname,
        lastname = _lastname,
        updatedon = timezone('utc', now()),
        updatedby = _admin
    WHERE employeeuid = _employeeid;
     
    UPDATE employeeprofessiondetail SET 
        firstname = _firstname,
        lastname = _lastname,
        updatedon = timezone('utc', now()),
        updatedby = _admin
    WHERE employeeuid = _employeeid;
     
    _processingresult := 'updated';
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    -- FIXED: Added ::varchar casts and error messaging output
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_basic_info_update_by_mobile'::varchar, 1, 0, _result);
    _processingresult := _message;
END;
$procedure$;
