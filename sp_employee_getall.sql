DROP PROCEDURE IF EXISTS public.sp_employee_getall(character varying, character varying, integer, integer, integer, jsonb);
DROP FUNCTION IF EXISTS public.sp_employee_getall(character varying, character varying, integer, integer, integer);

CREATE OR REPLACE PROCEDURE public.sp_employee_getall(
    IN _searchstring character varying, 
    IN _sortby character varying, 
    IN _pageindex integer, 
    IN _pagesize integer, 
    IN _financialyear integer,
    INOUT _response jsonb DEFAULT NULL
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
    _activequery TEXT;
BEGIN
    IF _sortby IS NULL OR _sortby = '' THEN
        _sortby := 'UpdatedOn DESC, CreatedOn DESC';
    END IF;

    IF _searchstring IS NULL OR _searchstring = '' THEN
        _searchstring := '1=1';
    END IF;

    _activequery := concat(
        'SELECT emp.EmployeeUid, ',
            'emp.FirstName, ',
            'emp.LastName, ',
            'emp.Mobile, ',
            'emp.Email, ',
            'emp.CompanyId, ',
            'emp.DesignationId, ',
            'emp.LeavePlanId, ',
            'emp.IsActive, ',
            'eprof.AadharNo, ',
            'eprof.PANNo, ',
            'eprof.AccountNumber, ',
            'eprof.BankName, ',
            'eprof.IFSCCode, ',
            'eprof.Domain, ',
            'eprof.Specification, ',
            'eprof.ExprienceInYear, ',
            'eper.ActualPackage, ',
            'eper.FinalPackage, ',
            'eper.TakeHomeByCandidate, ',
            '(',
                'SELECT COALESCE(jsonb_agg(jsonb_build_object(',
                '    ''CompanyId'', ClientUid,',
                '    ''CompanyName'', ClientName,',
                '    ''ActualPackage'', ActualPackage',
                ')), ''[]''::jsonb)',
                'FROM employeemappedclients ',
                'WHERE EmployeeUid = emp.EmployeeUid AND IsActive = 1',
            ') as ClientJson, ',
            'emp.WorkShiftId, ',
            'emp.ProjectId, ',
            'emp.UpdatedOn, ',
            'emp.CreatedOn, ',
            'u.FilePath, ',
            'u.FileName, ',
            'u.FileExtension ',
        'FROM employees emp ',
        'INNER JOIN employeelogin l ON emp.EmployeeUid = l.EmployeeId ',
        'LEFT JOIN employeepersonaldetail eper ON emp.EmployeeUid = eper.EmployeeUid ',
        'LEFT JOIN employeeprofessiondetail eprof ON emp.EmployeeUid = eprof.EmployeeUid ',
        'LEFT JOIN userfiledetail u ON u.FileOwnerId = l.EmployeeId AND u.UserTypeId = 2 AND u.ItemStatusId = 1 ',
        'WHERE emp.IsActive = true AND (', _searchstring, ')'
    ); 

    _selectquery := concat(
        'SELECT COALESCE(jsonb_agg(to_jsonb(T)), ''[]''::jsonb) FROM (',
        '    SELECT *, Row_Number() over() as RowIndex, Count(1) Over() as Total FROM (',
        _activequery,
        '    ) T ORDER BY ', _sortby, ' LIMIT ', _pagesize, ' OFFSET ', (_pageindex - 1) * _pagesize,
        ') T'
    );

    EXECUTE _selectquery INTO _response;
    
    -- Maintain side-effect execution of the health status procedure
    CALL sp_record_health_status_get_incomplete_profile(_financialyear);

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_getall'::varchar, 1, 0, _result);
    _response := jsonb_build_object('error', _message);
END;
$procedure$;
