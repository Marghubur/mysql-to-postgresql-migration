CREATE OR REPLACE FUNCTION public.sp_deactivateorganization_delandgetall(
  IN _clientmappedid bigint,
  IN _userid bigint
)
RETURNS SETOF "employeemappedclients"
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _operationstatus bigint;
BEGIN
  _operationstatus := '';
 begin
 
 update employeemappedclients set isactive = 0 
 where employeemappedclientsuid = _clientmappedid;
 RETURN QUERY select * from employeemappedclients 
 where employeeuid = _userid and isactive = 1;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_deactivateorganization_delandgetall', 1::bit, 0::bit, _result);
END;
$$;
