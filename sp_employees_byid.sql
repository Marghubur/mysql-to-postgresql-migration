CREATE OR REPLACE FUNCTION public.sp_employees_byid(_employeeid integer, _isactive integer)
 RETURNS TABLE(
    employeeuid bigint, organizationid integer, firstname character varying, lastname character varying, 
    mobile character varying, email character varying, leaveplanid integer, payrollgroupid integer, 
    salarygroupid integer, companyid integer, noticeperiodid integer, secondarymobile character varying, 
    gender integer, fathername character varying, dob timestamp without time zone, address character varying, 
    ispermanent boolean, actualpackage numeric, finalpackage numeric, takehomebycandidate numeric, 
    empprofdetailuid bigint, exprienceinyear numeric, specification character varying, panno character varying, 
    aadharno character varying, accountnumber character varying, bankname character varying, branchname character varying, 
    domain character varying, ifsccode character varying, lastcompanyname character varying, 
    accesslevelid bigint,   
    usertypeid integer,     -- FIXED: Changed back to integer to match your database (Column 33)
    createdon timestamp without time zone, employeepfdetailid bigint, pfnumber character varying, 
    uan character varying, pfaccountcreationdate timestamp without time zone, ispfenable boolean, 
    professionaldetail_json character varying
)
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF (_isactive = 1) THEN
        RETURN QUERY 
        SELECT 
            e.employeeuid, l.organizationid, e.firstname, e.lastname, e.mobile, e.email, e.leaveplanid,
            e.payrollgroupid, e.salarygroupid, e.companyid, e.noticeperiodid, ep.secondarymobile,
            ep.gender, ep.fathername, ep.dob, ep.address, ep.ispermanent, ep.actualpackage, ep.finalpackage,
            ep.takehomebycandidate, epro.empprofdetailuid, epro.exprienceinyear, epro.specification,
            epro.panno, epro.aadharno, epro.accountnumber, epro.bankname, epro.branchname, epro.domain,
            epro.ifsccode, epro.lastcompanyname, l.accesslevelid, l.usertypeid, e.createdon,
            epf.employeepfdetailid, epf.pfnumber, epf.universalaccountnumber AS uan,
            epf.pfjoindate AS pfaccountcreationdate, pfs.pfenable AS ispfenable,
            cast(epro.professionaldetail_json as character varying)
        FROM employees e
        INNER JOIN employeelogin l ON l.employeeid = e.employeeuid
        LEFT JOIN employeepersonaldetail ep ON e.employeeuid = ep.employeeuid
        LEFT JOIN employeeprofessiondetail epro ON e.employeeuid = epro.employeeuid
        LEFT JOIN employee_pf_detail epf ON e.employeeuid = epf.employeeid
        LEFT JOIN pf_esi_setting pfs ON pfs.companyid = e.companyid
        WHERE e.employeeuid = _employeeid;

    ELSEIF (_isactive = 0) THEN
        RETURN QUERY 
        SELECT 
            e.employeeuid, NULL::integer AS organizationid, e.firstname, e.lastname, e.mobile, e.email,
            NULL::integer AS leaveplanid, NULL::integer AS payrollgroupid, NULL::integer AS salarygroupid,
            NULL::integer AS companyid, NULL::integer AS noticeperiodid, ep.secondarymobile, ep.gender,
            ep.fathername, ep.dob, ep.address, ep.ispermanent, ep.actualpackage, ep.finalpackage,
            ep.takehomebycandidate, NULL::bigint AS empprofdetailuid, epro.exprienceinyear, epro.specification,
            epro.panno, epro.aadharno, epro.accountnumber, epro.bankname, epro.branchname, epro.domain,
            epro.ifsccode, epro.lastcompanyname, l.accesslevelid, l.usertypeid, e.createdon,
            epf.employeepfdetailid, epf.pfnumber, epf.universalaccountnumber AS uan,
            epf.pfjoindate AS pfaccountcreationdate, pfs.pfenable AS ispfenable,
            cast(epro.professionaldetail_json as character varying)
        FROM employee_archive e
        INNER JOIN employeelogin l ON l.employeeid = e.employeeuid
        LEFT JOIN employeepersonaldetail_archive ep ON e.employeeuid = ep.employeeuid
        LEFT JOIN employeeprofessiondetail_archive epro ON e.employeeuid = epro.employeeuid
        LEFT JOIN employee_pf_detail epf ON e.employeeuid = epf.employeeid
        LEFT JOIN pf_esi_setting pfs ON pfs.companyid = e.companyid
        WHERE e.employeeuid = _employeeid;

    ELSE
        RETURN QUERY 
        SELECT 
            e.employeeuid, NULL::integer AS organizationid, e.firstname, e.lastname, e.mobile, e.email,
            NULL::integer AS leaveplanid, NULL::integer AS payrollgroupid, NULL::integer AS salarygroupid,
            NULL::integer AS companyid, NULL::integer AS noticeperiodid, ep.secondarymobile, ep.gender,
            ep.fathername, ep.dob, ep.address, ep.ispermanent, ep.actualpackage, ep.finalpackage,
            ep.takehomebycandidate, NULL::bigint AS empprofdetailuid, epro.exprienceinyear, epro.specification,
            epro.panno, epro.aadharno, epro.accountnumber, epro.bankname, epro.branchname, epro.domain,
            epro.ifsccode, epro.lastcompanyname, l.accesslevelid, l.usertypeid, e.createdon,
            epf.employeepfdetailid, epf.pfnumber, epf.universalaccountnumber AS uan,
            epf.pfjoindate AS pfaccountcreationdate, pfs.pfenable AS ispfenable,
            cast(epro.professionaldetail_json as character varying)
        FROM (
            SELECT * FROM employees 
            UNION 
            SELECT * FROM employee_archive
        ) e
        INNER JOIN employeelogin l ON l.employeeid = e.employeeuid
        LEFT JOIN employeepersonaldetail_archive ep ON e.employeeuid = ep.employeeuid
        LEFT JOIN employeeprofessiondetail_archive epro ON e.employeeuid = epro.employeeuid
        LEFT JOIN employee_pf_detail epf ON e.employeeuid = epf.employeeid
        LEFT JOIN pf_esi_setting pfs ON pfs.companyid = e.companyid
        WHERE e.employeeuid = _employeeid;
    END IF;
END;
$function$;
