#!/usr/bin/perl

my $file = "/home/lookshe/myips.txt";

open(FILE, $file) || die("unable to open $file!");
my @lines = <FILE>;
close(FILE);

for ($i = 1; $i <= $#lines-2; $i+=2)
{
   my $ip = $lines[$i];
   chomp($ip);
   my $nextip = $lines[$i+2];
   chomp($nextip);
   if ($ip !~ m/^$nextip$/)
   {
      my $time = $lines[$i+1];
      chomp($time);
      print "$time: $ip -> $nextip\n";
   }
}
