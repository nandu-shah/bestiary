#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Std;
use Image::Magick;

my %opts;
getopts('whn:p:', \%opts);

$opts{p} //= 0.1;

die "provide dimension with -n\n" unless defined $opts{n};
die "provide exactly one of -w and -h\n"
  unless defined $opts{w} xor defined $opts{h};

my $file = shift || die "filename required\n";
my $image = Image::Magick->new();

$image->Read($file);

my $width  = $image->Get('width');
my $height = $image->Get('height');

printf("%.0f\n", $width * $opts{p} / $opts{n}) if $opts{w};
printf("%.0f\n", $height * $opts{p} / $opts{n}) if $opts{h};
