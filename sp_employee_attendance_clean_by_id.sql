DROP PROCEDURE IF EXISTS public.sp_employee_attendance_clean_by_id(character varying, integer);

CREATE OR REPLACE PROCEDURE public.sp_employee_attendance_clean_by_id(IN _employeesid character varying, IN _month integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying; -- FIXED: Changed to character varying to prevent logger crash
    _counter bigint;
    _current_id bigint;
    _condition_count bigint;
BEGIN
    -- FIXED: Use TEMP TABLE to avoid concurrency collisions between multiple users
    DROP TABLE IF EXISTS emp_list;
    CREATE TEMP TABLE emp_list AS (
        SELECT 
            row_number() OVER() AS row_index,
            value::int AS id
        FROM jsonb_array_elements_text(_employeesid::jsonb)
    );
     
    _counter := 1;
    _condition_count := (SELECT count(*) FROM emp_list);
    _current_id := 0;
     
    WHILE _counter <= _condition_count LOOP
        SELECT id INTO _current_id FROM emp_list WHERE row_index = _counter;
         
        DELETE FROM attendance 
        WHERE employeeid = _current_id
        AND (
            _month <= 0 OR formonth = _month
        );
         
        _counter := _counter + 1;
    END LOOP;
     
    DROP TABLE IF EXISTS emp_list; 
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    -- FIXED: Added ::varchar casts to prevent logger failure
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_attendance_clean_by_id'::varchar, 1, 0, _result);
END;
$procedure$;
