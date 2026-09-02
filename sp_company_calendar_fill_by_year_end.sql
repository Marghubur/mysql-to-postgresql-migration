CREATE OR REPLACE PROCEDURE public.sp_company_calendar_fill_by_year_end(
  IN _companyid integer,
  IN _userid bigint,
  IN _calendaryear integer
)
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _enddate TEXT;
  _startdate TEXT;
BEGIN
  _startdate := cast(concat(_calendaryear - 1, '-12-31 18:30:00') as timestamp);
 _enddate := cast(concat(_calendaryear, '-12-29 18:30:00') as timestamp);
 insert into company_calendar (
 companyid, 
 calendardate,
 eventid, 
 isholiday, 
 holidayname,
 ishalfday, 
 dayofweeknumber, 
 dayofweek, 
 descriptionnote, 
 departmentid, 
 year, 
 ispublicholiday, 
 createdby, 
 updatedby, 
 createdon, 
 updatedon
 )
 with recursive calendar as (
 select _startdate as cal_date
 union all
 select cal_date + (1) * interval '1 day' 
 from calendar 
 where cal_date < _enddate
 )
 select 
 _companyid as companyid, 
 cal_date as calendardate,
 null as eventid, 
 b'0' as isholiday, 
 null as holidayname,
 b'0' as ishalfday, 
 case 
 when dayofweek(cal_date) = 1 then 7 
 else dayofweek(cal_date) - 1 
 end as dayofweeknumber,
 dayname(cal_date) as dayofweek,
 null as descriptionnote, 
 0 as departmentid, 
 year(cal_date) as year,
 b'0' as ispublicholiday, 
 _userid as createdby, 
 _userid as updatedby, 
 cal_date as createdon, 
 cal_date as updatedon 
 from calendar;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_company_calendar_fill_by_year_end', 1::bit, 0::bit, _result);
END;
$$;
