DROP FUNCTION IF EXISTS public.sp_employee_duplicate_record_get_all();

CREATE OR REPLACE FUNCTION public.sp_employee_duplicate_record_get_all()
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;
    _response jsonb;
BEGIN
    -- FIXED: Changed return signature to JSONB and aggregated the custom 
    -- joined column selection to resolve PostgreSQL's SETOF row-type mismatch error.
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

    RETURN _response;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_duplicate_record_get_all'::varchar, 1, 0, _result);
    RETURN json_build_object('error', _message)::jsonb;
END;
$function$;
