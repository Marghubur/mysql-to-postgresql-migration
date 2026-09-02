CREATE OR REPLACE FUNCTION public.sp_dashboard_get(
  IN _userid bigint,
  IN _employeeuid bigint,
  IN _fromdate timestamp,
  IN _todate timestamp
)
RETURNS SETOF "billdetail"
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _workingyear bigint;
  _workingmonth bigint;
  _operationstatus bigint;
BEGIN
  _operationstatus := '';
 begin
 
 _workingmonth := month(utc_date());
 _workingyear := year(utc_date());
 if (_workingmonth = 1) then
 _workingyear := _workingyear - 1;
 end if;
 _workingmonth := _workingmonth - 1;
 
 RETURN QUERY select 
 e.firstname,
 e.lastname,
 e.email,
 e.mobile,
 c.clientname,
 c.clientid,
 b.paidamount,
 b.billdetailuid,
 b.billformonth,
 b.billyear,
 b.paidon,
 b.billno,
 b.billupdatedon,
 b.billstatusid
 from billdetail b 
 inner join employees e on b.employeeuid = e.employeeuid
 left join clients c on b.clientid = c.clientid
 where b.billstatusid = 2 and 
 b.billformonth = _workingmonth and 
 b.billyear = _workingyear
 and e.isactive = true;
 
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select 
 g.gstid, 
 g.billno, 
 g.amount, 
 c.clientname, 
 c.clientid, 
 b.employeeuid,
 b.billstatusid
 from gstdetail g
 inner join billdetail b on g.billno = b.billno
 inner join clients c on c.clientid = b.clientid
 where g.gststatus = 2 and 
 b.billyear = year(utc_date());
 
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from attendance a
 where a.formonth = month(utc_date())
 and a.foryear = year(utc_date()) and
 a.dayspending != 0;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select b.paidamount, b.billformonth, count(b.paidamount) totalbills from billdetail b
 where b.billyear = year(utc_date())
 group by b.billformonth;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_dashboard_get', 1::bit, 0::bit, _result);
END;
$$;
