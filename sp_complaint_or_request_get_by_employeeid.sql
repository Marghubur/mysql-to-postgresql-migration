CREATE OR REPLACE PROCEDURE public.sp_complaint_or_request_get_by_employeeid(
  IN _searchstring varchar(500),
  IN _sortby varchar(50),
  IN _pagesize integer,
  IN _pageindex integer,
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
  _selectquery TEXT;
BEGIN
  if(_sortby is null or _sortby = '') then
 _sortby := 'AttendanceDate desc, UpdatedOn desc';
 end if;
 _selectquery := concat('Select * from (
  Select 
  Row_Number() over(Order by ', _sortby, ') as RowIndex,
  ComplaintOrRequestId,
  RequestTypeId,
  TargetId,
  TargetOffset,
  EmployeeId, 
  EmployeeName, 
  Email, 
  Mobile,
  ManagerId,
  ManagerName,
  ManagerEmail,
  ManagerMobile,
  EmployeeMessage,
  ManagerComments,
  CurrentStatus,
  RequestedOn,
  AttendanceDate,
  LeaveFromDate,
  LeaveToDate,
  Notify,
  UpdatedOn,
  Count(1) Over() as Total from complaint_or_request
  Where ', _searchstring, '
  )T where RowIndex between ', ((_pageindex - 1 ) * _pagesize + 1), ' and ', (_pageindex * _pagesize));
 
 OPEN _refcur FOR EXECUTE _selectquery;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_complaint_or_request_get_by_employeeid', 1::bit, 0::bit, _result);
END;
$$;
