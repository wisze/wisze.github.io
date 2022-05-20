#!c:\perl\bin\perl.exe

my $out = $ARGV[0];

# my @dir = ('../waypoints', '../gpx-holux', '../gpx-etrex30', '../gpx-etrex35', '../gpx-navspark');
my @dir = ('../waypoints-20220501');

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;
$mon += 1;
$prefix = sprintf("%04d%02d%02d",$year,$mon,$mday);

# Initial options
if ($out eq 'sqlite') {
   print "Making spatialite dump for $prefix\n";
   my $options = "-dsco INIT_WITH_EPSG=yes -dsco SPATIALITE=yes -lco GEOM_TYPE=geography";
} else {
   print "Making postgres dump for $prefix\n";
   my $options = "-dsco INIT_WITH_EPSG=yes";
}

foreach $dir (@dir) {
  opendir( DIR, $dir) || die "Cannot open $dir\n";
  my @files = sort { $a <=> $b } readdir(DIR);
  while ( my $file = shift @files ) {
    next if ($file!~/\.gpx$/ or $file=~/china/ or $file=~/M-241_Total_Start/);
    print "File:\t$file\n";
    if ($out eq 'sqlite') {
       system ("ogr2ogr -append -f SQLite $options -t_srs epsg:4326 ../spatialite/$prefix.fromgpx.sqlite \"$dir\/$file\"");
    } else {
       system("ogr2ogr -append -f PostgreSQL \"PG:dbname=satnav host=localhost port=5432 user=edwin password=onkel-x\" $options -t_srs epsg:4326 \"$dir\/$file\"");
    }
    $options = "";
  }
}

