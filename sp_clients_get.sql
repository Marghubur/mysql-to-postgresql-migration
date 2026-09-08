CREATE OR REPLACE PROCEDURE public.sp_clients_get(
  IN _searchstring varchar(250),
  IN _sortby varchar(50),
  IN _pageindex integer,
  IN _pagesize integer,
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
  begin
 begin
 if(_sortby is null or _sortby = '') then
 _sortby := 'CreatedOn, UpdatedOn Desc';
 end if;
 _selectquery := concat('Select * from (
  Select 
  Row_Number() over(Order by ', _sortby, ') as RowIndex,
  ClientId, 
  ClientName,
  PrimaryPhoneNo,
  Email,
  FirstAddress,
  City,
  OtherEmail_1,
  OtherEmail_2,
  OtherEmail_3,
  OtherEmail_4,
  WorkShiftId,
  Count(1) Over() as Total from clients
  Where ', _searchstring, '
  )T where RowIndex between ', (_pageindex - 1) * _pagesize + 1 ,' and ', (_pageindex * _pagesize));
 
 OPEN _refcur FOR EXECUTE _selectquery;end;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_clients_get', 1::bit, 0::bit, _result);
END;
$$;
