#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Std;

my %opts;
getopts('fn:w:h:', \%opts);

die "provide dimension with -n or combination of -w and -h\n"
  if defined $opts{n} and (defined $opts{w} or defined $opts{h});

die "provide dimension with -n or combination of -w and -h\n"
  unless defined $opts{n} xor (defined $opts{w} and defined $opts{h});

my($w, $h);
if (defined $opts{n}) {
  $w = $h = $opts{n};
}

else {
  $w = $opts{w};
  $h = $opts{h};
}

my $dir = defined $opts{f} ? '$FEATHERED_DIR' : '$TILES_DIR';

print 'convert ';
print "-background transparent \\\n\t" if defined $opts{f};
for (my $i = 0; $i < $h; $i++) {
  print '\\( ';
  for (my $j = 0; $j < $w; $j++) {
    my $k = $i * $w + $j;
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
