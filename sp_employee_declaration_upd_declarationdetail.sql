DROP FUNCTION IF EXISTS public.sp_employee_declaration_upd_declarationdetail(bigint, bigint, integer);

CREATE OR REPLACE FUNCTION public.sp_employee_declaration_upd_declarationdetail(_employeedeclarationid bigint, _employeeid bigint, _financialyear integer)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;
    _jsonarray jsonb;
    _empdecid bigint;
    _response jsonb;
BEGIN
    _empdecid := 0;
    
    SELECT employeedeclarationid INTO _empdecid 
    FROM employee_declaration 
    WHERE employeeid = _employeeid 
      AND declarationfromyear = _financialyear;
      
    IF _empdecid = 0 OR _empdecid IS NULL THEN
        _empdecid := _employeedeclarationid;
    END IF;

    -- FIXED: Switched to jsonb_agg and jsonb_build_object to resolve the 
    -- COALESCE type mismatch error between json and jsonb types.
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'ComponentId', componentid,
            'ComponentFullName', componentfullname,
            'ComponentDescription', componentdescription,
            'CalculateInPercentage', CASE WHEN calculateinpercentage::text IN ('1', 'true', 't', 'yes') THEN true ELSE false END,
            'TaxExempt', CASE WHEN taxexempt::text IN ('1', 'true', 't', 'yes') THEN true ELSE false END,
            'ComponentTypeId', componenttypeid,
            'PercentageValue', percentagevalue,
            'MaxLimit', maxlimit,
            'DeclaredValue', declaredvalue,
            'Formula', formula,
            'EmployeeContribution', employeecontribution,
            'EmployerContribution', employercontribution,
            'IncludeInPayslip', CASE WHEN includeinpayslip::text IN ('1', 'true', 't', 'yes') THEN true ELSE false END,
            'Section', section,
            'SectionMaxLimit', sectionmaxlimit,
            'IsAdHoc', CASE WHEN isadhoc::text IN ('1', 'true', 't', 'yes') THEN true ELSE false END,
            'AdHocId', adhocid,
            'IsOpted', CASE WHEN isopted::text IN ('1', 'true', 't', 'yes') THEN true ELSE false END,
            'IsActive', CASE WHEN isactive::text IN ('1', 'true', 't', 'yes') THEN true ELSE false END
        )
    ), '[]'::jsonb) INTO _jsonarray
    FROM salary_components;

    -- Update declaration detail with the newly generated JSON components list
    UPDATE employee_declaration 
    SET declarationdetail = _jsonarray::text
    WHERE employeedeclarationid = _empdecid 
       OR (employeeid = _employeeid AND declarationfromyear = _financialyear);

    -- Return structured JSON response confirming the update
    SELECT jsonb_build_object(
        'status', 'updated',
        'employeedeclarationid', _empdecid,
        'declarationdetail', _jsonarray
    ) INTO _response;

    RETURN _response;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_declaration_upd_declarationdetail'::varchar, 1, 0, _result);
    RETURN json_build_object('error', _message)::jsonb;
END;
$function$;
