DROP PROCEDURE IF EXISTS public.sp_employee_leaveplan_mapping_getbyplanid(integer, jsonb);
DROP FUNCTION IF EXISTS public.sp_employee_leaveplan_mapping_getbyplanid(integer);

CREATE OR REPLACE PROCEDURE public.sp_employee_leaveplan_mapping_getbyplanid(
    IN _leaveplanid integer,
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
    -- Aggregated rows into a JSONB array via INOUT parameter
    SELECT COALESCE(jsonb_agg(to_jsonb(elm)), '[]'::jsonb) INTO _response
    FROM employee_leaveplan_mapping elm
    WHERE elm.leaveplanid = _leaveplanid;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_leaveplan_mapping_getbyplanid'::varchar, 1, 0, _result);
    _response := jsonb_build_object('error', _message);
END;
$procedure$;
