CREATE OR REPLACE PROCEDURE public.sp_deductions_detail_insupd(
  IN _deductionid integer,
  IN _deductiondescription varchar(100),
  IN _ispaidbyemployee bit,
  IN _ispaidbyemployeer bit,
  IN _ismandatory bit,
  IN _isfixedamount bit,
  IN _admin bigint,
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
  _operationstatus bigint;
BEGIN
  _operationstatus := '';
 begin
 
 if not exists(select 1 from deductions_detail where deductionid = _deductionid) then
 begin
 insert into deductions_detail
 values(
 default,
 _deductiondescription,
 _ispaidbyemployee,
 _ispaidbyemployeer,
 _ismandatory,
 _isfixedamount,
 timezone('utc', now()),
 null,
 _admin,
 null
 );
 _processingresult := 'inserted';
 end;
 else
 begin
 update deductions_detail set 
 deductiondescription = _deductiondescription,
 ispaidbyemployee = _ispaidbyemployee,
 ispaidbyemployeer = _ispaidbyemployeer,
 ismandatory = _ismandatory,
 isfixedamount = _isfixedamount,
 updatedby = _admin,
 updatedon = timezone('utc', now())
 where deductionid = _deductionid;
 _processingresult := 'updated';
 end;
 end if;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_deductions_detail_insupd', 1::bit, 0::bit, _result);
END;
$$;
