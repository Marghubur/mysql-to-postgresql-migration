-- Drop any existing procedure or function signature to prevent routine kind conflicts
DROP PROCEDURE IF EXISTS public.sp_employee_exit_initiate_by_admin(bigint, bigint, character varying, integer, timestamp without time zone, character varying, timestamp without time zone, character varying, bigint, timestamp without time zone);
DROP FUNCTION IF EXISTS public.sp_employee_exit_initiate_by_admin(bigint, bigint, character varying, integer, timestamp without time zone, character varying, timestamp without time zone, character varying, bigint, timestamp without time zone);

CREATE OR REPLACE FUNCTION public.sp_employee_exit_initiate_by_admin(
    IN _employeenoticeperiodid bigint, 
    IN _employeeid bigint, 
    IN _resigntype character varying, 
    IN _resignationstatus integer, 
    IN _approvedon timestamp without time zone, 
    IN _attachmentpath character varying, 
    IN _officiallastworkingday timestamp without time zone, 
    IN _employeecomment character varying, 
    IN _createdby bigint, 
    IN _requestedlastworkingday timestamp without time zone
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
    _reportingmanagerid bigint;
    _nextclearanceid bigint;
    _noticeperiodindays bigint;
    _processingresult character varying;
    _response jsonb;
BEGIN
    IF NOT EXISTS(SELECT * FROM employee_notice_period WHERE employeenoticeperiodid = _employeenoticeperiodid) THEN
        _employeenoticeperiodid := 0;
        SELECT employeenoticeperiodid INTO _employeenoticeperiodid 
        FROM employee_notice_period
        ORDER BY employeenoticeperiodid DESC LIMIT 1;
        
        IF _employeenoticeperiodid IS NULL THEN
            _employeenoticeperiodid := 0;
        END IF;
        _employeenoticeperiodid := _employeenoticeperiodid + 1;

        _noticeperiodindays := 0;
        SELECT noticeperiodindays INTO _noticeperiodindays FROM company_setting;
        IF _noticeperiodindays IS NULL THEN
            _noticeperiodindays := 0;
        END IF;

        INSERT INTO employee_notice_period VALUES (
            _employeenoticeperiodid,
            _employeeid,
            _resigntype,
            _resignationstatus,
            NULL,
            _attachmentpath,
            _requestedlastworkingday,
            _officiallastworkingday,
            timezone('utc', now()) + (_noticeperiodindays * interval '1 day'),
            _employeecomment,
            _createdby,
            0,
            timezone('utc', now()),
            NULL
        );

        UPDATE employees SET
            isactive = FALSE,
            updatedon = _officiallastworkingday,
            updatedby = _createdby
        WHERE employeeuid = _employeeid;

        _reportingmanagerid := 0;
        SELECT reportingmanagerid INTO _reportingmanagerid 
        FROM employees
        WHERE employeeuid = _employeeid;

        _nextclearanceid := 0;
        SELECT COALESCE(max(employeeexitclearanceid), 0) + 1 INTO _nextclearanceid
        FROM employee_exit_clearance;

        INSERT INTO employee_exit_clearance (
            employeeexitclearanceid,
            employeenoticeperiodid,
            employeeid,
            clearancebyname,
            isdepartment,
            departmentid,
            roleid,
            handledby,
            approvalstatusid,
            comments,
            isactive,
            updatedon
        )
        SELECT
            _nextclearanceid + row_number() OVER (),
            _employeenoticeperiodid,
            _employeeid,
            '',
            CASE WHEN ec.departmentid > 0 THEN TRUE ELSE FALSE END,
            ec.departmentid,
            CASE WHEN ec.departmentid > 0 THEN 0
            ELSE (
                SELECT roleid
                FROM org_hierarchy
                WHERE lower(rolename) = lower(ec.rolename)
                LIMIT 1
            ) END,
            CASE WHEN ec.departmentid > 0 THEN 0 ELSE _reportingmanagerid END,
            CASE WHEN _resignationstatus = (SELECT itemstatusid FROM itemstatus WHERE lower(status) = 'approved') THEN _resignationstatus
            ELSE (SELECT itemstatusid FROM itemstatus WHERE lower(status) = 'pending') END,
            '[]'::jsonb,
            CASE
            WHEN ec.departmentid = (
                SELECT roleid
                FROM org_hierarchy
                WHERE isdepartment = true AND lower(rolename) = 'human resources'
                LIMIT 1
            ) OR lower(ec.rolename) = 'reporting manager'
            THEN TRUE ELSE FALSE END,
            timezone('utc', now())
        FROM employee_exit_configuration ec;

        _processingresult := 'inserted';
    ELSE
        UPDATE employee_notice_period SET
            resigntype = _resigntype,
            resignationstatus = _resignationstatus,
            approvedon = _approvedon,
            attachmentpath = _attachmentpath,
            officiallastworkingday = _officiallastworkingday,
            employeecomment = _employeecomment,
            requestedlastworkingday = _requestedlastworkingday,
            updatedby = _createdby,
            updatedon = timezone('utc', now())
        WHERE employeenoticeperiodid = _employeenoticeperiodid;
        
        _processingresult := 'updated';
    END IF;

    _response := jsonb_build_object(
        'status', _processingresult,
        'employeenoticeperiodid', _employeenoticeperiodid
    );

    RETURN _response;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_exit_initiate_by_admin'::varchar, 1, 0, _result);
    RETURN json_build_object('error', _message)::jsonb;
END;
$function$;
