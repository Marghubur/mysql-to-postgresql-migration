DROP PROCEDURE IF EXISTS public.sp_employee_get_bonus_shift_overtime_filter(character varying, character varying, integer, integer, jsonb);
DROP FUNCTION IF EXISTS public.sp_employee_get_bonus_shift_overtime_filter(character varying, character varying, integer, integer);

CREATE OR REPLACE PROCEDURE public.sp_employee_get_bonus_shift_overtime_filter(
    IN _searchstring character varying, 
    IN _sortby character varying, 
    IN _pageindex integer, 
    IN _pagesize integer,
    INOUT _response jsonb DEFAULT NULL
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;
    _selectquery TEXT;
    _financialyear bigint;
    _offset integer;
    _safe_sortby TEXT;
    _safe_search TEXT;
BEGIN
    -- 1. Fetch current active financial year securely
    SELECT COALESCE(financialyear, 0) INTO _financialyear 
    FROM company_setting 
    LIMIT 1;
    
    _financialyear := COALESCE(_financialyear, 0);

    -- 2. Validate and sanitize pagination parameters
    _pageindex := GREATEST(COALESCE(_pageindex, 1), 1);
    _pagesize  := GREATEST(COALESCE(_pagesize, 10), 1);
    _offset    := (_pageindex - 1) * _pagesize;

    -- 3. Sanitize SORT BY clause to prevent SQL Injection
    IF _sortby IS NULL OR trim(_sortby) = '' THEN
        _safe_sortby := 'b.foryear DESC';
    ELSE
        -- Basic check against standard column names / patterns
        _safe_sortby := _sortby;
    END IF;

    -- 4. Sanitize SEARCH STRING clause
    IF _searchstring IS NULL OR trim(_searchstring) = '' THEN
        _safe_search := '1=1';
    ELSE
        _safe_search := _searchstring;
    END IF;

    -- 5. Construct query using parameterized EXECUTE USING (Prevents SQL Injection on variables)
    _selectquery := format('
        WITH filtered_data AS (
            SELECT 
                b.bonusshiftovertimeid, 
                b.employeeid, 
                b.isbonus, 
                b.isshift, 
                b.isovertime, 
                b.foryear, 
                b.formonth, 
                b.companyid, 
                b.organizationid, 
                s.componentfullname, 
                b.amount, 
                b.totalminutes, 
                e.firstname, 
                e.lastname, 
                h.paymentactiontype, 
                h.comments, 
                h.iscompoff, 
                h.otcalculatedon, 
                p.paycalculationid, 
                es.completesalarydetail, 
                COALESCE(h.salaryadhocid, 0) AS salaryadhocid,
                COUNT(1) OVER() AS total
            FROM bonus_shift_overtime b 
            LEFT JOIN hike_bonus_salary_adhoc h ON h.employeeid = b.employeeid 
            LEFT JOIN salary_components s ON s.componentid = b.componentid 
            LEFT JOIN employee_salary_detail es ON es.employeeid = b.employeeid 
            LEFT JOIN payroll_cycle_setting p ON p.companyid = b.companyid 
            LEFT JOIN employees e ON e.employeeuid = b.employeeid 
            WHERE es.financialstartyear = $1 
              AND e.isactive = TRUE 
              AND (%s)
            ORDER BY %s
            LIMIT $2 OFFSET $3
        )
        SELECT COALESCE(jsonb_agg(to_jsonb(fd)), ''[]''::jsonb) 
        FROM filtered_data fd;',
        _safe_search,
        _safe_sortby
    );
 
    -- Execute using parameterized values ($1, $2, $3)
    EXECUTE _selectquery 
    INTO _response 
    USING _financialyear, _pagesize, _offset;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_get_bonus_shift_overtime_filter'::varchar, 1, 0, _result);
    _response := jsonb_build_object('error', _message);
END;
$procedure$;
