DROP FUNCTION IF EXISTS public.sp_employee_autocomplete_data(varchar, int4, int4, int4);

CREATE OR REPLACE FUNCTION public.sp_employee_autocomplete_data(
    _searchstring character varying, 
    _pageindex integer, 
    _pagesize integer, 
    _companyid integer
)
 RETURNS TABLE (
    designationid bigint,
    selected boolean,
    email character varying,
    value bigint,
    text text
 )
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying; -- FIXED: Logger compatibility
BEGIN
    _pageindex := (_pageindex - 1) * _pagesize;

    -- FIXED: Changed from RETURNS SETOF employees to RETURNS TABLE to match the custom dropdown shape
    -- FIXED: Also replaced LIKE with ILIKE for case-insensitive search matching standard autocomplete behavior
    RETURN QUERY 
    SELECT 
        e.designationid,
        false AS selected,
        e.email,
        e.employeeuid AS value, 
        concat(e.firstname, ' ', e.lastname)::text AS text
    FROM employees e
    WHERE e.companyid = _companyid 
      AND e.isactive = true 
      AND (
          _searchstring IS NULL 
          OR _searchstring = '' 
          OR e.firstname ILIKE concat(_searchstring, '%') 
          OR e.lastname ILIKE concat(_searchstring, '%')
      )
    ORDER BY e.firstname
    LIMIT _pagesize OFFSET _pageindex;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    -- FIXED: Added ::varchar casts for the logger
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_autocomplete_data'::varchar, 1, 0, _result);
END;
$function$;
