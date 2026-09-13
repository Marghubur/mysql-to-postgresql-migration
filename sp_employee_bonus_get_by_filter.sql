DROP PROCEDURE IF EXISTS public.sp_employee_bonus_get_by_filter(varchar, varchar, int4, int4, refcursor);

CREATE OR REPLACE PROCEDURE public.sp_employee_bonus_get_by_filter(
    _searchstring character varying, 
    _sortby character varying, 
    _pageindex integer, 
    _pagesize integer,
    INOUT _result_ref refcursor DEFAULT 'rs_bonus_filter'
)
LANGUAGE plpgsql
AS $procedure$
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
        _sortby := 'b.CreatedOn DESC';
    END IF;
    
    _selectquery := concat('
        SELECT * FROM (
            SELECT 
                ROW_NUMBER() OVER(ORDER BY ', _sortby, ') AS RowIndex,
                b.*, 
                concat(e.FirstName, '' '', e.LastName)::text as Name,
                COUNT(1) OVER() AS Total
            FROM employee_bonus b
            LEFT JOIN employees e ON e.EmployeeUid = b.EmployeeId
            WHERE ', _searchstring, '
        ) T 
        WHERE RowIndex BETWEEN ', (_pageindex - 1) * _pagesize + 1, ' AND ', (_pageindex * _pagesize)
    );
 
    OPEN _result_ref FOR EXECUTE _selectquery;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_bonus_get_by_filter'::varchar, 1, 0, _result);
END;
$procedure$;
