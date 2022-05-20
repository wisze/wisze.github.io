# Get waypoint list and make a gpx file

use DBI;
# use strict;

my $nwpt = 0;

# Connection config
my $dbname = 'satnav';  
my $host   = 'localhost';  
my $username = 'edwin';  
my $password = 'onkel-x';  
# Create DB handle object by connecting
my $dbh = DBI -> connect("dbi:Pg:dbname=$dbname;host=$host",  
                         $username, $password,
                         {AutoCommit => 0, RaiseError => 1}
                         ) or die $DBI::errstr;

# Get the list
my $sqlsel = "select ogc_fid,name,time,ele,sat,hdop,vdop,pdop,sym,type,fix,sat,cmt,st_x(wkb_geometry) as lon,st_y(wkb_geometry) as lat from waypoints order by time asc;";
my $sthsel = $dbh->prepare($sqlsel);  
$sthsel->execute();

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;
$mon += 1;
$today = sprintf("%04d-%02d-%02d",$year,$mon,$mday);
open(GPX,">wpt-$today.gpx");

print GPX '<?xml version="1.0" encoding="UTF-8" standalone="no" ?>
<gpx xmlns="http://www.topografix.com/GPX/1/1" version="1.1">
  <metadata>
    <name>wisze.net waypoints</name>
  </metadata>'."\n";

while (my $hr = $sthsel->fetchrow_hashref) {
   for my $col (keys %$hr) {
      # print " $col ".$hr->{$col};
   }
   # 2010-03-12 13:20:41+01
   my $t  = $hr->{time};
   $t =~ s/([-\d]+)\ ([\d:]+)\+(\d+)/$1T$2Z/g;
   print GPX '  <wpt lat="'.$hr->{lat}.'" lon="'.$hr->{lon}.'">'."\n";
   print GPX '    <name>'.$hr->{name}.'</name>'."\n" if ($hr->{name});
   print GPX '    <time>'.$t.'</time>'."\n" if ($t);
   for my $tag ('ele', 'cmt', 'hdop', 'vdop', 'pdop', 'sym', 'type', 'fix', 'sat') {
      print GPX '    <'.$tag. '>'.$hr->{$tag}.'</'.$tag.'>'."\n" if ($hr->{$tag});
   }
   print GPX '  </wpt>'."\n";
   $nwpt++;
}
print GPX '</gpx>'."\n";
close(GPX);

$dbh->commit or die $DBI::errstr;
$dbh->disconnect;

print "$nwpt waypoints gevonden\n";
