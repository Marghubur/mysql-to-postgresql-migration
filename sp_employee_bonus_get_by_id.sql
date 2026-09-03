-- DROP FUNCTION public.sp_employee_bonus_get_by_id(int8);

CREATE OR REPLACE FUNCTION public.sp_employee_bonus_get_by_id(_bonusid bigint)
 RETURNS SETOF employee_bonus
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result TEXT;
BEGIN
    begin
 
 
 RETURN QUERY select * from employee_bonus
 where bonusid = _bonusid;
 end;
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    CALL sp_logexception(_message, '', 'sp_employee_bonus_get_by_id', 1, 0, _result);
END;
$function$
;
