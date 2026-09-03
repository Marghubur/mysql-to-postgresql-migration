CREATE OR REPLACE PROCEDURE public.sp_employee_bonus_ins_upd(
    IN _bonusid bigint, 
    IN _employeeid bigint, 
    IN _foryear integer, 
    IN _formonth integer, 
    IN _componentid character varying, 
    IN _amount numeric, 
    IN _comments character varying, 
    IN _statusid integer, 
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
    _result character varying; -- FIXED: Logger variable compatibility
BEGIN
    _processingresult := '';
    
    IF NOT EXISTS(SELECT 1 FROM employee_bonus WHERE bonusid = _bonusid) THEN
        -- If inserting a new record, fetch the max ID or let the sequence handle it
        -- Keeping manual increment logic as provided, with fallback safety
        SELECT COALESCE(MAX(bonusid), 0) + 1 INTO _bonusid FROM employee_bonus;
        
        INSERT INTO employee_bonus VALUES (
            _bonusid,
            _employeeid,
            _foryear,
            _formonth,
            _componentid,
            _amount,
            _comments,
            _statusid,
            _adminid,
            timezone('utc', now()),
            0,
            null
        );
        
        _processingresult := 'inserted';
    ELSE 
        UPDATE employee_bonus SET
            foryear = _foryear,
            formonth = _formonth,
            componentid = _componentid,
            amount = _amount,
            comments = _comments,
            statusid = _statusid,
            updatedby = _adminid,
            updatedon = timezone('utc', now())
        WHERE bonusid = _bonusid;
        
        _processingresult := 'updated';
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    -- FIXED: Added ::varchar casts to prevent logger crashes
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_bonus_ins_upd'::varchar, 1, 0, _result);
    _processingresult := _message;
END;
$procedure$;
