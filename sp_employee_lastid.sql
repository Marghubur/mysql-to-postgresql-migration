-- Ensure the procedure exists in its original form
CREATE OR REPLACE PROCEDURE public.sp_employee_lastid(IN _isactive bit, OUT _processingresult character varying)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    SELECT employeeuid INTO _processingresult 
    FROM employees 
    WHERE isactive = (_isactive = '1'::bit)
    ORDER BY employeeuid DESC 
    LIMIT 1;
END;
$procedure$;
