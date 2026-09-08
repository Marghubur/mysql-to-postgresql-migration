CREATE OR REPLACE PROCEDURE public.sp_catagory_insupd(
  IN _categoryid integer,
  IN _groupid integer,
  IN _categorycode varchar(45),
  IN _categorydescription varchar(500),
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
 if not exists (select * from catagory where categoryid = _categoryid) then
 begin
 _categoryid := 0;
 select categoryid from catagory order by categoryid desc limit 1 into _categoryid ;
 _categoryid := _categoryid+1;
 insert into catagory values (
 _categoryid, 
 _groupid,
 _categorycode,
 _categorydescription
 );
 _processingresult := 'inserted';
 end;
 else
 begin
 update catagory set 
 groupid = _groupid,
 categorycode = _categorycode,
 categorydescription = _categorydescription
 where categoryid = _categoryid;
 
 _processingresult := 'updated';
 end;
 end if;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_catagory_insupd', 1::bit, 0::bit, _result);
END;
$$;
