-- DROP PROCEDURE public.sp_employee_bonus_delte_by_id(in int8, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_employee_bonus_delte_by_id(IN _bonusid bigint, OUT _processingresult character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result TEXT;
BEGIN
    begin
 
 
 delete from employee_bonus where bonusid = _bonusid;
 
 _processingresult := 'deleted';
 end;
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    CALL sp_logexception(_message, '', 'sp_employee_bonus_delte_by_id', 1, 0, _result);
END;
$procedure$
;
