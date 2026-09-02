CREATE OR REPLACE PROCEDURE public.sp_digital_allocated_assets_upd(
  IN _allocationid bigint,
  IN _revokedby bigint,
  IN _isactive bit,
  OUT _processingresult varchar(500)
)
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
 update employee_digital_allocation set
 revokedby = _revokedby,
 revokedon = timezone('utc', now()),
 isactive = _isactive
 where allocationid = _allocationid;
 _processingresult := 'updated';
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_digital_allocated_assets_upd', 1::bit, 0::bit, _result);
END;
$$;
