DROP PROCEDURE IF EXISTS public.sp_employee_declaration_get_byid(bigint, refcursor);

CREATE OR REPLACE PROCEDURE public.sp_employee_declaration_get_byid(
    _employeedeclarationid bigint,
    INOUT _result_ref refcursor DEFAULT 'rs_declaration_by_id'
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result TEXT;
BEGIN
    OPEN _result_ref FOR 
        SELECT * 
        FROM employee_declaration
        WHERE employeedeclarationid = _employeedeclarationid;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, '', 'sp_employee_declaration_get_byid', 1, 0, _result);
END;
$procedure$;
