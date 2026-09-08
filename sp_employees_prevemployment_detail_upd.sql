DROP PROCEDURE IF EXISTS public.sp_employees_prevemployment_detail_upd(bigint, varchar, timestamp, timestamp, varchar, varchar, numeric, numeric, varchar, varchar, bigint);

CREATE OR REPLACE PROCEDURE public.sp_employees_prevemployment_detail_upd(
    IN _employeeuid bigint, 
    IN _lastcompanydesignation character varying, 
    IN _workingfromdate timestamp without time zone, 
    IN _workingtodate timestamp without time zone, 
    IN _lastcompanyaddress character varying, 
    IN _lastcompanynatureofduty character varying, 
    IN _lastdrawnsalary numeric, 
    IN _exprienceinyear numeric, 
    IN _lastcompanyname character varying, 
    IN _profilestatuscode character varying, 
    IN _adminid bigint, 
    OUT _processingresult character varying
)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying; -- FIXED: Changed TEXT to character varying
BEGIN
    if exists (select 1 from employeeprofessiondetail where employeeuid = _employeeuid) then
        update employeeprofessiondetail set
            lastcompanydesignation = _lastcompanydesignation,
            workingfromdate = _workingfromdate,
            workingtodate = _workingtodate,
            lastcompanyaddress = _lastcompanyaddress,
            lastcompanynatureofduty = _lastcompanynatureofduty,
            lastdrawnsalary = _lastdrawnsalary,
            exprienceinyear = _exprienceinyear,
            lastcompanyname = _lastcompanyname,
            profilestatuscode = _profilestatuscode,
            updatedby = _adminid, 
            updatedon = timezone('utc', now())
        where employeeuid = _employeeuid;
        
        _processingresult := 'updated';
    else
        -- Added fallback so it doesn't return a blank result
        _processingresult := 'not found';
    end if;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    -- FIXED: Added ::varchar casts so the logger doesn't crash
    CALL sp_logexception(_message, ''::varchar, 'sp_employees_prevemployment_detail_upd'::varchar, 1, 0, _result);
END;
$procedure$;
