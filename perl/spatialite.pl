#!/usr/bin/perl

%proj = ( platecarree => 'EPSG:4326',
          webmercator => 'EPSG:3857' );

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;
$mon += 1;
$prefix = sprintf("%04d%02d%02d",$year,$mon,$mday);
print "Making spatialite dump for $prefix\n";

foreach my $table ("waypoints", "countries", "waypoints_cluster", "hex_grid", "beidou", "glonass", "tracks", "newtracks", "track_points") {
  print "$table ... ";
  foreach $p (keys %proj) {
    $epsg = $proj{$p};
    $opt = "-a_srs $epsg -t_srs $epsg ";
    if ($table eq "waypoints")
      {$opt .= "-dsco SPATIALITE=yes";}
    else
      {$opt .= "-update";}
    # print("\n  ogr2ogr -f SQLite $opt $prefix.$p.sqlite PG:\"dbname=satnav user=edwin password=onkel-x\" $table\n");
    system("ogr2ogr -f SQLite $opt $prefix.$p.sqlite PG:\"dbname=satnav user=edwin password=onkel-x\" --config OGR_ENABLE_PARTIAL_REPROJECTION TRUE $table");
  }
}

print "done\n";

