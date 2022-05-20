#!/usr/bin/perl
my @dir = ('.');

foreach $dir (@dir) {
  opendir( DIR, $dir) || die "Cannot open $dir\n";
  my @files = sort { $a <=> $b } readdir(DIR);
  while ( my $file = shift @files ) {
    next if ($file!~/\.fit/);
    $file =~ s/\.fit//g;
    system ("gpsbabel -i garmin_fit -o gpx $file.fit $file.gpx");
    print "$file.gpx\n";
  }
}
