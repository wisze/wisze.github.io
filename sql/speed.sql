ALTER TABLE newtracks ADD COLUMN speed float;
ALTER TABLE newtracks ADD COLUMN distance float;

UPDATE newtracks h SET speed = c.speed, distance = c.kilometers FROM (
   SELECT ogc_fid,
          (extract(epoch from endtime)-extract(epoch from starttime)) as seconds,
          st_length(wkb_geometry::geography)/1000.0 as kilometers,
          st_length(wkb_geometry::geography)/(extract(epoch from endtime)-extract(epoch from starttime))*3.6 as speed 
     FROM newtracks) c
WHERE h.ogc_fid = c.ogc_fid;

