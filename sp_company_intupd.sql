CREATE OR REPLACE PROCEDURE public.sp_company_intupd(
  IN _companyid integer,
  IN _organizationid integer,
  IN _organizationname varchar(250),
  IN _companyname varchar(150),
  IN _companydetail varchar(250),
  IN _sectortype integer,
  IN _country varchar(50),
  IN _state varchar(100),
  IN _city varchar(100),
  IN _firstaddress varchar(100),
  IN _secondaddress varchar(100),
  IN _thirdaddress varchar(100),
  IN _forthaddress varchar(100),
  IN _fulladdress varchar(150),
  IN _mobileno varchar(20),
  IN _email varchar(50),
  IN _firstemail varchar(100),
  IN _secondemail varchar(100),
  IN _thirdemail varchar(100),
  IN _forthemail varchar(100),
  IN _primaryphoneno varchar(20),
  IN _secondaryphoneno varchar(20),
  IN _fax varchar(50),
  IN _pincode integer,
  IN _fileid bigint,
  IN _legaldocumentpath varchar(250),
  IN _legalentity varchar(50),
  IN _typeofbusiness varchar(150),
  IN _incorporationdate timestamp,
  IN _isprimarycompany boolean,
  IN _fixedcomponentsid jsonb,
  IN _bankaccountid integer,
  IN _bankname varchar(100),
  IN _branchcode varchar(20),
  IN _branch varchar(50),
  IN _ifsc varchar(20),
  IN _panno varchar(45),
  IN _gstno varchar(45),
  IN _tradelicenseno varchar(45),
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
  _operationstatus bigint;
BEGIN
  _operationstatus := '';
 begin
 select * from company; 
 if not exists(select 1 from company where companyid = _companyid) then
 begin
 if exists(select 1 from company where lower(companyname) = lower(_companyname)) then
 begin
 select companyid from company 
 where lower(companyname) = lower(_companyname) into _companyid;
 end;
 end if;
 end;
 end if;
 _organizationname := '';
 select organizationname into _organizationname 
 from organization_detail
 where organizationid = _organizationid;
 if not exists(select 1 from company where companyid = _companyid) then
 begin
 insert into company values(
 _companyid,
 _organizationid,
 _organizationname,
 _companyname,
 _companydetail,
 _sectortype,
 _country,
 _state,
 _city,
 _firstaddress,
 _secondaddress,
 _thirdaddress,
 _forthaddress,
 _fulladdress,
 _mobileno,
 _email,
 _firstemail,
 _secondemail,
 _thirdemail,
 _forthemail,
 _primaryphoneno,
 _secondaryphoneno,
 _fax,
 _pincode,
 _fileid,
 _legaldocumentpath,
 _legalentity,
 _typeofbusiness,
 _incorporationdate,
 _panno,
 _gstno,
 _tradelicenseno,
 _isprimarycompany,
 _fixedcomponentsid,
 _adminid,
 null,
 timezone('utc', now()),
 null
 );
 _processingresult := 'inserted';
 end;
 else 
 begin
 update company set
 organizationid = _organizationid,
 organizationname = _organizationname,
 companyname = _companyname,
 companydetail = _companydetail,
 sectortype = _sectortype,
 country = _country,
 state = _state,
 city = _city,
 firstaddress = _firstaddress,
 secondaddress = _secondaddress,
 thirdaddress = _thirdaddress,
 forthaddress = _forthaddress,
 fulladdress = _fulladdress,
 mobileno = _mobileno,
 email = _email,
 firstemail = _firstemail,
 secondemail = _secondemail,
 thirdemail = _thirdemail,
 forthemail = _forthemail,
 primaryphoneno = _primaryphoneno,
 secondaryphoneno = _secondaryphoneno,
 fax = _fax,
 pincode = _pincode,
 fileid = _fileid,
 legaldocumentpath = _legaldocumentpath,
 legalentity = _legalentity,
 typeofbusiness = _typeofbusiness,
 incorporationdate = _incorporationdate,
 panno = _panno,
 gstno = _gstno,
 tradelicenseno = _tradelicenseno,
 isprimarycompany = _isprimarycompany,
 fixedcomponentsid = _fixedcomponentsid,
 updatedby = _adminid,
 updatedon = timezone('utc', now())
 where companyid = _companyid;
 _processingresult := 'updated';
 end;
 end if;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_company_intupd', 1::bit, 0::bit, _result);
END;
$$;
