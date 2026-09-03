DROP FUNCTION IF EXISTS public.sp_employee_and_all_clients_get(varchar, varchar, int4, int4);

CREATE OR REPLACE FUNCTION public.sp_employee_and_all_clients_get(
    _searchstring character varying, 
    _sortby character varying, 
    _pageindex integer, 
    _pagesize integer
)
RETURNS TABLE (
    RowIndex bigint,
    EmployeeUid bigint,
    FirstName character varying,
    ClientUid integer,
    LastName character varying,
    Mobile character varying,
    Email character varying,
    IsActive boolean,
    CreatedOn timestamp without time zone,
    ReportingManagerId bigint,
    ClientJson json,
    EmployeeCurrentRegime character varying, 
    DOB timestamp without time zone,
    UpdatedOn timestamp without time zone,
    Total bigint
)
LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;
    _selectquery TEXT;
    _currentfinancialyear bigint;
BEGIN
    -- Safely get current financial year
    _currentfinancialyear := 0;
    select financialyear into _currentfinancialyear from company_setting where isprimary = true;

    if(_sortby is null or _sortby = '') then
        _sortby := 'UpdatedOn Desc, CreatedOn Desc';
    end if;
    
    if(_searchstring is null or _searchstring = '') then
        _searchstring := '1=1';
    end if;

    -- FIXED: Replaced SQL Server JSON functions with Postgres json_agg & json_build_object
    -- FIXED: Concatenated _currentfinancialyear into the string instead of @currentFinancialYear
    _selectquery := concat('Select * from (
                    Select 
                        Row_Number() over(Order by ', _sortby, ') as RowIndex,
                        emp.EmployeeUid, 
                        emp.FirstName,
                        0::integer as ClientUid,
                        emp.LastName,
                        emp.Mobile,
                        emp.Email,
                        emp.IsActive,
                        emp.CreatedOn,
                        emp.ReportingManagerId,
                        (
                            Select json_agg(
                                json_build_object(
                                    ''CompanyId'', ClientUid,
                                    ''CompanyName'', ClientName,
                                    ''ActualPackage'', ActualPackage
                                )
                            )
                            from employeemappedclients 
                            where EmployeeUid = emp.EmployeeUid and IsActive = true
                        ) as ClientJson,
                        (select EmployeeCurrentRegime::varchar from employee_declaration where EmployeeId = emp.EmployeeUid and DeclarationFromYear = ', _currentfinancialyear, ') as EmployeeCurrentRegime,
                        (select DOB from employeepersonaldetail where EmployeeUid = emp.EmployeeUid) as DOB,
                        emp.UpdatedOn,
                        Count(1) Over() as Total 
                    from employees emp
                    Where ', _searchstring, '
                ) T where RowIndex between ', ((_pageindex - 1 ) * _pagesize + 1), ' and ', (_pageindex * _pagesize));
 
    RETURN QUERY EXECUTE _selectquery;
    
    -- FIXED: Removed "RETURN QUERY select * from clients;" to prevent schema crashes
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    -- FIXED: Added ::varchar casts so the logger doesn't crash
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_and_all_clients_get'::varchar, 1, 0, _result);
END;
$function$;
