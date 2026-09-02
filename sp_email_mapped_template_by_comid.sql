CREATE OR REPLACE FUNCTION public.sp_email_mapped_template_by_comid(
  IN _searchstring varchar(250),
  IN _sortby varchar(50),
  IN _pageindex integer,
  IN _pagesize integer
)
RETURNS SETOF "email_mapped_template"
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _selectquery TEXT;
BEGIN
  begin
 
 begin
 if(_sortby is null or _sortby = '') then
 _sortby := 'UpdatedOn desc, CreatedOn desc';
 end if;
 _selectquery := concat('Select * from (
  Select 
  Row_Number() over(Order by ', _sortby, ') as RowIndex,
  EmailTempMappingId, 
  CompanyId,
  EmailTemplateName,
  TemplateId,
  UpdatedOn,
  CreatedOn,
  Count(1) Over() as Total from email_mapped_template
  Where ', _searchstring, '
  )T where RowIndex between ', ((_pageindex - 1 ) * _pagesize + 1), ' and ', (_pageindex * _pagesize));
 
 RETURN QUERY EXECUTE _selectquery;end;
 RETURN QUERY select * from email_templates;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_email_mapped_template_by_comid', 1::bit, 0::bit, _result);
END;
$$;
