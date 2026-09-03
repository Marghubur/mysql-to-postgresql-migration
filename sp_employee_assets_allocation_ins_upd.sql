CREATE OR REPLACE PROCEDURE public.sp_employee_assets_allocation_ins_upd(
    IN _employeeassetsallocationid bigint, 
    IN _employeeid bigint, 
    IN _productid bigint, 
    IN _allocatedon timestamp without time zone, 
    IN _allocatedby bigint, 
    IN _returnstatus bit, 
    IN _returnedon timestamp without time zone, 
    IN _commentsonreturneditem character varying, 
    IN _returnedhandledby bigint, 
    IN _remarks character varying, 
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
    _local_id bigint := _employeeassetsallocationid; 
BEGIN
    if not exists(select 1 from employee_assets_allocation where employeeassetsallocationid = _local_id) then
        select coalesce(max(employeeassetsallocationid), 0) into _local_id from employee_assets_allocation;
        _local_id := _local_id + 1;
        
        -- FIXED: Explicitly listing column names guarantees data types match perfectly
        insert into employee_assets_allocation (
            employeeassetsallocationid,
            employeeid,
            productid,
            allocatedon,
            allocatedby,
            returnstatus,
            returnedon,
            commentsonreturneditem,
            returnedhandledby,
            remarks
        ) values (
            _local_id,
            _employeeid,
            _productid,
            _allocatedon,
            _allocatedby,
            _returnstatus,
            _returnedon,
            _commentsonreturneditem,
            _returnedhandledby,
            _remarks
        );
        
        _processingresult := 'inserted';
    else
        update employee_assets_allocation set
            employeeid = _employeeid,
            productid = _productid,
            allocatedon = _allocatedon,
            allocatedby = _allocatedby,
            returnstatus = _returnstatus,
            returnedon = _returnedon,
            commentsonreturneditem = _commentsonreturneditem,
            returnedhandledby = _returnedhandledby,
            remarks = _remarks
        where employeeassetsallocationid = _local_id;
        
        _processingresult := 'updated';
    end if;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_assets_allocation_ins_upd'::varchar, 1, 0, _result);
    _processingresult := _message; 
END;
$procedure$;
