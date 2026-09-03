-- DROP PROCEDURE public.sp_employee_declaration_insupd(in int8, in int8, in varchar, in text, in jsonb, in numeric, in numeric, in numeric, in int4, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_employee_declaration_insupd(
    IN _employeedeclarationid bigint, 
    IN _employeeid bigint, 
    IN _documentpath character varying, 
    IN _declarationdetail text, 
    IN _houserentdetail jsonb, 
    IN _totaldeclaredamount numeric, 
    IN _totalapprovedamount numeric, 
    IN _totalrejectedamount numeric, 
    IN _employeecurrentregime integer, 
    OUT _processingresult character varying
)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;
    _endmonth bigint;
    _startmonth bigint;
    _financialstartyear bigint;
BEGIN
    -- Fallback to default tax regime if none provided
    IF (_employeecurrentregime = 0 OR _employeecurrentregime IS NULL) THEN
        SELECT taxregimedescid INTO _employeecurrentregime 
        FROM tax_regime_desc
        WHERE isdefaultregime = 1 
        LIMIT 1;
        
        IF _employeecurrentregime IS NULL THEN
            _employeecurrentregime := 0;
        END IF;
    END IF;
    
    -- Check if declaration record exists by ID
    IF NOT EXISTS (SELECT 1 FROM employee_declaration WHERE employeedeclarationid = _employeedeclarationid) THEN
        _startmonth := 0;
        _endmonth := 0;
        _financialstartyear := 0;
        
        -- Fetch primary company settings for declaration bounds
        SELECT 
            declarationstartmonth,
            declarationendmonth,
            financialyear 
        INTO _startmonth, _endmonth, _financialstartyear
        FROM company_setting
        WHERE isprimary = true 
        LIMIT 1;
        
        -- Insert new declaration record
        INSERT INTO employee_declaration (
            employeeid,
            documentpath,
            declarationdetail,
            houserentdetail,
            totaldeclaredamount,
            totalapprovedamount,
            totalrejectedamount,
            employeecurrentregime,
            declarationstartmonth,
            declarationendmonth,
            declarationfromyear,
            declarationtoyear
        ) VALUES (
            _employeeid,
            _documentpath,
            _declarationdetail,
            _houserentdetail,
            _totaldeclaredamount,
            _totalapprovedamount,
            _totalrejectedamount,
            _employeecurrentregime,
            _startmonth,
            _endmonth,
            _financialstartyear,
            _financialstartyear + 1
        ); 
        
        _processingresult := 'inserted';
    ELSE
        -- Update existing record based on conditions
        IF (_houserentdetail IS NOT NULL AND _totaldeclaredamount > 0 AND _totalapprovedamount > 0) THEN
            UPDATE employee_declaration SET
                declarationdetail = _declarationdetail,
                documentpath = _documentpath,
                houserentdetail = _houserentdetail,
                totaldeclaredamount = _totaldeclaredamount,
                totalapprovedamount = _totalapprovedamount,
                totalrejectedamount = (_totaldeclaredamount - _totalapprovedamount),
                employeecurrentregime = _employeecurrentregime
            WHERE employeedeclarationid = _employeedeclarationid;
            
        ELSIF (_houserentdetail IS NOT NULL) THEN
            UPDATE employee_declaration SET
                declarationdetail = _declarationdetail,
                documentpath = _documentpath,
                houserentdetail = _houserentdetail,
                employeecurrentregime = _employeecurrentregime
            WHERE employeedeclarationid = _employeedeclarationid;
            
        ELSIF (_totaldeclaredamount > 0 AND _totalapprovedamount > 0) THEN
            UPDATE employee_declaration SET
                declarationdetail = _declarationdetail,
                documentpath = _documentpath,
                totaldeclaredamount = _totaldeclaredamount,
                totalapprovedamount = _totalapprovedamount,
                totalrejectedamount = (_totaldeclaredamount - _totalapprovedamount),
                employeecurrentregime = _employeecurrentregime
            WHERE employeedeclarationid = _employeedeclarationid;
            
        ELSE
            UPDATE employee_declaration SET
                declarationdetail = _declarationdetail,
                employeecurrentregime = _employeecurrentregime
            WHERE employeedeclarationid = _employeedeclarationid;
        END IF;
        
        _processingresult := 'updated';
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_declaration_insupd'::varchar, 1, 0, _result);
    _processingresult := _message;
END;
$procedure$;
