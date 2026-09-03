CREATE OR REPLACE PROCEDURE public.sp_employee_declaration_ins_new(
    IN _employeeid bigint, 
    IN _financialyear integer, 
    IN _startmonth integer, 
    IN _endmonth integer
)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;
    _jsonarray jsonb;
    _empdecid bigint;
BEGIN
    _empdecid := 0;
    
    SELECT employeedeclarationid INTO _empdecid 
    FROM employee_declaration 
    WHERE employeeid = _employeeid 
      AND declarationfromyear = _financialyear;
    
    -- Proceed only if the declaration does not already exist for this financial year
    IF _empdecid = 0 OR _empdecid IS NULL THEN
        
        -- FIXED: Replaced manual row-by-row WHILE loop and MySQL `if()` syntax 
        -- with efficient PostgreSQL set-based `json_agg` and `CASE WHEN` expressions.
        SELECT COALESCE(json_agg(
            json_build_object(
                'ComponentId', componentid,
                'ComponentFullName', componentfullname,
                'ComponentDescription', componentdescription,
                'CalculateInPercentage', CASE WHEN calculateinpercentage = 1 THEN true ELSE false END,
                'TaxExempt', CASE WHEN taxexempt = 1 THEN true ELSE false END,
                'ComponentTypeId', componenttypeid,
                'PercentageValue', percentagevalue,
                'MaxLimit', maxlimit,
                'DeclaredValue', declaredvalue,
                'Formula', formula,
                'EmployeeContribution', employeecontribution,
                'EmployerContribution', employercontribution,
                'IncludeInPayslip', CASE WHEN includeinpayslip = 1 THEN true ELSE false END,
                'Section', section,
                'SectionMaxLimit', sectionmaxlimit,
                'IsAdHoc', CASE WHEN isadhoc = 1 THEN true ELSE false END,
                'AdHocId', adhocid,
                'IsOpted', CASE WHEN isopted = 1 THEN true ELSE false END,
                'IsActive', CASE WHEN isactive = 1 THEN true ELSE false END
            )
        ), '[]'::jsonb) INTO _jsonarray
        FROM salary_components;

        -- FIXED: Explicitly named target columns and resolved the undeclared 
        -- _declarationdetail variable by mapping the generated component JSON array.
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
            '',
            _jsonarray::text,
            '{}'::jsonb,
            0,
            0,
            0,
            0,
            _startmonth,
            _endmonth,
            _financialyear,
            _financialyear + 1
        ); 
    END IF;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_declaration_ins_new'::varchar, 1, 0, _result);
END;
$procedure$;
