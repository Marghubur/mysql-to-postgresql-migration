CREATE OR REPLACE PROCEDURE public.sp_employees_basicinfo_ins_upd(
    IN _employeeuid bigint, IN _firstname character varying, IN _lastname character varying, 
    IN _mobile character varying, IN _email character varying, IN _adminid bigint, 
    IN _reportingmanagerid bigint, IN _designationid integer, IN _usertypeid integer, 
    IN _leaveplanid integer, IN _payrollgroupid integer, IN _salarygroupid integer, 
    IN _companyid integer, IN _workshiftid integer, IN _dateofjoining timestamp without time zone, 
    IN _secondarymobile character varying, IN _accesslevelid integer, IN _password character varying, 
    IN _organizationid integer, IN _ctc numeric, IN _dob timestamp without time zone, 
    IN _location character varying, IN _departmentid integer, IN _gender integer, 
    IN _profilestatuscode character varying, OUT _processingresult character varying
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;     -- FIXED: Changed from TEXT to character varying
    _employeepfdetailid bigint;
    _employeeproid bigint;
    _leaverequestid bigint;
    _adjusteddate timestamp;       -- FIXED: Changed to timestamp for date math
    _todate timestamp;             -- FIXED: Changed to timestamp
    _fromdate timestamp;           -- FIXED: Changed to timestamp
    _employeeid bigint;
    _projectmemberid bigint;
    _empid bigint;                 -- Make sure this matches sp_daily_attendance_ins_advance_by_empid OUT type
    _empprofdetailuid bigint;
    _financialstartyear bigint;
    _employeeloginid bigint;
    _salarydetailid bigint;
BEGIN
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM employees WHERE employeeuid = _employeeuid) THEN
            _employeeid := 0;
            SELECT employeeuid INTO _employeeid FROM employees ORDER BY employeeuid DESC LIMIT 1;
            _employeeid := COALESCE(_employeeid, 0) + 1;

            INSERT INTO employees VALUES(
                _employeeid, _firstname, _lastname, _mobile, _email, true, _adminid, _adminid,
                _dateofjoining, null, _reportingmanagerid, _designationid, _usertypeid,
                _leaveplanid, _payrollgroupid, _salarygroupid, _companyid, 0, _workshiftid, 0
            );

            _employeeproid := 0;
            SELECT employeepersonaldetailid INTO _employeeproid FROM employeepersonaldetail ORDER BY employeepersonaldetailid DESC LIMIT 1;
            _employeeproid := COALESCE(_employeeproid, 0) + 1;

            INSERT INTO employeepersonaldetail VALUES (
                _employeeproid, _employeeid, _mobile, _secondarymobile, _email, _gender, null, 2,
                null, null, null, null, false, null, null, null, null, null, null, null, null, 0,
                null, null, null, null, null, 0, null, null, null, 0, null, false, 0, 0, 0,
                _adminid, null, _dateofjoining, null, _dob
            );

            _empprofdetailuid := 0;
            SELECT empprofdetailuid INTO _empprofdetailuid FROM employeeprofessiondetail ORDER BY empprofdetailuid DESC LIMIT 1;
            _empprofdetailuid := COALESCE(_empprofdetailuid, 0) + 1;

            INSERT INTO employeeprofessiondetail VALUES (
                _empprofdetailuid, _employeeid, _firstname, _lastname, _mobile, _secondarymobile,
                _email, null, null, null, null, null, null, null, null, null, 0, null, null, null,
                null, null, null, 0, false, null, null, null, _location, _departmentid,
                _profilestatuscode, _adminid, null, _dateofjoining, null, '[]'
            );

            _employeeloginid := 0;
            SELECT employeeloginid INTO _employeeloginid FROM employeelogin ORDER BY employeeloginid DESC LIMIT 1;
            _employeeloginid := COALESCE(_employeeloginid, 0) + 1;

            INSERT INTO employeelogin VALUES(
                _employeeloginid, _employeeid, _usertypeid, _accesslevelid, _password, _email,
                _mobile, _organizationid, _companyid, _adminid, null, _dateofjoining, null
            );

            _salarydetailid := 0;
            SELECT salarydetailid INTO _salarydetailid FROM employee_salary_detail ORDER BY salarydetailid DESC LIMIT 1;
            _salarydetailid := COALESCE(_salarydetailid, 0) + 1;

            _financialstartyear := 0;
            SELECT financialyear INTO _financialstartyear FROM company_setting;
            -- FIXED: Removed invalid standalone "select _financialstartyear;" here

            INSERT INTO employee_salary_detail VALUES (
                _salarydetailid, _employeeid, _ctc, 0, 0, '[]', '[]', 1, '[]',
                _financialstartyear, timezone('utc', now())
            );

            _leaverequestid := 0;
            SELECT leaverequestid INTO _leaverequestid FROM employee_leave_request ORDER BY leaverequestid DESC LIMIT 1;
            _leaverequestid := COALESCE(_leaverequestid, 0) + 1;
 
            INSERT INTO employee_leave_request VALUES(
                _leaverequestid, _employeeid, '[]', 
                EXTRACT(YEAR FROM timezone('utc', now())), -- FIXED: MySQL year() to Postgres EXTRACT()
                false, 0, 0, 0, 0, _dateofjoining
            );

            _projectmemberid := 0;
            SELECT projectmemberdetailid INTO _projectmemberid FROM project_members_detail ORDER BY projectmemberdetailid DESC LIMIT 1;
            _projectmemberid := COALESCE(_projectmemberid, 0) + 1;

            INSERT INTO project_members_detail VALUES (
                _projectmemberid, 1, 1, _employeeid, concat(_firstname, ' ', _lastname), _email,
                true, _designationid, timezone('utc', now()), 1, null, 'Default Team', 0
            );

            _employeepfdetailid := 0;
            SELECT employeepfdetailid INTO _employeepfdetailid FROM employee_pf_detail ORDER BY employeepfdetailid DESC LIMIT 1;
            _employeepfdetailid := COALESCE(_employeepfdetailid, 0) + 1;

            INSERT INTO employee_pf_detail VALUES(
                _employeepfdetailid, _employeeid, false, false, '', '', '', false, null, true
            );

            _fromdate := _dateofjoining;

            -- FIXED: Handled all MySQL date manipulation functions correctly for Postgres
            _adjusteddate := CASE
                WHEN EXTRACT(YEAR FROM _fromdate) != EXTRACT(YEAR FROM current_date)
                    THEN cast(concat(EXTRACT(YEAR FROM current_date), '-01-01 18:30:00') as timestamp)
                WHEN cast(_fromdate as time) != '18:30:00'::time
                    THEN cast(to_char(_fromdate, 'YYYY-MM-DD') || ' 18:30:00' as timestamp)
                ELSE
                    _fromdate
            END;

            _adjusteddate := _adjusteddate - INTERVAL '1 day'; -- FIXED: date_sub replaced
            _todate := timezone('utc', now());

            CALL sp_daily_attendance_ins_advance_by_empid(_adjusteddate, _todate, 0, _empid);

            _processingresult := cast(_employeeid as character varying);
        ELSE
            UPDATE employees SET
                firstname = _firstname, lastname = _lastname, mobile = _mobile, email = _email,
                updatedby = _adminid, createdon = _dateofjoining, updatedon = timezone('utc', now()),
                reportingmanagerid = _reportingmanagerid, designationid = _designationid,
                usertypeid = _usertypeid, leaveplanid = _leaveplanid, workshiftid = _workshiftid
            WHERE employeeuid = _employeeuid;

            UPDATE employeepersonaldetail SET
                mobile = _mobile, secondarymobile = _secondarymobile, email = _email,
                updatedby = _adminid, updatedon = timezone('utc', now()), gender = _gender, dob = _dob
            WHERE employeeuid = _employeeuid;

            UPDATE employeeprofessiondetail SET
                firstname = _firstname, lastname = _lastname, mobile = _mobile,
                secondarymobile = _secondarymobile, email = _email, departmentid = _departmentid,
                location = _location, updatedby = _adminid, updatedon = timezone('utc', now())
            WHERE employeeuid = _employeeuid;

            UPDATE employeelogin SET
                usertypeid = _usertypeid, accesslevelid = _accesslevelid, email = _email,
                mobile = _mobile, updatedby = _adminid, updatedon = timezone('utc', now())
            WHERE employeeid = _employeeuid;

            _financialstartyear := 0;
            SELECT financialyear INTO _financialstartyear FROM company_setting;
            -- FIXED: Removed invalid standalone "select _financialstartyear;" here

            UPDATE employee_salary_detail SET ctc = _ctc
            WHERE employeeid = _employeeuid AND financialstartyear = _financialstartyear;
            
            _processingresult := cast(_employeeuid as character varying);
        END IF;
    END;
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    CALL sp_logexception(_message, '', 'sp_employees_basicinfo_ins_upd', 1, 0, _result);
END;
$procedure$;
