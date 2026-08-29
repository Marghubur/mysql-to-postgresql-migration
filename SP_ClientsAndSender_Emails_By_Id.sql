-- DROP PROCEDURE IF EXISTS public.sp_clientsandsender_emails_by_id(int8, int8, int8, refcursor, refcursor, refcursor);

CREATE OR REPLACE PROCEDURE public.sp_clientsandsender_emails_by_id(
    IN  _senderid       bigint,
    IN  _receiverid     bigint,
    IN  _fileid         bigint,
    INOUT cur_sender    refcursor DEFAULT 'cur_sender',
    INOUT cur_receiver  refcursor DEFAULT 'cur_receiver',
    INOUT cur_file      refcursor DEFAULT 'cur_file'
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate  TEXT;
    _errorno   TEXT;
    _errortext TEXT;
    _message   TEXT;
    _result    TEXT;
BEGIN

    OPEN cur_sender FOR
        SELECT s.*            -- expand to explicit columns if you want fixed ordering
        FROM public.clients s
        WHERE s.clientid = _senderid;

    OPEN cur_receiver FOR
        SELECT r.*
        FROM public.clients r
        WHERE r.clientid = _receiverid;

    OPEN cur_file FOR
        SELECT f.*
        FROM public.filedetail f
        WHERE f.fileid = _fileid;

EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            _sqlstate  = RETURNED_SQLSTATE,
            _errortext = MESSAGE_TEXT;

        _message := 'sp_clientsandsender_emails_by_id('
                    || COALESCE(_senderid::text,'null')   || ', '
                    || COALESCE(_receiverid::text,'null') || ', '
                    || COALESCE(_fileid::text,'null')     || ')';

        CALL public.sp_logexception(_message, _sqlstate, _errortext, 1, 0, _result);

        RAISE;
END;
$procedure$;

ALTER PROCEDURE public.sp_clientsandsender_emails_by_id(int8, int8, int8, refcursor, refcursor, refcursor) OWNER TO postgres;
GRANT ALL ON PROCEDURE public.sp_clientsandsender_emails_by_id(int8, int8, int8, refcursor, refcursor, refcursor) TO public;
