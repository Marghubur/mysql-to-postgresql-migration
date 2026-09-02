CREATE OR REPLACE FUNCTION public.sp_declaration_and_payroll_common_detail(
  IN _employeeid bigint,
  IN _companyid integer
)
RETURNS SETOF "company_setting"
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _startmonth bigint;
  _endmonth bigint;
  _financialyear bigint;
  _statename TEXT;
BEGIN
  _financialyear := 0;
 _startmonth := 0;
 _endmonth := 0;
 select 
 financialyear, 
 declarationstartmonth,
 declarationendmonth into _financialyear, _startmonth, _endmonth
 from company_setting
 where 
 case when _companyid > 0 then companyid = _companyid
 else isprimary = 1
 end;
 RETURN QUERY select * from employees
 where employeeuid = _employeeid;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from employee_declaration
 where employeeid = _employeeid
 and declarationfromyear = _financialyear;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from employee_salary_detail
 where employeeid = _employeeid
 and financialstartyear = _financialyear;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from salary_components;
 _statename := '';
 select state into _statename from company where companyid = _companyid limit 1;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select s.*, _statename as statename from company_setting s
 where 
 case when _companyid > 0 then s.companyid = _companyid
 else s.isprimary = true
 end;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from ptax_slab where lower(statename) = lower(_statename);
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from surcharge_slab;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from previous_employement_details where employeeid = _employeeid;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_declaration_and_payroll_common_detail', 1::bit, 0::bit, _result);
END;
$$;
