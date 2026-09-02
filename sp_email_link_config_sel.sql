CREATE OR REPLACE FUNCTION public.sp_email_link_config_sel(
  IN _templatename varchar(145),
  IN _pagenumber integer,
  IN _pagesize integer
)
RETURNS SETOF "email_link_config"
LANGUAGE plpgsql
AS $$
DECLARE
  _offset integer;
BEGIN
  _offset := (_pagenumber - 1) * _pagesize;
 RETURN QUERY select
 emailtlinkconfigurationid,
 templatename,
 templateurl,
 signaturetemplateurl,
 updatedby,
 updatedon
 from email_link_config
 where
 (_templatename is null or templatename like concat('%', _templatename, '%'))
 order by emailtlinkconfigurationid desc
 limit _pagesize offset _offset;
END;
$$;
