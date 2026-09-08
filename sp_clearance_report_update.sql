CREATE OR REPLACE PROCEDURE public.sp_clearance_report_update(
  IN _clearancereportid bigint,
  IN _comments jsonb,
  IN _approverid bigint,
  IN _clearancedepartmentdetailid integer,
  OUT _processingresult varchar(500)
)
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _status bigint;
BEGIN
  begin
 _status := 0;
 select 
 case 
 when 
 (select count(distinct featureid) 
 from clearance_feature 
 where clearancedepartmentdetailid = _clearancedepartmentdetailid)
 =
 (select count(distinct csfv.featureid) 
 from clearance_submitted_feature_values csfv
 inner join clearance_feature cf 
 on cf.featureid = csfv.featureid
 where cf.clearancedepartmentdetailid = _clearancedepartmentdetailid)
 then (select itemstatusid from itemstatus where lower(status) = 'approved')
 else (select itemstatusid from itemstatus where lower(status) = 'pending')
 end into _status;
 update clearance_report set
 comments = _comments,
 clearancestatus = _status,
 updatedby = _approverid,
 updatedon = timezone('utc', now()),
 approverid = case 
 when _status = 9 then _approverid 
 else _approverid 
 end,
 approveron = case 
 when _status = 9 then timezone('utc', now()) 
 else timezone('utc', now())
 end
 where clearancereportid = _clearancereportid;
 _processingresult := 'updated';
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_clearance_report_update', 1::bit, 0::bit, _result);
END;
$$;
