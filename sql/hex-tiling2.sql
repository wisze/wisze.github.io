DROP TABLE IF EXISTS hex_grid;
CREATE TABLE hex_grid (
  gid serial not null primary key, 
  hexwidth float, 
  waypoints integer not null default 0, 
  track_points integer not null default 0, 
  height float
);
SELECT addgeometrycolumn('hex_grid','wkb_geometry', 4326, 'POLYGON', 2);

CREATE OR REPLACE FUNCTION genhexagons (size float, xmin float,ymin float,xmax float,ymax float)
RETURNS float AS $total$
declare

sx1 float := cos((60 * 1 + 30) * (pi()/180)) * size;
sx2 float := cos((60 * 2 + 30) * (pi()/180)) * size;
sx3 float := cos((60 * 3 + 30) * (pi()/180)) * size;
sx4 float := cos((60 * 4 + 30) * (pi()/180)) * size;
sx5 float := cos((60 * 5 + 30) * (pi()/180)) * size;
sx6 float := cos((60 * 6 + 30) * (pi()/180)) * size;

sy1 float := sin((60 * 1 + 30) * (pi()/180)) * size;
sy2 float := sin((60 * 2 + 30) * (pi()/180)) * size;
sy3 float := sin((60 * 3 + 30) * (pi()/180)) * size;
sy4 float := sin((60 * 4 + 30) * (pi()/180)) * size;
sy5 float := sin((60 * 5 + 30) * (pi()/180)) * size;
sy6 float := sin((60 * 6 + 30) * (pi()/180)) * size;

width float := ((size / 2) * sqrt(3)) * 2;
a float := cos((60) * (pi()/180)) * size;
b float := width / 2;
c float := 2 * a;

height float := size + c;

ncol float :=ceil(abs(xmax-xmin)/width);

nrow float :=ceil(abs(ymax-ymin)/height);

polygon_string varchar := 'POLYGON((' ||
sx1||' '||sy1||' , '||
sx2||' '||sy2||' , '||
sx3||' '||sy3||' , '||
sx4||' '||sy4||' , '||
sx5||' '||sy5||' , '||
sx6||' '||sy6||' , '||
sx1||' '||sy1||'))';

BEGIN
INSERT INTO hex_grid (hexwidth, wkb_geometry) 
  SELECT size, st_translate(the_geom, x_series*(width)+xmin, y_series*(2*(c+a))+ymin)
  FROM generate_series(0, ncol::int, 1) as x_series,
       generate_series(0, nrow::int, 1) as y_series,
(
  SELECT ST_GeomFromText(polygon_string,4326) as the_geom
  UNION
  SELECT ST_Translate(ST_GeomFromText(polygon_string,4326), b , a+c) as the_geom
  -- SELECT polygon_string as the_geom
  -- UNION
  -- SELECT ST_Translate(polygon_string, b , a+c) as the_geom
) as two_hex;
-- WHERE (ST_Contains(two_hex.the_geom, waypoints.wkb_geometry));

RETURN NULL;
END;
$total$ LANGUAGE plpgsql;

----------------------------------------
SELECT genhexagons(30.0, -180.0,-90.0,180.0,90.0);
SELECT genhexagons(10.0, -180.0,-90.0,180.0,90.0);
SELECT genhexagons( 3.0, -180.0,-90.0,180.0,90.0);
SELECT genhexagons( 1.0, -180.0,-90.0,180.0,90.0);
SELECT genhexagons( 0.3, -180.0,-90.0,180.0,90.0);
SELECT genhexagons( 0.1, -180.0,-90.0,180.0,90.0);
SELECT genhexagons(0.03, -180.0,-90.0,180.0,90.0);

-- UPDATE hex_grid h SET waypoints = point_count FROM (
-- 	SELECT hex_grid.gid, count(*) AS point_count
-- 	FROM hex_grid JOIN waypoints ON (ST_Contains(hex_grid.wkb_geometry, waypoints.wkb_geometry))
-- 	GROUP BY hex_grid.gid
-- 	) c
-- WHERE h.gid = c.gid;
-- 
-- UPDATE hex_grid h SET track_points = point_count FROM (
-- 	SELECT hex_grid.gid, count(*) AS point_count
-- 	FROM hex_grid JOIN track_points ON (ST_Contains(hex_grid.wkb_geometry, track_points.wkb_geometry))
-- 	GROUP BY hex_grid.gid
-- 	) c
-- WHERE h.gid = c.gid;
