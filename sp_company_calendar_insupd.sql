CREATE OR REPLACE PROCEDURE public.sp_company_calendar_insupd(
  IN _companycalendarid bigint,
  IN _companyid integer,
  IN _calendardate timestamp,
  IN _eventid integer,
  IN _isholiday boolean,
  IN _holidayname varchar(250),
  IN _ishalfday boolean,
  IN _dayofweeknumber integer,
  IN _dayofweek varchar(20),
  IN _descriptionnote text,
  IN _departmentid integer,
  IN _year integer,
  IN _ispublicholiday boolean,
  IN _adminid bigint,
  OUT _processingresult varchar(50)
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
  begin
 begin
 if not exists (select 1 from company_calendar where companycalendarid = _companycalendarid) then
 begin
 _companycalendarid := 0;
 select companycalendarid into _companycalendarid from company_calendar
 order by companycalendarid desc limit 1;
 _companycalendarid := _companycalendarid + 1;
 insert into company_calendar values (
 _companycalendarid,
 _companyid,
 _calendardate,
 _eventid,
 _isholiday,
 _holidayname,
 _ishalfday,
 _dayofweeknumber,
 _dayofweek,
 _descriptionnote,
 _departmentid,
 _year,
 _ispublicholiday,
 _adminid,
 null,
 timezone('utc', now()),
 null
 );
 _processingresult := 'inserted';
 end;
 else
 begin
 update company_calendar set 
 holidayname = _holidayname,
 isholiday = _isholiday,
 ishalfday = _ishalfday,
 descriptionnote = _descriptionnote,
 departmentid = _departmentid,
 ispublicholiday = _ispublicholiday,
 updatedby = _adminid,
 updatedon = timezone('utc', now())
 where companycalendarid = _companycalendarid;
 _processingresult := 'updated';
 end;
 end if;
 end;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_company_calendar_insupd', 1::bit, 0::bit, _result);
END;
$$;
