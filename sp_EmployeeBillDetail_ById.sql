-- DROP FUNCTION public.sp_employeebilldetail_byid(int8, int8, int8, int4, timestamp, timestamp, int4);

CREATE OR REPLACE FUNCTION public.sp_employeebilldetail_byid(_employeeid bigint, _clientid bigint, _fileid bigint, _foryear integer, _firstdate timestamp without time zone, _lastdate timestamp without time zone, _companyid integer)
 RETURNS SETOF billdetail
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result TEXT;
    _financialyear bigint;
BEGIN
    begin
 
        RETURN QUERY select b.* from billdetail b
        where b.employeeuid = _employeeid 
        and b.clientid = _clientid
        and b.filedetailid = _fileid;
        
        _financialyear := 0;
        select financialyear into _financialyear from company_setting
        where isprimary = true;
        
        -- THE CALL IS NOW COMMENTED OUT:
        -- CALL sp_employee_getall(concat(' 1=1 and emp.EmployeeUid = ', _employeeid), null, 1, 10, _financialyear);
 
    end;
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    -- Ensure you are either logging or raising the exception properly:
    RAISE EXCEPTION 'Error in sp_employeebilldetail_byid: %', _message;
END;
$function$
;
