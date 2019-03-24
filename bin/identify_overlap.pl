#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Std;
use Image::Magick;

my %opts;
getopts('n:p:', \%opts);

$opts{p} //= 0.1;

die "provide dimension with -n\n" unless defined $opts{n};

my $file = shift || die "filename required\n";
my $image = Image::Magick->new();

$image->Read($file);

my $width  = $image->Get('width');
my $height = $image->Get('height');

my $overlap_w = sprintf('%.0f', $width * $opts{p} / $opts{n});
my $overlap_h = sprintf('%.0f', $height * $opts{p} / $opts{n});

print $width, 'x', $height, "\n";
print "overlap_w=$overlap_w\n";
print "overlap_h=$overlap_h\n";
