-- Drop old versions to prevent parameter conflicts
DROP PROCEDURE IF EXISTS public.sp_employees_professionaldetail_upd(bigint, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, timestamp, varchar, varchar, bit, bit, bit, varchar, bit, bigint);

CREATE OR REPLACE PROCEDURE public.sp_employees_professionaldetail_upd(
    IN _employeeuid bigint, 
    IN _panno character varying, 
    IN _aadharno character varying, 
    IN _accountnumber character varying, 
    IN _bankname character varying, 
    IN _branchname character varying, 
    IN _ifsccode character varying, 
    IN _bankaccounttype character varying, 
    IN _pfnumber character varying, 
    IN _pfaccountcreationdate timestamp without time zone, 
    IN _uan character varying, 
    IN _esiserialnumber character varying, 
    IN _isemployeeeligibleforpf boolean,      -- FIXED: changed from bit
    IN _isexistingmemberofpf boolean,         -- FIXED: changed from bit
    IN _isemployeeeligibleforesi boolean,     -- FIXED: changed from bit
    IN _profilestatuscode character varying, 
    IN _isptaxenable boolean,                 -- FIXED: changed from bit
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
    _result character varying;                -- FIXED: Matched to logger OUT param
    _employeepfdetailid bigint;
BEGIN
    -- 1. Update Profession Details if they exist
    if exists (select 1 from employeeprofessiondetail where employeeuid = _employeeuid) then
        update employeeprofessiondetail set
            panno = _panno,
            aadharno = _aadharno,
            accountnumber = _accountnumber,
            ifsccode = _ifsccode,
            branchname = _branchname,
            bankaccounttype = _bankaccounttype,
            bankname = _bankname,
            profilestatuscode = _profilestatuscode,
            updatedby = _adminid,
            updatedon = timezone('utc', now())
        where employeeuid = _employeeuid;
    end if;

    -- 2. Insert or Update PF Details
    if not exists (select 1 from employee_pf_detail where employeeid = _employeeuid) then
        
        -- FIXED: Added coalesce and null check to prevent crash on first insert
        select coalesce(employeepfdetailid, 0) into _employeepfdetailid 
        from employee_pf_detail
        order by employeepfdetailid desc limit 1;
        
        if _employeepfdetailid is null then
            _employeepfdetailid := 0;
        end if;
        
        _employeepfdetailid := _employeepfdetailid + 1;

        insert into employee_pf_detail values(
            _employeepfdetailid,
            _employeeuid,
            _isemployeeeligibleforpf,
            _isexistingmemberofpf,
            _pfnumber,
            _uan,
            _esiserialnumber,
            _isemployeeeligibleforesi,
            _pfaccountcreationdate,
            _isptaxenable
        );

        _processingresult := 'inserted';
    else
        update employee_pf_detail set
            pfnumber = _pfnumber,
            universalaccountnumber = _uan,
            esiserialnumber = _esiserialnumber,
            pfjoindate = _pfaccountcreationdate,
            isemployeeeligibleforpf = _isemployeeeligibleforpf,
            isexistingmemberofpf = _isexistingmemberofpf,
            isemployeeeligibleforesi = _isemployeeeligibleforesi,
            isptaxenable = _isptaxenable
        where employeeid = _employeeuid;
        
        _processingresult := 'updated';
    end if;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    -- FIXED: Added ::varchar casts so the logger doesn't crash
    CALL sp_logexception(_message, ''::varchar, 'sp_employees_professionaldetail_upd'::varchar, 1, 0, _result);
END;
$procedure$;
