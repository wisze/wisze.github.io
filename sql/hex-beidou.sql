ALTER TABLE hex_grid ADD COLUMN beidou_view_mean float;
ALTER TABLE hex_grid ADD COLUMN beidou_used_mean float;
ALTER TABLE hex_grid ADD COLUMN beidou_view_min integer;
ALTER TABLE hex_grid ADD COLUMN beidou_used_min integer;
ALTER TABLE hex_grid ADD COLUMN beidou_view_max integer;
ALTER TABLE hex_grid ADD COLUMN beidou_used_max integer;
ALTER TABLE hex_grid ADD COLUMN beidou_points integer;
ALTER TABLE hex_grid ADD COLUMN beidou_used_perc float;

UPDATE hex_grid SET beidou_view_mean = null, beidou_used_mean = null, beidou_view_max  = null, beidou_used_max  = null, beidou_view_min  = null, beidou_used_min  = null, beidou_points = null, beidou_used_perc  = null;

UPDATE hex_grid h SET beidou_points = beidouhex FROM (
        SELECT hex_grid.gid, count(*) as beidouhex 
        FROM hex_grid, beidou ,track_points
        WHERE ST_Contains(hex_grid.wkb_geometry, track_points.wkb_geometry)
        AND track_points.ogc_fid = beidou.ogc_fid
        AND beidou.used IS NOT NULL
	GROUP BY hex_grid.gid
	) c
WHERE h.gid = c.gid;

UPDATE hex_grid h SET beidou_used_perc = percentage FROM (
	SELECT hex_grid.gid,
           (count(beidou.used)*100.0/hex_grid.beidou_points) as percentage
        FROM hex_grid, beidou ,track_points
        WHERE ST_Contains(hex_grid.wkb_geometry, track_points.wkb_geometry)
        AND track_points.ogc_fid = beidou.ogc_fid
        AND beidou.used IS NOT NULL
        AND beidou.used > 3
	GROUP BY hex_grid.gid
	) c
WHERE h.gid = c.gid;

UPDATE hex_grid h SET beidou_view_mean = bvmean,
                      beidou_view_min  = bvmin,
                      beidou_view_max  = bvmax FROM (
	SELECT hex_grid.gid,
           AVG(beidou.view) AS bvmean,
           MIN(beidou.view) AS bvmin,
           MAX(beidou.view) AS bvmax
	FROM hex_grid, beidou, track_points 
        WHERE ST_Contains(hex_grid.wkb_geometry, track_points.wkb_geometry)
        AND track_points.ogc_fid = beidou.ogc_fid
        AND beidou.view IS NOT NULL
        AND beidou.view <> 0.0
	GROUP BY hex_grid.gid
	) c
WHERE h.gid = c.gid;

UPDATE hex_grid h SET beidou_used_mean = bumean,
                      beidou_used_min  = bumin,
                      beidou_used_max  = bumax FROM (
	SELECT hex_grid.gid,
           AVG(beidou.used) AS bumean,
           MIN(beidou.used) AS bumin,
           MAX(beidou.used) AS bumax
	FROM hex_grid, beidou, track_points 
        WHERE ST_Contains(hex_grid.wkb_geometry, track_points.wkb_geometry)
        AND track_points.ogc_fid = beidou.ogc_fid
        AND beidou.used IS NOT NULL
        AND beidou.used <> 0.0
	GROUP BY hex_grid.gid
	) c
WHERE h.gid = c.gid;
