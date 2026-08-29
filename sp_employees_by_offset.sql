CREATE OR REPLACE FUNCTION public.sp_employees_by_offset(_pagesize integer, _offsetsize integer)
 RETURNS SETOF employees
 LANGUAGE plpgsql
AS $function$
BEGIN
    _offsetsize := _offsetsize - 1;
    
    RETURN QUERY 
    SELECT * FROM employees e    -- FIXED: Changed to SELECT * to match 'SETOF employees'
    WHERE isactive = true        -- FIXED: Changed 1 to true for the boolean column
    ORDER BY employeeuid
    LIMIT _pagesize OFFSET _offsetsize;
END;
$function$;
