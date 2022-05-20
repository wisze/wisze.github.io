ALTER TABLE countries ADD COLUMN waypoints integer;
ALTER TABLE countries ADD COLUMN track_points integer;
ALTER TABLE countries ADD COLUMN waypoints_percent float;
ALTER TABLE countries ADD COLUMN track_points_percent float;
ALTER TABLE countries ADD COLUMN mean_percent float;

UPDATE countries h SET waypoints = point_count FROM (
	SELECT countries.ogc_fid, count(*) AS point_count
	FROM countries JOIN waypoints ON (ST_Contains(countries.wkb_geometry, waypoints.wkb_geometry))
	GROUP BY countries.ogc_fid
	) c
WHERE h.ogc_fid = c.ogc_fid;

UPDATE countries h SET track_points = point_count FROM (
	SELECT countries.ogc_fid, count(*) AS point_count
	FROM countries JOIN track_points ON (ST_Contains(countries.wkb_geometry, track_points.wkb_geometry))
	GROUP BY countries.ogc_fid
	) c
WHERE h.ogc_fid = c.ogc_fid;

UPDATE countries h SET waypoints_percent = ( h.waypoints * 1.0 / c.total_waypoints ) FROM (
       SELECT count(*) AS total_waypoints FROM waypoints
       ) c;

UPDATE countries h SET track_points_percent = ( h.track_points * 1.0 / c.total_track_points ) FROM (
       SELECT count(*) AS total_track_points FROM track_points
       ) c;

UPDATE countries SET mean_percent = (track_points_percent+waypoints_percent)/2.0;
UPDATE countries SET mean_percent = track_points_percent WHERE track_points_percent IS NOT NULL AND waypoints_percent IS NULL;
UPDATE countries SET mean_percent = waypoints_percent WHERE track_points_percent IS NULL AND waypoints_percent IS NOT NULL;

