#
# Get the glonass locations and put them in a separate table
# Schema of the original table track_points
#    |       Column       |           Type           |
#    |--------------------+--------------------------+
#    | ogc_fid            | integer                  |
#    | track_fid          | integer                  |
#    | track_seg_id       | integer                  |
#    | track_seg_point_id | integer                  |
#    | ele                | double precision         |
#    | time               | timestamp with time zone |
#    | magvar             | double precision         |
#    | geoidheight        | double precision         |
#    | name               | character varying        |
#    | cmt                | character varying        |
#    | desc               | character varying        |
#    | src                | character varying        |
#    | link1_href         | character varying        |
#    | link1_text         | character varying        |
#    | link1_type         | character varying        |
#    | link2_href         | character varying        |
#    | link2_text         | character varying        |
#    | link2_type         | character varying        |
#    | sym                | character varying        |
#    | type               | character varying        |
#    | fix                | character varying        |
#    | sat                | integer                  |
#    | hdop               | double precision         |
#    | vdop               | double precision         |
#    | pdop               | double precision         |
#    | ageofdgpsdata      | double precision         |
#    | dgpsid             | integer                  |
#    | wkb_geometry       | geometry                 |

use DBI;
use strict;

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

# Drop and create the glonass table
my $sql = "drop table glonass;";
my $sth = $dbh->prepare($sql);  
$sth->execute() or print $DBI::errstr;
$dbh->commit or print $DBI::errstr;

my $sql = "
create table glonass (
             ogc_fid integer,
             view    integer,
             used    integer);
";
# select addgeometrycolumn('glonass','wkb_geometry', 4326, 'POINT', 2);
my $sth = $dbh->prepare($sql);  
$sth->execute();
$dbh->commit or print $DBI::errstr;

# Get the list
my $sqlsel = "select ogc_fid,time,wkb_geometry,ele,sat,hdop,vdop,pdop,cmt,st_x(wkb_geometry),st_y(wkb_geometry) from track_points where cmt like \'%glo_used%\' and time is not null order by time asc;";
my $sthsel = $dbh->prepare($sqlsel);  
$sthsel->execute();
my $sqlins = "insert into glonass (ogc_fid,view,used) values (?,?,?);";
my $sthins = $dbh->prepare($sqlins);  

while (my @row = $sthsel->fetchrow_array ) {  
   my @values = ($row[8] =~ m/glo_[a-z]+=(\S+)/g);
   # print $row[0]."\t".join("\t",@row[2..7])."\t";
   # print join(',',@values)."\t";
   # print "\t".join("\t",@row[8..9])."\n";
   print $row[0],',',join(',',@values)."\n";
   $sthins->execute(@row[0],@values);
}

$dbh->commit or die $DBI::errstr;
$dbh->disconnect;
