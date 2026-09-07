-- Drop both potential routine kinds to avoid conflict
DROP FUNCTION IF EXISTS public.sp_employee_exit_dashboard(character varying, character varying, integer, integer);
DROP PROCEDURE IF EXISTS public.sp_employee_exit_dashboard(character varying, character varying, integer, integer);

CREATE OR REPLACE FUNCTION public.sp_employee_exit_dashboard(
    _searchstring character varying, 
    _sortby character varying, 
    _pageindex integer, 
    _pagesize integer
)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;
    _selectquery TEXT;
    _response jsonb;
BEGIN
    IF _sortby IS NULL OR _sortby = '' THEN
        _sortby := 'n.CreatedOn DESC';
    END IF;

    IF _searchstring IS NULL OR _searchstring = '' THEN
        _searchstring := '1=1';
    END IF;

    -- FIXED: Combined paginated list items and dashboard summary metrics into 
    -- a single JSONB structure to prevent SETOF multi-query conflict errors.
    _selectquery := concat(
        'SELECT jsonb_build_object(',
        '    ''items'', COALESCE(jsonb_agg(to_jsonb(sub)), ''[]''::jsonb),',
        '    ''summary'', (',
        '        SELECT jsonb_build_object(',
        '            ''totalexitemployees'', sum(case when resignationstatus = (select itemstatusid from itemstatus where lower(status) = ''approved'') then 1 else 0 end),',
        '            ''totalrevokeemployees'', sum(case when resignationstatus = (select itemstatusid from itemstatus where lower(status) = ''rejected'') then 1 else 0 end),',
        '            ''totalpendingexitemployees'', sum(case when resignationstatus = (select itemstatusid from itemstatus where lower(status) = ''pending'') then 1 else 0 end)',
        '        ) FROM employee_notice_period',
        '    )',
        ') FROM (',
        '    SELECT * FROM (',
        '        SELECT ',
        '            ROW_NUMBER() OVER(ORDER BY ', _sortby, ') AS RowIndex,',
        '            n.*,',
        '            CONCAT(e.FirstName, '' '', e.LastName) as Name,',
        '            o.RoleName as Designation,',
        '            org.RoleName as DepartmentName,',
        '            COUNT(1) OVER() AS Total',
        '        FROM employee_notice_period n',
        '        LEFT JOIN employees e ON e.EmployeeUid = n.EmployeeId',
        '        LEFT JOIN org_hierarchy o ON o.RoleId = e.DesignationId',
        '        LEFT JOIN employeeprofessiondetail epro ON epro.EmployeeUid = n.EmployeeId',
        '        LEFT JOIN org_hierarchy org ON org.RoleId = epro.DepartmentId',
        '        WHERE ', _searchstring,',',
        '    ) T',
        '    WHERE RowIndex BETWEEN ', ((_pageindex - 1) * _pagesize + 1), ' AND ', (_pageindex * _pagesize),
        ') sub'
    );

    EXECUTE _selectquery INTO _response;
    
    RETURN _response;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_exit_dashboard'::varchar, 1, 0, _result);
    RETURN json_build_object('error', _message)::jsonb;
END;
$function$;
