CREATE OR REPLACE FUNCTION public.sp_complaint_or_request_get_by_attendanceid(
    _attendanceid integer,
    _employeeid bigint
)
RETURNS SETOF attendance
LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _processingresult VARCHAR;
BEGIN

    RETURN QUERY
    SELECT *
    FROM attendance
    WHERE attendanceid = _attendanceid;

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

        CALL public.sp_logexception(
            _message,
            '',
            'sp_complaint_or_request_get_by_attendanceid',
            1::bit,
            0::bit,
            _processingresult
        );

END;
$function$;
