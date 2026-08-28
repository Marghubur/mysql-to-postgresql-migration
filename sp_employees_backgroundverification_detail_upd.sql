 DROP PROCEDURE public.sp_employees_backgroundverification_detail_upd(in int8, in varchar, in varchar, in varchar, in varchar, in int8, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_employees_backgroundverification_detail_upd(IN _employeeuid bigint, IN _agencyname character varying, IN _verificationstatus character varying, IN _verificationremark character varying, IN _profilestatuscode character varying, IN _adminid bigint, OUT _processingresult character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result TEXT;
BEGIN
    begin
 
 if exists (select 1 from employeeprofessiondetail where employeeuid = _employeeuid) then
 begin
 -- sql_safe_updates ignored
 update employeeprofessiondetail set
 agencyname = _agencyname,
 verificationstatus = _verificationstatus,
 verificationremark = _verificationremark,
 profilestatuscode = _profilestatuscode,
 updatedby = _adminid, 
 updatedon = timezone('utc', now())
 where employeeuid = _employeeuid;
 -- sql_safe_updates ignored
 
 _processingresult := 'updated';
 end;
 end if;
 end;
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    CALL sp_logexception(_message, '', 'sp_employees_backgroundverification_detail_upd', 1, 0, _result);
END;
$procedure$
;
