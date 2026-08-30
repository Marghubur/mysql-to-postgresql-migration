-- DROP FUNCTION public.sp_employees_get(varchar, varchar, int4, int4);

CREATE OR REPLACE FUNCTION public.sp_employees_get(_searchstring character varying, _sortby character varying, _pageindex integer, _pagesize integer)
 RETURNS TABLE(rowindex bigint, employeeuid bigint, firstname character varying, clientuid integer, lastname character varying, mobile character varying, email character varying, isactive boolean, reportingmanagerid bigint, total bigint)
 LANGUAGE plpgsql
AS $function$
DECLARE
    _selectquery TEXT;
    _result character varying;
BEGIN
    if(_sortby is null or _sortby = '') then
        _sortby := 'employeeuid DESC';
    end if;

    if(_searchstring is null or _searchstring = '') then
        _searchstring := '1=1';
    end if;

    _selectquery := concat('Select * from (
                    Select 
                        Row_Number() over(Order by ', _sortby, ') as RowIndex,
                        EmployeeUid, 
                        FirstName,
                        0::integer as ClientUid,
                        LastName,
                        Mobile,
                        Email,
                        IsActive,
                        ReportingManagerId,
                        Count(1) Over() as Total 
                    from employees
                    Where ', _searchstring, '
                ) T where RowIndex between ', ((_pageindex - 1 ) * _pagesize + 1), ' and ', (_pageindex * _pagesize));
 
    RETURN QUERY EXECUTE _selectquery;
    
EXCEPTION WHEN OTHERS THEN
    CALL sp_logexception(
        concat('ERROR ', SQLSTATE, ': ', SQLERRM), 
        ''::varchar, 
        'sp_employees_get'::varchar, 
        1, 0, _result
    );
END;
$function$
;
