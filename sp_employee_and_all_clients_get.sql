DROP PROCEDURE IF EXISTS public.sp_employee_and_all_clients_get(
    varchar,
    varchar,
    integer,
    integer,
    refcursor
);

CREATE OR REPLACE PROCEDURE public.sp_employee_and_all_clients_get(
    IN _searchstring character varying,
    IN _sortby character varying,
    IN _pageindex integer,
    IN _pagesize integer,
    INOUT _result_cursor refcursor
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR;
    _selectquery TEXT;
    _currentfinancialyear bigint;
BEGIN

    -- Get current financial year
    _currentfinancialyear := 0;

    SELECT financialyear
    INTO _currentfinancialyear
    FROM company_setting
    WHERE isprimary = true
    LIMIT 1;


    -- Default sorting
    IF (_sortby IS NULL OR _sortby = '') THEN
        _sortby := 'UpdatedOn DESC, CreatedOn DESC';
    END IF;


    -- Default search condition
    IF (_searchstring IS NULL OR _searchstring = '') THEN
        _searchstring := '1=1';
    END IF;


    -- Build dynamic query
    _selectquery := concat(
        'SELECT * FROM (
            SELECT
                ROW_NUMBER() OVER (
                    ORDER BY ', _sortby, '
                ) AS RowIndex,

                emp.EmployeeUid,
                emp.FirstName,
                0::integer AS ClientUid,
                emp.LastName,
                emp.Mobile,
                emp.Email,
                emp.IsActive,
                emp.CreatedOn,
                emp.ReportingManagerId,

                (
                    SELECT json_agg(
                        json_build_object(
                            ''CompanyId'', ClientUid,
                            ''CompanyName'', ClientName,
                            ''ActualPackage'', ActualPackage
                        )
                    )
                    FROM employeemappedclients
                    WHERE EmployeeUid = emp.EmployeeUid
                      AND IsActive = true
                ) AS ClientJson,

                (
                    SELECT EmployeeCurrentRegime::varchar
                    FROM employee_declaration
                    WHERE EmployeeId = emp.EmployeeUid
                      AND DeclarationFromYear = ',
                      _currentfinancialyear,
                '
                ) AS EmployeeCurrentRegime,

                (
                    SELECT DOB
                    FROM employeepersonaldetail
                    WHERE EmployeeUid = emp.EmployeeUid
                ) AS DOB,

                emp.UpdatedOn,

                COUNT(1) OVER() AS Total

            FROM employees emp
            WHERE ', _searchstring, '
        ) T
        WHERE RowIndex BETWEEN ',
        ((_pageindex - 1) * _pagesize + 1),
        ' AND ',
        (_pageindex * _pagesize)
    );


    -- Open cursor with dynamic query
    OPEN _result_cursor FOR EXECUTE _selectquery;


EXCEPTION
    WHEN OTHERS THEN

        _sqlstate := SQLSTATE;
        _errortext := SQLERRM;
        _errorno := SQLSTATE;

        _message := concat(
            'ERROR ',
            _errorno,
            ' (',
            _sqlstate,
            '): ',
            _errortext
        );

        CALL sp_logexception(
            _message,
            ''::varchar,
            'sp_employee_and_all_clients_get'::varchar,
            1,
            0,
            _result
        );

        RAISE EXCEPTION '%', _errortext;

END;
$procedure$;
