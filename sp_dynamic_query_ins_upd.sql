CREATE OR REPLACE PROCEDURE public.sp_dynamic_query_ins_upd(
  IN _tablename varchar(50),
  IN _primarykey varchar(50),
  IN _rows text,
  OUT _processingresult varchar(100)
)
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _id integer;
  _lastprimarykey TEXT;
  _nonquery TEXT;
BEGIN
  _processingresult := 'updated';
 _id := 0;
 _lastprimarykey := concat(
 'select ', _primarykey ,' into @id from ', 
 _tablename, 
 ' order by ', 
 _primarykey, 
 ' desc limit 1;');
 
 EXECUTE _lastprimarykey;_nonquery := concat(
 'insert into ', _tablename, ' values', 
 _rows);
 
 EXECUTE _nonquery;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_dynamic_query_ins_upd', 1::bit, 0::bit, _result);
END;
$$;
