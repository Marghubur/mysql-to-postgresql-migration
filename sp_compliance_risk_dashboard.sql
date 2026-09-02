CREATE OR REPLACE PROCEDURE public.sp_compliance_risk_dashboard(
  IN _searchstring varchar(250),
  IN _sortby varchar(50),
  IN _clientid integer,
  IN _frommonth integer,
  IN _fromyear integer,
  IN _tomonth integer,
  IN _toyear integer,
  IN _vendorid integer,
  IN _subvendorid integer,
  IN _fromduedate date,
  IN _toduedate date,
    INOUT _refcur refcursor DEFAULT 'cur_result'
)
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _todate TEXT;
  _fromdate TEXT;
  _duedatefilterinner TEXT;
  _selectquery TEXT;
BEGIN
  if (_sortby is null or _sortby = '') then
 _sortby := 'cra.ComplianceRiskActId';
 end if;
 _fromdate := null;
 _todate := null;
 _fromdate := str_to_date(
 concat(_fromyear, '-', lpad(_frommonth,2,'0'), '-01'),
 '%Y-%m-%d'
 );
 _todate := last_day(
 str_to_date(
 concat(_toyear, '-', lpad(_tomonth,2,'0'), '-01'),
 '%Y-%m-%d'
 )
 );
 
 _duedatefilterinner := '';
 
 if _fromduedate is not null then
 _duedatefilterinner := concat(_duedatefilterinner,
 ' AND STR_TO_DATE(
  CONCAT(
  YEAR(DATE_ADD(mr.PeriodDate, INTERVAL 1 MONTH)),
  ''-'',
  LPAD(MONTH(DATE_ADD(mr.PeriodDate, INTERVAL 1 MONTH)),2,''0''),
  ''-'',
  LPAD(IFNULL(c.DueDate,1),2,''0'')
  ),
  ''%Y-%m-%d''
  ) >= ''', _fromduedate, ''''
 );
 end if;
 
 if _toduedate is not null then
 _duedatefilterinner := concat(_duedatefilterinner,
 ' AND STR_TO_DATE(
  CONCAT(
  YEAR(DATE_ADD(mr.PeriodDate, INTERVAL 1 MONTH)),
  ''-'',
  LPAD(MONTH(DATE_ADD(mr.PeriodDate, INTERVAL 1 MONTH)),2,''0''),
  ''-'',
  LPAD(IFNULL(c.DueDate,1),2,''0'')
  ),
  ''%Y-%m-%d''
  ) <= ''', _toduedate, ''''
 );
 end if;
 _selectquery := concat(
 '
  WITH RECURSIVE month_range AS (
  SELECT
  YEAR(''', _fromdate, ''') AS Year,
  MONTH(''', _fromdate, ''') AS Month,
  ''' , _fromdate , ''' AS PeriodDate
  UNION ALL
  SELECT
  YEAR(DATE_ADD(PeriodDate, INTERVAL 1 MONTH)),
  MONTH(DATE_ADD(PeriodDate, INTERVAL 1 MONTH)),
  DATE_ADD(PeriodDate, INTERVAL 1 MONTH)
  FROM month_range
  WHERE DATE_ADD(PeriodDate, INTERVAL 1 MONTH) < ''' , _todate , '''
  )
  SELECT * FROM (
  SELECT
  ROW_NUMBER() OVER (ORDER BY ', _sortby, ') AS RowIndex,
  cra.ComplianceRiskActId,
  cra.ActName,
  cra.DocumentName,
  cra.DocumentSeverity,
  cra.AllowedFormat,
  cra.DocumentDescription,
  mr.Month,
  mr.Year,
  cr.ComplianceRiskId,
  cr.AuditBy,
  COALESCE(cr.Status, 0) AS StatusId,
  cr.FileIds,
  cr.Comment,
  cr.AuditorComment,
  cr.AuditorQuestionnaire,
  c.Name AS ClientName,
  c.ClientId,
  c.StateName,
  c.City,
  c.Location,
  c.Site,
  v.Name AS VendorName,
  v.ClientId AS VendorId,
  sv.Name AS SubVendorName,
  sv.ClientId AS SubVendorId,
  DATE_FORMAT(mr.PeriodDate, ''%b-%Y'') AS Period,
  DATE_ADD(
  DATE_ADD(mr.PeriodDate, INTERVAL 1 MONTH),
  INTERVAL
  LEAST(
  IFNULL(c.DueDate, DAY(LAST_DAY(DATE_ADD(mr.PeriodDate, INTERVAL 1 MONTH)))),
  DAY(LAST_DAY(DATE_ADD(mr.PeriodDate, INTERVAL 1 MONTH)))
  ) - 1 DAY
  ) AS DueDateCalc,
  DATE_FORMAT(
  DATE_ADD(
  DATE_ADD(mr.PeriodDate, INTERVAL 1 MONTH),
  INTERVAL
  LEAST(
  IFNULL(c.DueDate, DAY(LAST_DAY(DATE_ADD(mr.PeriodDate, INTERVAL 1 MONTH)))),
  DAY(LAST_DAY(DATE_ADD(mr.PeriodDate, INTERVAL 1 MONTH)))
  ) - 1 DAY
  ),
  ''%d-%b-%Y''
  ) AS DueDate,
  COUNT(1) OVER() AS Total
  FROM compliance_risk_acts cra
  CROSS JOIN month_range mr
  LEFT JOIN compliance_risks cr
  ON cr.ComplianceRiskActId = cra.ComplianceRiskActId
  AND cr.ClientId = ', coalesce(_clientid,0), '
  AND cr.Month = mr.Month
  AND cr.Year  = mr.Year
  LEFT JOIN compliance_client c
  ON c.ClientId = ', coalesce(_clientid,0), '
  LEFT JOIN compliance_client v
  ON v.ClientId = ', coalesce(_vendorid,0), '
  AND v.ParentId = c.ClientId
  LEFT JOIN compliance_client sv
  ON sv.ClientId = ', coalesce(_subvendorid,0), '
  AND sv.ParentId = v.ClientId
  WHERE ', _searchstring, '
  AND (
  cra.DocumentType = 1
  OR (
  cra.DocumentType = 2
  AND (
  cra.Month = -1
  OR cra.Month = mr.Month
  )
  )
  )
  ', _duedatefilterinner, '
  ) t '
 );
 OPEN _refcur FOR EXECUTE _selectquery;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_compliance_risk_dashboard', 1::bit, 0::bit, _result);
END;
$$;
