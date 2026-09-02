CREATE OR REPLACE FUNCTION public.sp_email_link_config_getby_pagename(
  IN _pagename varchar(50),
  IN _companyid integer
)
RETURNS SETOF "email_templates"
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
 
 RETURN QUERY select e.*, c.*, concat(f.filepath, '\\', f.filename) filepath from email_templates e
 left join company_files f on f.companyfileid = e.fileid
 right join email_link_config c on c.emailtemplateid = e.emailtemplateid
 where c.pagename = _pagename
 and c.companyid = _companyid;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_email_link_config_getby_pagename', 1::bit, 0::bit, _result);
END;
$$;
