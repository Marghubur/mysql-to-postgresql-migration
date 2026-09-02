CREATE OR REPLACE FUNCTION public.sp_digital_allocated_assets_by_id(
  IN _employeeid bigint,
  IN _featureid bigint
)
RETURNS SETOF "employee_digital_allocation"
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
BEGIN
  begin
 RETURN QUERY select d.*, da.name, da.featureid from employee_digital_allocation d
 inner join digital_asset da on da.digitalassetid = d.digitalassetid
 where d.employeeid = _employeeid
 and da.featureid = _featureid;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_digital_allocated_assets_by_id', 1::bit, 0::bit, _result);
END;
$$;
