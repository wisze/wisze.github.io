
-- select waypoints, track_points, ST_Box2D(wkb_geometry) as bbox from hex_grid where hexwidth = 30.0;
select count(*) from hex_grid where hexwidth = 0.1;
select hexwidth, count(*) from hex_grid group by hexwidth;

--width in the units of the projection, xmin,ymin,xmax,ymax
-- SELECT genhexagons(30.0, -180.0,-90.0,180.0,90.0);
-- SELECT genhexagons(10.0, -180.0,-90.0,180.0,90.0);
-- SELECT genhexagons( 3.0, -180.0,-90.0,180.0,90.0);
-- SELECT genhexagons( 1.0, -180.0,-90.0,180.0,90.0);
-- SELECT genhexagons( 0.3, -180.0,-90.0,180.0,90.0);
-- SELECT genhexagons( 0.1, -180.0,-90.0,180.0,90.0);
