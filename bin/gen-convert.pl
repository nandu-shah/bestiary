#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Std;

my %opts;
getopts('fn:', \%opts);

die "provide dimension with -n\n" unless defined $opts{n};
my $n = $opts{n};

my $dir = defined $opts{f} ? '$FEATHERED_DIR' : '$TILES_DIR';

print 'convert ';
print "-background transparent \\\n\t" if defined $opts{f};
for (my $i = 0; $i < $n; $i++) {
  print '\\( ';
  for (my $j = 0; $j < $n; $j++) {
    my $k = $i * $n + $j;
    print $dir, '/$IMAGE_NAME', "'_$k.png' \\\n\t";
  }

  print '+smush -$smush_value_w';
  print ' -background transparent' if defined $opts{f};
  print " \\) \\\n\t";
}

if (defined $opts{f}) {
  print '-background transparent';
}

else {
  print '-background none';
}

print " \\\n\t", '-smush -$smush_value_h \\', "\n\t";
print '$OUT_DIR/$IMAGE_NAME.large';
print '_feathered' if $opts{f};
print ".png\n";
