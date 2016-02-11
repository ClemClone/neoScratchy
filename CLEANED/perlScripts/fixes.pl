#!/usr/bin/perl

use 5.10.0;
use strict;
use warnings;
# use diagnostics;
# use File::Slurp;

# Cat cleaned up csv files
my $inF;
my $lines = 0;
# my %hs;
my $heading = 0;

my $outfile = 'reg200m2.ALL.csv';

opendir my $dh, '.' or die "Could not open dir: $!";
open(my $oh, '>', $outfile) or die "Could not open outfile: $!";

while (readdir $dh) {
	if (/\.\d\d\d\d\.csv/) {
		$inF = $_;
		open(my $ih, '<', $inF) or die "Could not open infile: $!";
		# $hs{$1} = $ih;	# This seems to work but couldn't <> it below...
		while (<$ih>) {
			next if (/YEAR/ && $heading++ > 0);
#			s/^(\d\d),/19$1,/;	# This for early s1Seedling files
			print $oh $_;
		}
		say "  $inF: $. lines";
	}
}

# (my $outF = $inF) =~ s/s1Seedl[NS]/s1Seedling/;
# say "  $inF; $outF";
# open(my $oh, '>', $outF) or die "Could not open outfile $!";
# while (<{$hs{'N'}}>) {
		# s/^(\S+) +(\S+) +([^.]+\.)/$1 $2 0 $3/;
	# print $oh $_;
	# say "$.: $_";
# }


# # Add condition field to REG200M2.1997.dat
	# open(my $ih, '<', 'REG200M2.1997.dat') or die "Could not open infile $!";
	# open(my $oh, '>', 'REG200M2.1997COR.dat') or die "Could not open outfile $!";
	# while (<$ih>) {
		# s/^(\S+) +(\S+) +([^.]+\.)/$1 $2 0 $3/;
		# print $oh $_;
	# }
