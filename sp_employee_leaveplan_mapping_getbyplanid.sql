-- DROP FUNCTION public.sp_employee_leaveplan_mapping_getbyplanid(int4);

CREATE OR REPLACE FUNCTION public.sp_employee_leaveplan_mapping_getbyplanid(_leaveplanid integer)
 RETURNS SETOF record
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
 
 
 RETURN QUERY select * from employee_leaveplan_mapping
 where leaveplanid = _leaveplanid;
 end;
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    CALL sp_logexception(_message, '', 'sp_employee_leaveplan_mapping_getbyplanid', 1, 0, _result);
END;
$function$
;
