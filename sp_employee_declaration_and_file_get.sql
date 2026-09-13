DROP PROCEDURE IF EXISTS public.sp_employee_declaration_and_file_get(bigint, bigint, refcursor);

CREATE OR REPLACE PROCEDURE public.sp_employee_declaration_and_file_get(
    _declarationid bigint, 
    _fileid bigint,
    INOUT _result_ref refcursor DEFAULT 'rs_declaration_and_file'
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;
BEGIN
    OPEN _result_ref FOR 
        SELECT 
            d.employeedeclarationid,
            d.employeeid,
            d.documentpath,
            d.declarationdetail,
            d.houserentdetail,
            d.totaldeclaredamount
        FROM employee_declaration d
        WHERE d.employeedeclarationid = _declarationid;
        
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_declaration_and_file_get'::varchar, 1, 0, _result);
END;
$procedure$;
