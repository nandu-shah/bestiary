#!/usr/bin/perl

use strict;
use warnings;

my $log_path   = shift;

my ($image_name, $style_name) = $log_path =~ m#output/(.+?)/(.+?)/#;

my $image_path = "images/$image_name.png";
my $style_path = "styles/$style_name.png";
my $html_path  = "./$image_name-$style_name.html";

my %table;
open my $log_fh, $log_path or die "couldn't open $log_path: $!\n";
$_ = <$log_fh>;
while (<$log_fh>) {
  my($img,$style,$slwe,$cwb,$preserve,$output,$cmd) = split /,/;
  $table{$preserve}->{$slwe}->{$cwb} = $output;
}

close $log_fh or die "WTAF: $!\n";


open my $html_fh, ">$html_path" or die "couldn't open $html_path: $!\n";
print $html_fh qq!<html><body>\n<img src="$image_path"><img src="$style_path">\n!;
foreach my $preserve (sort keys %table) {
  my @slwes = sort { $a <=> $b } keys %{$table{$preserve}};
  my @cwes  = sort { $a <=> $b } keys %{$table{$preserve}->{$slwes[0]}};

  print $html_fh "<table>\n";
  print $html_fh "<tr>\n<th></th>\n<th>";
  print $html_fh join("</th>\n<th>", @cwes), "</th>\n</tr>\n";

  foreach my $slwc (@slwes) {
    print $html_fh "<tr>\n<th>$slwc</th>\n";
    foreach my $cwe (@cwes) {
      my $output = "$image_name-$style_name/" . $table{$preserve}->{$slwc}->{$cwe};
      print $html_fh qq!<th><a href="$output"><img width="50%" src="$output"></a></th>\n!
    }

    print $html_fh "</tr>\n";
  }

  print $html_fh "</table>\n"
}

print $html_fh "</body></html>\n";
