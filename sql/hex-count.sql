
UPDATE hex_grid h SET waypoints = point_count FROM (
	SELECT hex_grid.gid, count(*) AS point_count
	FROM hex_grid JOIN waypoints ON (ST_Contains(hex_grid.wkb_geometry, waypoints.wkb_geometry))
	GROUP BY hex_grid.gid
	) c
WHERE h.gid = c.gid;

UPDATE hex_grid h SET track_points = point_count FROM (
	SELECT hex_grid.gid, count(*) AS point_count
	FROM hex_grid JOIN track_points ON (ST_Contains(hex_grid.wkb_geometry, track_points.wkb_geometry))
	GROUP BY hex_grid.gid
	) c
WHERE h.gid = c.gid;
