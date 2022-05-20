ALTER TABLE hex_grid ADD COLUMN glonass_view_mean float;
ALTER TABLE hex_grid ADD COLUMN glonass_used_mean float;
ALTER TABLE hex_grid ADD COLUMN glonass_view_min integer;
ALTER TABLE hex_grid ADD COLUMN glonass_used_min integer;
ALTER TABLE hex_grid ADD COLUMN glonass_view_max integer;
ALTER TABLE hex_grid ADD COLUMN glonass_used_max integer;
ALTER TABLE hex_grid ADD COLUMN glonass_points integer;
ALTER TABLE hex_grid ADD COLUMN glonass_used_perc float;

UPDATE hex_grid SET glonass_view_mean = null, glonass_used_mean = null, glonass_view_max  = null, glonass_used_max  = null, glonass_view_min  = null, glonass_used_min  = null, glonass_points = null, glonass_used_perc  = null;

UPDATE hex_grid h SET glonass_points = glonasshex FROM (
        SELECT hex_grid.gid, count(*) as glonasshex 
        FROM hex_grid, glonass ,track_points
        WHERE ST_Contains(hex_grid.wkb_geometry, track_points.wkb_geometry)
        AND track_points.ogc_fid = glonass.ogc_fid
        AND glonass.used IS NOT NULL
	GROUP BY hex_grid.gid
	) c
WHERE h.gid = c.gid;

UPDATE hex_grid h SET glonass_used_perc = percentage FROM (
	SELECT hex_grid.gid,
           (count(glonass.used)*100.0/hex_grid.glonass_points) as percentage
        FROM hex_grid, glonass ,track_points
        WHERE ST_Contains(hex_grid.wkb_geometry, track_points.wkb_geometry)
        AND track_points.ogc_fid = glonass.ogc_fid
        AND glonass.used IS NOT NULL
        AND glonass.used > 3
	GROUP BY hex_grid.gid
	) c
WHERE h.gid = c.gid;

UPDATE hex_grid h SET glonass_view_mean = bvmean,
                      glonass_view_min  = bvmin,
                      glonass_view_max  = bvmax FROM (
	SELECT hex_grid.gid,
           AVG(glonass.view) AS bvmean,
           MIN(glonass.view) AS bvmin,
           MAX(glonass.view) AS bvmax
	FROM hex_grid, glonass, track_points 
        WHERE ST_Contains(hex_grid.wkb_geometry, track_points.wkb_geometry)
        AND track_points.ogc_fid = glonass.ogc_fid
        AND glonass.view IS NOT NULL
        AND glonass.view <> 0.0
	GROUP BY hex_grid.gid
	) c
WHERE h.gid = c.gid;

UPDATE hex_grid h SET glonass_used_mean = bumean,
                      glonass_used_min  = bumin,
                      glonass_used_max  = bumax FROM (
	SELECT hex_grid.gid,
           AVG(glonass.used) AS bumean,
           MIN(glonass.used) AS bumin,
           MAX(glonass.used) AS bumax
	FROM hex_grid, glonass, track_points 
        WHERE ST_Contains(hex_grid.wkb_geometry, track_points.wkb_geometry)
        AND track_points.ogc_fid = glonass.ogc_fid
        AND glonass.used IS NOT NULL
        AND glonass.used <> 0.0
	GROUP BY hex_grid.gid
	) c
WHERE h.gid = c.gid;
