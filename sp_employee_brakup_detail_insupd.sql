CREATE OR REPLACE PROCEDURE public.sp_employee_brakup_detail_insupd(
    IN _employeeid bigint, 
    IN _breakupdetail jsonb, 
    IN _breakupheadercount integer, 
    IN _deductiondetail jsonb, 
    IN _deductionheadercount integer, 
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
    -- FIXED: Removed invalid assignment to unused bigint variable (_operationstatus)
    
    IF NOT EXISTS(SELECT 1 FROM employee_brakup_detail WHERE employeeid = _employeeid) THEN
        INSERT INTO employee_brakup_detail VALUES (
            _employeeid,
            _breakupdetail,
            _breakupheadercount,
            _deductiondetail,
            _deductionheadercount,
            timezone('utc', now()) -- FIXED: Replaced non-standard utc_date() with PostgreSQL equivalent
        );
        
        _processingresult := 'inserted';
    ELSE
        UPDATE employee_brakup_detail SET 
            breakupdetail = _breakupdetail,
            breakupheadercount = _breakupheadercount,
            deductiondetail = _deductiondetail,
            deductionheadercount = _deductionheadercount,
            updatedon = timezone('utc', now()) -- FIXED: Replaced non-standard utc_date()
        WHERE employeeid = _employeeid;
        
        _processingresult := 'updated';
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    -- FIXED: Added ::varchar casts to prevent logger crashes
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_brakup_detail_insupd'::varchar, 1, 0, _result);
    _processingresult := _message;
END;
$procedure$;
