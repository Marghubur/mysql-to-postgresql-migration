CREATE OR REPLACE PROCEDURE public.sp_declaration_get_filter_by_empid(
  IN _searchstring varchar(250),
  IN _companyid integer,
    INOUT _refcur refcursor DEFAULT 'cur_result'
)
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _selectquery TEXT;
  _financialyear bigint;
BEGIN
  begin
 begin
 _financialyear := 0;
 select financialyear into _financialyear from company_setting
 where companyid = _companyid;
 _selectquery := concat('Select d.*,concat(e.FIrstName, e.LastName) FullName, e.Email from employee_declaration d
  inner join employees e on e.EmployeeUid = d.EmployeeId 
  Where d.DeclarationFromYear = @financialYear and e.IsActive = TRUE AND d.EmployeeId in (', _searchstring, ')'
 );
 OPEN _refcur FOR EXECUTE _selectquery;
 _selectquery := concat('Select es.* from employee_salary_detail es 
  Where es.FinancialStartYear = @financialYear and  es.EmployeeId in (', _searchstring, ')'
 );
 OPEN _refcur FOR EXECUTE _selectquery; 
 end;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_declaration_get_filter_by_empid', 1::bit, 0::bit, _result);
END;
$$;
