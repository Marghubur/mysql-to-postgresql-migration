-- DROP FUNCTION public.sp_employees_addupdate_remote_client(int8, int8, int8, numeric, numeric, numeric, bit, int4, int4, timestamp, timestamp);

CREATE OR REPLACE FUNCTION public.sp_employees_addupdate_remote_client(_employeemappedclientsuid bigint, _employeeuid bigint, _clientuid bigint, _finalpackage numeric, _actualpackage numeric, _takehome numeric, _ispermanent bit, _billinghours integer, _daysperweek integer, _dateofleaving timestamp without time zone, _assignedate timestamp without time zone)
 RETURNS SETOF employeemappedclients
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR; 
    _clientname TEXT;
    _empmappedid bigint;
BEGIN
    _clientname := '';
    select clientname from clients where clientid = _clientuid into _clientname;
    
    begin
        if exists(select 1 from employeemappedclients where employeemappedclientsuid = _employeemappedclientsuid) then 
            if (_dateofleaving is null) then
                update employeemappedclients set 
                    clientuid = _clientuid, 
                    clientname = _clientname, 
                    finalpackage = _finalpackage, 
                    actualpackage = _actualpackage, 
                    takehomebycandidate = _takehome, 
                    ispermanent = _ispermanent,
                    billinghours = _billinghours,
                    daysperweek = _daysperweek,
                    assignedate = _assignedate
                where employeemappedclientsuid = _employeemappedclientsuid;
            else
                update employeemappedclients set 
                    clientuid = _clientuid, 
                    clientname = _clientname, 
                    finalpackage = _finalpackage, 
                    actualpackage = _actualpackage, 
                    takehomebycandidate = _takehome, 
                    ispermanent = _ispermanent,
                    billinghours = _billinghours,
                    daysperweek = _daysperweek,
                    dateofleaving = _dateofleaving,
                    assignedate = _assignedate
                where employeemappedclientsuid = _employeemappedclientsuid;
            end if;
        else
            _empmappedid := COALESCE((select max(employeemappedclientsuid) from employeemappedclients), 0);
            _empmappedid := _empmappedid + 1;

            insert into employeemappedclients values(
                _empmappedid, 
                _employeeuid, 
                _clientuid, 
                _clientname, 
                _finalpackage, 
                _actualpackage, 
                _takehome, 
                _ispermanent,
                1,
                _billinghours,
                _daysperweek,
                timezone('utc', now()),
                null,
                _assignedate
            );
        end if;
    end;
 
    RETURN QUERY select * from employeemappedclients 
    where employeeuid = _employeeuid and isactive = 1;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employees_addupdate_remote_client'::varchar, 1, 0, _result);
END;
$function$
;
