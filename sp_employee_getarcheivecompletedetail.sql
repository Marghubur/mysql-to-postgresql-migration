DROP PROCEDURE IF EXISTS public.sp_employee_getarcheivecompletedetail(bigint, refcursor);
DROP FUNCTION IF EXISTS public.sp_employee_getarcheivecompletedetail(bigint);

CREATE OR REPLACE PROCEDURE public.sp_employee_getarcheivecompletedetail(
    IN _employeeid bigint,
    INOUT _result_cursor refcursor DEFAULT 'rs_cursor'
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _log_result TEXT;
BEGIN
    OPEN _result_cursor FOR 
    SELECT * 
    FROM employee_archive
    WHERE employeeid = _employeeid;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_getarcheivecompletedetail'::varchar, 1, 0, _log_result);
END;
$procedure$;
