-- DROP FUNCTION public.sp_email_templates_sel(varchar, int4, int4);

CREATE OR REPLACE FUNCTION public.sp_email_templates_sel(_templatename character varying, _pagenumber integer, _pagesize integer)
 RETURNS TABLE(emailtemplateid integer, templatename character varying, sampletemplateurl character varying, createdon timestamp with time zone, createdby bigint)
 LANGUAGE plpgsql
AS $function$
DECLARE
    _offset integer;
BEGIN
    -- Calculate the offset for pagination
    _offset := (_pagenumber - 1) * _pagesize;

    RETURN QUERY 
    SELECT
        e.emailtemplateid,
        e.templatename,
        e.sampletemplateurl,
        e.createdon,
        e.createdby
    FROM email_templates e
    WHERE (_templatename IS NULL OR e.templatename ILIKE concat('%', _templatename, '%'))
    ORDER BY e.emailtemplateid DESC
    LIMIT _pagesize 
    OFFSET _offset;
END;
$function$
;
