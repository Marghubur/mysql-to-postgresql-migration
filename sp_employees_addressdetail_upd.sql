-- DROP PROCEDURE public.sp_employees_addressdetail_upd(in int8, in varchar, in varchar, in int4, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in varchar, in varchar, in int8, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_employees_addressdetail_upd(IN _employeeuid bigint, IN _state character varying, IN _city character varying, IN _pincode integer, IN _address character varying, IN _country character varying, IN _permanentcountry character varying, IN _permanentstate character varying, IN _permanentcity character varying, IN _permanentpincode integer, IN _permanentaddress character varying, IN _profilestatuscode character varying, IN _adminid bigint, OUT _processingresult character varying)
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
 state = _state,
 city = _city,
 pincode = _pincode,
 address = _address,
 country = _country,
 permanentcountry = _permanentcountry,
 permanentstate = _permanentstate,
 permanentcity = _permanentcity,
 permanentpincode = _permanentpincode,
 permanentaddress = _permanentaddress,
 updatedby = _adminid, 
 updatedon = timezone('utc', now())
 where employeeuid = _employeeuid;
 
 update employeeprofessiondetail set
 profilestatuscode = _profilestatuscode
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
    CALL sp_logexception(_message, '', 'sp_employees_addressdetail_upd', 1, 0, _result);
END;
$procedure$
;
