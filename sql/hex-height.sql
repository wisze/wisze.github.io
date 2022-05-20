ALTER TABLE hex_grid ADD COLUMN ele float;
ALTER TABLE hex_grid ADD COLUMN eleln float;
ALTER TABLE hex_grid ADD COLUMN elesd float;

UPDATE hex_grid SET ele = null, eleln = null, elesd = null;

UPDATE hex_grid h SET ele = meanele, elesd = stddevele  FROM (
	SELECT hex_grid.gid, AVG(track_points.ele) AS meanele, STDDEV(track_points.ele) AS stddevele
	FROM hex_grid JOIN track_points ON (ST_Contains(hex_grid.wkb_geometry, track_points.wkb_geometry))
        WHERE track_points.ele IS NOT NULL
        AND track_points.ele < 5000.0
        AND track_points.ele <> 0.0
	GROUP BY hex_grid.gid
	) c
WHERE h.gid = c.gid;

UPDATE hex_grid SET eleln = ln(abs(ele)) WHERE ele is not null;

