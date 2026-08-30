-- DROP PROCEDURE public.sp_employees_personaldetail_upd(in int8, in varchar, in varchar, in varchar, in int8, in int4, in timestamp, in varchar, in varchar, in varchar, in bit, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in varchar, in bit, in varchar, in varchar, in varchar, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_employees_personaldetail_upd(IN _employeeuid bigint, IN _fathername character varying, IN _mothername character varying, IN _spousename character varying, IN _adminid bigint, IN _maritalstatus integer, IN _marriagedate timestamp without time zone, IN _countryoforigin character varying, IN _religion character varying, IN _bloodgroup character varying, IN _isphchallanged bit, IN _emergencycontactname character varying, IN _relationship character varying, IN _emergencymobileno character varying, IN _emergencycountry character varying, IN _emergencystate character varying, IN _emergencycity character varying, IN _emergencypincode integer, IN _emergencyaddress character varying, IN _isinternationalemployee bit, IN _domain character varying, IN _specification character varying, IN _profilestatuscode character varying, OUT _processingresult character varying)
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
 
 if exists (select 1 from employeepersonaldetail where employeeuid = _employeeuid) then
 begin
 -- sql_safe_updates ignored
 
 update employeepersonaldetail set
 fathername = _fathername,
 maritalstatus = _maritalstatus,
 marriagedate = _marriagedate,
 countryoforigin = _countryoforigin,
 religion = _religion,
 bloodgroup = _bloodgroup,
 isphchallanged = _isphchallanged,
 spousename = _spousename,
 mothername = _mothername,
 emergencycontactname = _emergencycontactname,
 relationship = _relationship,
 emergencymobileno = _emergencymobileno,
 emergencycountry = _emergencycountry,
 emergencystate = _emergencystate,
 emergencycity = _emergencycity,
 emergencypincode = _emergencypincode,
 emergencyaddress = _emergencyaddress,
 updatedby = _adminid, 
 updatedon = timezone('utc', now())
 where employeeuid = _employeeuid;
 
 update employeeprofessiondetail set
 isinternationalemployee = _isinternationalemployee,
 domain = _domain,
 specification = _specification,
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
    CALL sp_logexception(_message, '', 'sp_employees_personaldetail_upd', 1, 0, _result);
END;
$procedure$
;
