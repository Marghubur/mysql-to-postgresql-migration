-- DROP PROCEDURE public.sp_employees_nominee_ins_upd(in int8, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in numeric, in bit, in int4, in varchar, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_employees_nominee_ins_upd(IN _employeeid bigint, IN _nomineename character varying, IN _nomineerelationship character varying, IN _nomineemobile character varying, IN _nomineeemail character varying, IN _nomineedob timestamp without time zone, IN _nomineeaddress character varying, IN _percentageshare numeric, IN _isprimarynominee bit, IN _nomineeid integer, IN _profilestatuscode character varying, OUT _processingresult character varying)
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
 
 
 if not exists (select 1 from nominee_detail where employeeid = _employeeid) then
 begin
 _nomineeid := 0;
 select nomineeid into _nomineeid from nominee_detail 
 order by nomineeid desc limit 1;
 _nomineeid := _nomineeid + 1;

 insert into nominee_detail values(
 _nomineeid,
 _employeeid,
 _nomineename,
 _nomineerelationship,
 _nomineemobile,
 _nomineeemail,
 _nomineedob,
 _nomineeaddress,
 _percentageshare,
 _isprimarynominee,
 timezone('utc', now()),
 null
 );
 
 -- sql_safe_updates ignored
 update employeeprofessiondetail set
 profilestatuscode = _profilestatuscode
 where employeeuid = _employeeid;
 -- sql_safe_updates ignored
 
 _processingresult := 'inserted';
 end;
 else
 begin
 -- sql_safe_updates ignored
 update nominee_detail set
 nomineename = _nomineename,
 nomineerelationship = _nomineerelationship,
 nomineemobile = _nomineemobile,
 nomineeemail = _nomineeemail,
 nomineedob = _nomineedob,
 nomineeaddress = _nomineeaddress,
 percentageshare = _percentageshare,
 isprimarynominee = _isprimarynominee,
 updatedon = timezone('utc', now())
 where employeeid = _employeeid;
 end;
 -- sql_safe_updates ignored
 
 _processingresult := 'updated';
 end if;
 end;
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    CALL sp_logexception(_message, '', 'sp_employees_nominee_ins_upd', 1, 0, _result);
END;
$procedure$
;
