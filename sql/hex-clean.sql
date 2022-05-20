delete from hex_grid where waypoints = 0 and track_points = 0;
vacuum (analyze, verbose) hex_grid;
