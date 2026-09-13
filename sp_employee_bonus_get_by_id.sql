DROP PROCEDURE IF EXISTS public.sp_employee_bonus_get_by_id(bigint, refcursor);

CREATE OR REPLACE PROCEDURE public.sp_employee_bonus_get_by_id(
    _bonusid bigint,
    INOUT _result_ref refcursor DEFAULT 'rs_bonus_by_id'
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
        FROM employee_bonus
        WHERE bonusid = _bonusid;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, '', 'sp_employee_bonus_get_by_id', 1, 0, _result);
END;
$procedure$;
