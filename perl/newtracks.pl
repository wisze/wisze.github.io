#
# Makes new tracks from track_points
#

use DBI;
use strict;

my $table = "newtracks";
my %maxdistance = ('notime'   => 0.100,
                   'rest'     => 0.250);
my $maxinterval = 900.0; # Max distance in seconds
my $minpoints   = 3;

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

my $create = 0;
if ($create) {
  my $sql = "
  create table $table (
               ogc_fid     serial not null primary key,
               name        varchar,
               starttime   timestamp with time zone,
               endtime     timestamp with time zone,
               cmt         varchar,
               src         varchar,
               link1_href  varchar,
               link1_text  varchar,
               link1_type  varchar,
               link2_href  varchar,
               link2_text  varchar,
               link2_type  varchar,
               number      integer,
               type        varchar,
               used        integer,
	       distance    float,
	       speed       float);
  ";
  my $sth = $dbh->prepare($sql);  
  $sth->execute();
  $dbh->commit or print $DBI::errstr;
  $sth->finish;
  print "Table $table created\n";
  #
  $sql = "select addgeometrycolumn(\'$table\','wkb_geometry', 4326, 'LINESTRING', 2);";
  $sth = $dbh->prepare($sql);  
  $sth->execute();
  $dbh->commit or print $DBI::errstr;
  $sth->finish;
  print "Table $table geometry\n";
}

my $sql = "delete from $table;";
my $sth = $dbh->prepare($sql);  
$sth->execute() or print $DBI::errstr;
$dbh->commit or print $DBI::errstr;
$sth->finish;
print "Table $table cleared\n";

# Get the list
my %sqlsel;
$sqlsel{notime} = "SELECT ogc_fid, time,
       ST_AsText(wkb_geometry)  as point,
       ST_AsText(next_geometry) as nextpoint,
       ST_X(wkb_geometry) as lon, ST_Y(wkb_geometry) as lat,
       ele,
       ST_DISTANCE(wkb_geometry, prev_geometry) AS distance,
       time as timestep,
       name, prev_name
  FROM (SELECT ogc_fid,
               name,
               time,
               wkb_geometry,
               ele,
               LAG(name) OVER (ORDER by name, ogc_fid ASC) AS prev_name,
               LAG(wkb_geometry) OVER (ORDER by name, ogc_fid ASC) AS prev_geometry,
               LEAD(wkb_geometry) OVER (ORDER by name, ogc_fid ASC) AS next_geometry
          FROM track_points
          WHERE time IS NULL
          ORDER BY name, ogc_fid ASC
       ) f ";
$sqlsel{rest} = "SELECT ogc_fid, time,
       ST_AsText(wkb_geometry)  as point,
       ST_AsText(next_geometry) as nextpoint,
       ST_X(wkb_geometry) as lon, ST_Y(wkb_geometry) as lat,
       ele,
       ST_DISTANCE(wkb_geometry, prev_geometry) AS distance,
       extract(epoch from (time::timestamp - prev_time::timestamp)) AS timestep,
       name, prev_name
  FROM (SELECT ogc_fid,
               name,
               time,
               wkb_geometry,
               ele,
               LAG(time) OVER (ORDER by name, time::timestamp ASC) AS prev_time,
               LAG(name) OVER (ORDER by name, time::timestamp ASC) AS prev_name,
               LAG(wkb_geometry)  OVER (ORDER by name, time::timestamp ASC) AS prev_geometry,
               LEAD(wkb_geometry) OVER (ORDER by name, time::timestamp ASC) AS next_geometry
          FROM track_points
          WHERE time IS NOT NULL
          ORDER BY name, time::timestamp ASC
       ) f  ";

foreach my $type ( 'notime', 'rest') {
   my $starttime = 0;
   my $endtime   = 0;
   my @line = ();
   my $number = 0;
   my $nlines = 0;

   my $sthsel = $dbh->prepare($sqlsel{$type}); 
   $sthsel->execute();
   while (my @row = $sthsel->fetchrow_array ) {  
      my $time      = $row[1];
      my $newpoint  = "ST_GeomFromText(\'".$row[2]."\',4326)";
      my $nextpoint = $row[3];
      my $elevation = $row[6];
      my $distance  = $row[7];
      my $interval  = $row[8];
      my $name      = $row[9];
      my $prevname  = $row[10];
      if (scalar(@line)==0) {$starttime = $time;}
      #----------------------------------------------------------------------
      # if distance to the previous point is small, there is a next value
      # and the time to the previous point is also small 
      # and they are both from the same file then add to the line
      if (($distance < $maxdistance{$type} && $nextpoint ne '') && 
          ($interval < $maxinterval || $type eq 'notime') &&
          ($name eq $prevname && $prevname ne '')) {
         push(@line,$newpoint);
         $endtime = $time;
         $number = scalar(@line);
      } else {
         my $sqlins="INSERT INTO $table (wkb_geometry, number, name, starttime, endtime)
                     VALUES (ST_MakeLine(ARRAY[".join(',',@line)."]),
                            \'$number\',\'$prevname\',\'$starttime\',\'$endtime\')";
         if ($type eq 'notime') {
            $sqlins="INSERT INTO $table (wkb_geometry, number, name) 
                     VALUES (ST_MakeLine(ARRAY[".join(',',@line)."]), \'$number\',\'$prevname\')";
         }
         my $points = scalar(@line);
         if ($points > $minpoints) {
            my $sthins = $dbh->prepare($sqlins); 
            $sthins->execute();
            $sthins->finish;
            $dbh->commit or die $DBI::errstr;
            $nlines++;
         }
         @line = ($newpoint);
         $starttime = $time;
      } 
   }
   print "$nlines for $type\n";
   $sthsel->finish;

# Now compute distances
#   my $sqldst ="UPDATE $table
#                SET length=l
#                WHERE l IN (SELECT ST_Length(wkb_geometry) FROM $table );";
#   my $sthdst = $dbh->prepare($sqldst); 
#   $sthdst->execute();
#   $sthdst->finish;
#   $dbh->commit or die $DBI::errstr;
}

$dbh->commit or die $DBI::errstr;
$dbh->disconnect;
