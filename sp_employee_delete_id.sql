-- DROP PROCEDURE public.sp_employee_delete_id(in int8, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_employee_delete_id(IN _employeeid bigint, OUT _processingresult character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;
BEGIN
    -- NOTE: In PostgreSQL procedural code (PL/pgSQL), explicit transactions 
    -- (START TRANSACTION / COMMIT) are not allowed inside a block. 
    -- PL/pgSQL implicitly handles transactions per procedure call.

    -- Delete from dependent tables first to maintain foreign key integrity
    DELETE FROM employee_performance WHERE employeeid = _employeeid;
    DELETE FROM employeepersonaldetail WHERE employeeuid = _employeeid;
    DELETE FROM employeeprofessiondetail WHERE employeeuid = _employeeid;
    DELETE FROM employee_declaration WHERE employeeid = _employeeid;
    DELETE FROM employee_leave_request WHERE employeeid = _employeeid;
    DELETE FROM employee_salary_detail WHERE employeeid = _employeeid;
    DELETE FROM daily_attendance WHERE employeeid = _employeeid;
    DELETE FROM project_members_detail WHERE employeeid = _employeeid; 
    DELETE FROM employee_pf_detail WHERE employeeid = _employeeid; 
    DELETE FROM employeelogin WHERE employeeid = _employeeid;
    DELETE FROM employee_overtimetable WHERE employeeid = _employeeid;
    DELETE FROM employee_bonus WHERE employeeid = _employeeid;
    DELETE FROM salary_advance_repayment WHERE employeeid = _employeeid;
    DELETE FROM salary_advance_request WHERE employeeid = _employeeid;
    DELETE FROM hike_bonus_salary_adhoc WHERE employeeid = _employeeid;
    DELETE FROM other_deduction_and_reimbursement_payment WHERE employeeid = _employeeid;
    DELETE FROM employee_notice_period WHERE employeeid = _employeeid;
    DELETE FROM employee_exit_clearance WHERE employeeid = _employeeid; 
    DELETE FROM other_deduction_and_reimbursement_repayment WHERE employeeid = _employeeid;
    DELETE FROM payroll_monthly_detail WHERE employeeid = _employeeid;
    DELETE FROM employee_salary_change_history WHERE employeeid = _employeeid;

    -- Finally delete from the main employees table
    DELETE FROM employees WHERE employeeuid = _employeeid;

    _processingresult := 'deleted';
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_delete_id'::varchar, 1, 0, _result);
    _processingresult := _message;
END;
$procedure$;
