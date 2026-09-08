CREATE OR REPLACE FUNCTION public.sp_catagory_getby_id(
  IN _categoryid integer
)
RETURNS SETOF "catagory"
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
 
 RETURN QUERY select *
 from catagory
 where categoryid = _categoryid;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_catagory_getby_id', 1::bit, 0::bit, _result);
END;
$$;
