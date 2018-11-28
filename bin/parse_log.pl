use strict;
use warnings;

my $re =
    '--content ' . $ENV{PWD} . '/(\S+) --styles ' . $ENV{PWD} . '/(\S+) ' .
    '--style-layer-weight-exp (\S+) --content-weight-blend (\S+) ' .
    '--output ' . $ENV{PWD} . '/(\S+)( --preserve-colors)?';

my %tables;
while (<>) {
  chomp;
  my ($image, $style, $slwe, $cwb, $output, $pc)  = /$re/;

  $pc ||= 0;
  $pc = 1 if $pc;


  $tables{$image}->{$style}->{$pc}->{$slwe}->{$cwb} = $output;
}

foreach my $img (keys %tables) {
  my ($html) = $img =~ m#([^/]+)$#;
  $html =~ s/\.jpg/.html/;
  open(my $fh, ">$html") || die "$html: $!\n";
  print $fh qq!<html><body><h1>$img</h1>\n<img width="25%" src="$img">\n!;
  foreach my $st (keys %{$tables{$img}}) {
    print $fh qq!<h2>$st</h2>\n<img width="25%" src="$st">\n!;
    foreach my $p (keys %{$tables{$img}->{$st}}) {
      if ($p) {
	print $fh "<h3>Preserve colors</h3>\n";
      }

      else {
	print $fh "<h3>Don't preserve colors</h3>\n";
      }

      my @sl = sort { $a <=> $b } keys %{$tables{$img}->{$st}->{$p}};
      my @c  = sort { $a <=> $b } keys %{$tables{$img}->{$st}->{$p}->{$sl[0]}};

      print $fh "<table>\n";
      print $fh "<tr>\n<th></th>\n<th>";
      print $fh join("</th>\n<th>", @c), "</th>\n</tr>\n";

      foreach my $sl (@sl) {
	print $fh "<tr>\n<th>$sl</th>\n";
	foreach my $c (@c) {
	  my $o = $tables{$img}->{$st}->{$p}->{$sl}->{$c};
	  print $fh qq!<th><img width="50%" src="$o"></th>\n!
	}

	print $fh "</tr>\n";
      }

      print $fh "</table>\n";
    }
  }

  print $fh "</body></html>\n";
}
