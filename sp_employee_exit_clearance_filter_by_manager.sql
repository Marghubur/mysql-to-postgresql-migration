-- Step 1: Drop the existing procedure completely
DROP PROCEDURE IF EXISTS public.sp_employee_exit_clearance_filter_by_manager;

-- Step 2: Create it cleanly as a function returning jsonb
CREATE OR REPLACE FUNCTION public.sp_employee_exit_clearance_filter_by_manager(
    IN _searchstring character varying, 
    IN _sortby character varying, 
    IN _pageindex integer, 
    IN _pagesize integer, 
    IN _employeeid bigint
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
    _departmentid bigint;
    _response jsonb;
BEGIN
    _departmentid := 0;
    
    SELECT departmentid INTO _departmentid 
    FROM employeeprofessiondetail 
    WHERE employeeuid = _employeeid;
    
    IF _departmentid IS NULL THEN
        _departmentid := 0;
    END IF;

    IF _sortby IS NULL OR _sortby = '' THEN
        _sortby := 'CreatedOn';
    END IF;

    IF _searchstring IS NULL OR _searchstring = '' THEN
        _searchstring := '1=1';
    END IF;

    _selectquery := concat(
        'SELECT COALESCE(jsonb_agg(to_jsonb(sub)), ''[]''::jsonb) FROM (',
        'SELECT * FROM (',
        'SELECT ',
        'ROW_NUMBER() OVER (ORDER BY ', _sortby, ') AS RowIndex, ',
        'ex.ClearanceReportId, ',
        'ex.ClearanceDepartmentDetailId, ',
        'ex.ApproverId, ',
        'ex.ClearanceStatus AS Status, ',
        'ex.EmployeeId, ',
        'ex.EmployeeNoticePeriodId, ',
        'n.ResignType, ',
        'n.RequestedLastWorkingDay, ',
        'n.OfficialLastWorkingDay, ',
        'n.NoticePeriodDate, ',
        'n.EmployeeComment, ',
        'n.CreatedOn, ',
        'CONCAT(e.FirstName, '' '', e.LastName) AS EmployeeName, ',
        'e.Mobile, ',
        'e.Email, ',
        'o.RoleName AS Designation, ',
        'oh.RoleName AS Department, ',
        'COUNT(1) OVER() AS Total ',
        'FROM clearance_report ex ',
        'LEFT JOIN employees e ON e.EmployeeUid = ex.EmployeeId ',
        'LEFT JOIN org_hierarchy o ON o.RoleId = e.DesignationId ',
        'LEFT JOIN employeeprofessiondetail epro ON epro.EmployeeUid = ex.EmployeeId ',
        'LEFT JOIN org_hierarchy oh ON oh.RoleId = epro.DepartmentId ',
        'INNER JOIN employee_notice_period n ON n.EmployeeNoticePeriodId = ex.EmployeeNoticePeriodId ',
        'INNER JOIN project_members_detail pmTarget ON pmTarget.EmployeeId = ', _employeeid, ' ',
        'INNER JOIN project_members_detail pmOther ON pmOther.ProjectId = pmTarget.ProjectId ',
        'INNER JOIN clearance_department_detail cdd ON cdd.ClearanceDepartmentDetailId = ex.ClearanceDepartmentDetailId ',
        ' AND pmOther.EmployeeId = ex.EmployeeId ',
        'WHERE cdd.DepartmentId = ', _departmentid, ' ',
        ' AND (', _searchstring, ')',
        ') T ',
        'WHERE RowIndex BETWEEN ', ((_pageindex - 1) * _pagesize + 1), ' AND ', (_pageindex * _pagesize),
        ') sub'
    );
    
    EXECUTE _selectquery INTO _response;
    
    RETURN _response;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_exit_clearance_filter_by_manager'::varchar, 1, 0, _result);
    RETURN json_build_object('error', _message)::jsonb;
END;
$function$;
