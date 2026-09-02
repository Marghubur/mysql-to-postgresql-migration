CREATE OR REPLACE FUNCTION public.sp_columnmapping_getbypagename(
  IN _pagename varchar(100)
)
RETURNS SETOF "tablecolumnmapping"
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
BEGIN
  if (_pagename = 'all') then
 begin
 RETURN QUERY select pagename, 
 columnname, 
 displayname, 
 style, 
 classname,
 ishidden
 from tablecolumnmapping;
 end;
 else
 begin
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select pagename, 
 columnname, 
 displayname, 
 style, 
 classname,
 ishidden
 from tablecolumnmapping
 where pagename = _pagename;
 end;
 end if;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_columnmapping_getbypagename', 1::bit, 0::bit, _result);
END;
$$;
