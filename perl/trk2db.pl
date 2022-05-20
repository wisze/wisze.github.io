#!c:\perl\bin\perl.exe

my $out = @ARGV[0];

# my @dir = ('../gpx', '../gpx-aquaris', '../gpx-navspark', '../gpx-holux', '../gpx-etrex30', '../gpx-etrex35', '../gpx-gpsmap66', '../gpx-opengps', '../gpx-connect', '../gpx-xoss');
my @dir = ('../gpx-new');

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;
$mon += 1;
$prefix = sprintf("%04d%02d%02d",$year,$mon,$mday);

# Initial options
if ($out eq 'sqlite') {
   print "Starting export to $prefix SQLite DB\n";
   system ("rm ..\/spatialite\/$prefix.fromgpx.sqlite");
   my $options = "-dsco INIT_WITH_EPSG=yes GPX_USE_EXTENSIONS=yes SPATIALITE=yes -lco GEOM_TYPE=g
eography";
} else {
   print "Starting export to Postgis DB\n";
   my $options = "-dsco INIT_WITH_EPSG=yes GPX_USE_EXTENSIONS=yes";
}

foreach $dir (@dir) {
  opendir( DIR, $dir) || die "Cannot open $dir\n";
  my @files = sort { $a <=> $b } readdir(DIR);
  while ( my $file = shift @files ) {
    next if ($file!~/\.gpx$/ or $file=~/waypoint/ or $file=~/china/
                           or $file=~/M-241_Total_Start/);
    print "File:\t$file\t";
    $filename = $file;
    # $filename =~ s/([\w+])\.[\d]+\.gpx/$1.gpx/ if ($filename =~ /^[\d-_]+\.\d+\.gpx/);
    print "$filename\n";
    if ($out eq 'sqlite') {
       system ("ogr2ogr -append -f SQLite $options -t_srs epsg:4326 ../spatialite/$prefix.fromgpx.sqlite \"$dir\/$file\"");
    } else {
       system("ogr2ogr -f GPX $options tmp.gpx \"$dir\/$file\" -sql \"select \'$filename\' as name, track_fid, track_seg_id, ele, time, sat, hdop, pdop, vdop, cmt from track_points\" ");
       system("ogr2ogr -append -f PostgreSQL \"PG:dbname=satnav host=localhost port=5432 user=edwin password=onkel-x\" $options -t_srs epsg:4326 tmp.gpx");
    }
    $options = "";
  }
}

