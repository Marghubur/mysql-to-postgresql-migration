CREATE OR REPLACE PROCEDURE public.sp_default_reporting_manager_ins_upd(
  IN _defaultreportingmanagerid integer,
  IN _employeeid bigint,
  IN _departmentid integer,
  OUT _processingresult varchar(100)
)
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
BEGIN
  if not exists(select * from default_reporting_manager where defaultreportingmanagerid = _defaultreportingmanagerid) then
 begin
 insert into default_reporting_manager values(
 _defaultreportingmanagerid,
 _employeeid,
 _departmentid
 );
 _processingresult := 'inserted';
 end;
 else
 begin
 update default_reporting_manager set
 employeeid = _employeeid,
 departmentid = _departmentid
 where defaultreportingmanagerid = _defaultreportingmanagerid;
 _processingresult := 'updated';
 end;
 end if;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_default_reporting_manager_ins_upd', 1::bit, 0::bit, _result);
END;
$$;
