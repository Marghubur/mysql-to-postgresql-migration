DROP PROCEDURE IF EXISTS public.sp_employee_and_declaration_get_byid(
    bigint,
    refcursor
);

CREATE OR REPLACE PROCEDURE public.sp_employee_and_declaration_get_byid(
    IN _employeeid bigint,
    INOUT _result_cursor refcursor
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result TEXT;
    _currentfinancialyear bigint;
BEGIN

    -- Get current financial year
    _currentfinancialyear := 0;

    SELECT financialyear
    INTO _currentfinancialyear
    FROM company_setting
    WHERE isprimary = true
    LIMIT 1;


    -- Get employee and declaration details
    OPEN _result_cursor FOR
    SELECT
        e.*,
        ed.employeedeclarationid
    FROM employees e
    INNER JOIN employee_declaration ed
        ON e.employeeuid = ed.employeeid
       AND ed.declarationfromyear = _currentfinancialyear
    WHERE e.employeeuid = _employeeid;


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
            'sp_employee_and_declaration_get_byid'::varchar,
            1,
            0,
            _result
        );

        RAISE EXCEPTION '%', _errortext;

END;
$procedure$;
