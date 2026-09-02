CREATE OR REPLACE PROCEDURE public.sp_columnmapping_insupd(
  IN _mappingid bigint,
  IN _pagename varchar(100),
  IN _columnname varchar(50),
  IN _displayname varchar(50),
  IN _style varchar(250),
  IN _classname varchar(250),
  IN _ishidden bit
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
  if not exists(select 1 from tablecolumnmapping where mappingid = _mappingid)then
 begin 
 insert into tablecolumnmapping values(default, 
 _pagename, 
 _columnname, 
 _displayname, 
 _style, 
 _classname,
 _ishidden
 );
 end;
 else
 begin
 update tablecolumnmapping set 
 pagename = _pagename, 
 columnname = _columnname, 
 style = _style, 
 displayname = _displayname, 
 classname = _classname
 where mappingid = _mappingid;
 end;
 end if;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_columnmapping_insupd', 1::bit, 0::bit, _result);
END;
$$;
