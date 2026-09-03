DROP FUNCTION IF EXISTS public.sp_employee_asset_allocation_filter(varchar, varchar, int4, int4);

CREATE OR REPLACE FUNCTION public.sp_employee_asset_allocation_filter(
    _searchstring character varying, 
    _sortby character varying, 
    _pageindex integer, 
    _pagesize integer
)
 RETURNS TABLE (
    RowIndex bigint,
    employeeassetsallocationid bigint,
    employeeid bigint,
    productid bigint,
    allocatedon timestamp without time zone,
    allocatedby bigint,
    returnstatus bit,
    returnedon timestamp without time zone,
    commentsonreturneditem character varying,
    returnedhandledby bigint,
    remarks character varying,
    EmployeeName text,
    AllocatedByName text,
    ReturnedHandledByName text,
    AssetName character varying,
    CatagoryName character varying,
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
BEGIN
    IF _searchstring IS NULL OR btrim(_searchstring) = '' THEN
        _searchstring := '1=1';
    END IF;

    IF _sortby IS NULL OR btrim(_sortby) = '' THEN
        _sortby := 'EmployeeAssetsAllocationId';
    END IF;
    
    _selectquery := concat(
        'SELECT * FROM (',
            'SELECT ',
            'ROW_NUMBER() OVER (ORDER BY ', _sortby, ') AS RowIndex, ',
            'a.*, ',
            'CONCAT(em.FirstName, '' '', em.LastName)::text AS EmployeeName, ',
            'CONCAT(e.FirstName, '' '', e.LastName)::text AS AllocatedByName, ',
            'CONCAT(emp.FirstName, '' '', emp.LastName)::text AS ReturnedHandledByName, ',
            'p.AssetName, ',
            'p.CatagoryName, ',
            'COUNT(1) OVER() AS Total ',
            'FROM employee_assets_allocation a ',
            'LEFT JOIN employees e ON e.EmployeeUid = a.AllocatedBy ',
            'LEFT JOIN employees em ON em.EmployeeUid = a.EmployeeId ',
            'LEFT JOIN employees emp ON emp.EmployeeUid = a.ReturnedHandledBy ',
            'LEFT JOIN product p ON p.ProductId = a.ProductId ',
            'WHERE ', _searchstring,
        ') T ',
        'WHERE RowIndex BETWEEN ', ((_pageindex - 1) * _pagesize + 1), ' AND ', (_pageindex * _pagesize)
    );
 
    RETURN QUERY EXECUTE _selectquery;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_asset_allocation_filter'::varchar, 1, 0, _result);
END;
$function$;
