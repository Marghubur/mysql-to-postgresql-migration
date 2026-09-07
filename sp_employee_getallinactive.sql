-- Drop existing procedure or function variants to prevent routine kind conflicts
DROP PROCEDURE IF EXISTS public.sp_employee_getallinactive(character varying, character varying, integer, integer);
DROP FUNCTION IF EXISTS public.sp_employee_getallinactive(character varying, character varying, integer, integer);

CREATE OR REPLACE FUNCTION public.sp_employee_getallinactive(
    IN _searchstring character varying, 
    IN _sortby character varying, 
    IN _pageindex integer, 
    IN _pagesize integer
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
    _activequery TEXT;
    _response jsonb;
BEGIN
    IF _sortby IS NULL OR _sortby = '' THEN
        _sortby := 'CreatedOn DESC';
    END IF;

    IF _searchstring IS NULL OR _searchstring = '' THEN
        _searchstring := '1=1';
    END IF;

    _activequery := concat(
        'SELECT ',
            'emp.EmployeeId, ',
            'emp.EmployeeCompleteJsonData, ',
            'emp.CreatedBy, ',
            'emp.CreatedOn, ',
            '(',
                'SELECT COALESCE(jsonb_agg(jsonb_build_object(',
                '    ''CompanyId'', ClientUid,',
                '    ''CompanyName'', ClientName,',
                '    ''ActualPackage'', ActualPackage',
                ')), ''[]''::jsonb)',
                'FROM employeemappedclients ',
                'WHERE EmployeeUid = emp.EmployeeId',
            ') as ClientJson, ',
            'u.FilePath, ',
            'u.FileName, ',
            'u.FileExtension ',
        'FROM employee_archive emp ',
        'LEFT JOIN userfiledetail u ON u.FileOwnerId = emp.EmployeeId ',
        'WHERE (', _searchstring, ')'
    ); 

    _selectquery := concat(
        'SELECT COALESCE(jsonb_agg(to_jsonb(T)), ''[]''::jsonb) FROM (',
        '    SELECT *, Count(1) Over() as Total FROM (',
        _activequery,
        '    ) T ORDER BY ', _sortby, ' LIMIT ', _pagesize, ' OFFSET ', (_pageindex - 1) * _pagesize,
        ') T'
    );

    EXECUTE _selectquery INTO _response;
    
    RETURN _response;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_getallinactive'::varchar, 1, 0, _result);
    RETURN json_build_object('error', _message)::jsonb;
END;
$function$;
