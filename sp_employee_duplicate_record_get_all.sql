DROP PROCEDURE IF EXISTS public.sp_employee_duplicate_record_get_all(jsonb);

CREATE OR REPLACE PROCEDURE public.sp_employee_duplicate_record_get_all(
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
BEGIN
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'employeeuid', pro.employeeuid,
            'accountnumber', pro.accountnumber,
            'panno', pro.panno,
            'universalaccountnumber', pf.universalaccountnumber,
            'esiserialnumber', pf.esiserialnumber,
            'pfnumber', pf.pfnumber,
            'firstname', pro.firstname,
            'lastname', pro.lastname
        )
    ), '[]'::jsonb) INTO _response
    FROM employeeprofessiondetail pro
    LEFT JOIN employee_pf_detail pf ON pro.employeeuid = pf.employeeid;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_duplicate_record_get_all'::varchar, 1, 0, _result);
    _response := json_build_object('error', _message)::jsonb;
END;
$procedure$;
