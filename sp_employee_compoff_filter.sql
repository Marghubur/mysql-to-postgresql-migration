-- DROP PROCEDURE public.sp_employee_compoff_filter(varchar, int4, int4);

CREATE OR REPLACE PROCEDURE public.sp_employee_compoff_filter(IN _searchstring character varying, IN _pageindex integer, IN _pagesize integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result TEXT;
    _sortby TEXT;
    _selectquery TEXT;
BEGIN
    begin
 

 begin

 _sortby := ' e.UpdatedOn DESC ';
 
 _selectquery := concat('Select * from (
				Select 
					Row_Number() over(Order by ', _sortby, ') as RowIndex,
					e.*,
                    emp.FirstName,
                    emp.LastName,
                    Count(1) Over() as Total
				FROM employee_compoff_and_overtime e
                left Join employees emp on e.EmployeeId = emp.EmployeeUid
				where ', _searchstring, '
			)T where RowIndex between ', (_pageindex - 1) * _pagesize + 1 ,' and ', (_pageindex * _pagesize)) ;
 
 EXECUTE _selectquery;end;
 end;
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    CALL sp_logexception(_message, '', 'sp_employee_compoff_filter', 1, 0, _result);
END;
$procedure$
;
