-- DROP FUNCTION public.sp_email_signature_templates_sel(varchar, int4, int4);

CREATE OR REPLACE FUNCTION public.sp_email_signature_templates_sel(_templatename character varying, _pagenumber integer, _pagesize integer)
 RETURNS SETOF email_signature_templates
 LANGUAGE plpgsql
AS $function$
DECLARE
    _offset integer;
BEGIN
    _offset := (_pagenumber - 1) * _pagesize;

 RETURN QUERY select
 emailsignaturetemplateid,
 templatename,
 signaturetemplateurl,
 createdon,
 createdby
 from email_signature_templates
 where
 (_templatename is null or templatename like concat('%', _templatename, '%'))
 order by emailsignaturetemplateid desc
 limit _pagesize offset _offset;
END;
$function$
;
