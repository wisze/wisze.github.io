DROP table waypoints_cluster;
CREATE TABLE waypoints_cluster (
  id serial not null primary key,
  name     varchar,
  number   integer,
  distance float,
  radius   float);
SELECT addgeometrycolumn('waypoints_cluster','centroid', 4326, 'POINT', 2); 
SELECT addgeometrycolumn('waypoints_cluster','circle',   4326, 'POLYGON', 2); 
SELECT addgeometrycolumn('waypoints_cluster','geom_collection', 4326, 'GEOMETRYCOLLECTION', 2); 

CREATE OR REPLACE FUNCTION clusterwaypoints (distance float) RETURNS float AS $total$
BEGIN
  INSERT INTO waypoints_cluster (number, distance, radius, centroid, circle, geom_collection)
    SELECT numgeo, distance, radius, centroid, circle, geom_collection
    FROM (
    SELECT row_number() over () AS id,
      ST_NumGeometries(gc) AS numgeo,
      gc AS geom_collection,
      ST_Centroid(gc) AS centroid,
      ST_MinimumBoundingCircle(gc) AS circle,
      sqrt(ST_Area(ST_MinimumBoundingCircle(gc)) / pi()) AS radius
    FROM (
      SELECT unnest(ST_ClusterWithin(wkb_geometry, distance)) gc
      FROM waypoints
    ) f
  ) g WHERE numgeo > 1 AND radius > 0.0;

  INSERT INTO waypoints_cluster (number, distance, centroid, geom_collection)
    SELECT numgeo, distance, centroid, geom_collection
    FROM (
    SELECT row_number() over () AS id,
      ST_NumGeometries(gc) AS numgeo,
      gc AS geom_collection,
      ST_Centroid(gc) AS centroid,
      sqrt(ST_Area(ST_MinimumBoundingCircle(gc)) / pi()) AS radius
    FROM (
      SELECT unnest(ST_ClusterWithin(wkb_geometry, distance)) gc
      FROM waypoints
    ) f
  ) g WHERE numgeo = 1 OR radius = 0.0;

  RETURN NULL;
END;
$total$ LANGUAGE plpgsql;

SELECT clusterwaypoints(1.0);
SELECT clusterwaypoints(0.3);
SELECT clusterwaypoints(0.1);
SELECT clusterwaypoints(0.03);
SELECT clusterwaypoints(0.01);
