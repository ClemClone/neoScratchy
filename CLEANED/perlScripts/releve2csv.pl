#!/usr/bin/perl

use 5.10.0;
use strict;
use warnings;
use File::Slurp;

	# This script is for converting HRF releve data files to uniform .csv formats

# my $fnBase	= 'S1releve';
# my $fnExt	= 'dat';
# my @columns = ('YEAR','LINE','PLOT','SPEC','HT1','HT2','HT3');
# my $patt	= qr/^(2008) +([NS])0{0,2}([1-9]\d{0,2})/;
# my $fnBase	= 'S1rel';
# my $fnExt	= 's1d';
# my @columns = ('YEAR','LINE','PLOT','SPEC','HT1','HT2','HT3');
# my $patt	= qr/^(2011) +([NS])0{0,2}([1-9]\d{0,2})/;

my $fnBase	= 'S1rel';
my $fnExt	= 's1d';
my @columns = ('YEAR','LINE','PLOT','SPEC','HT1','HT2','HT3');
my $patt	= qr/^([12][90]\d\d) +([NS]) +(\d{1,3}) +(\d{1,4}(?:\.\d)?) +(\d{1,3}(?:\.1)?) +(\d{1,3}(?:\.1)?) +(\d{1,3}(?:\.1)?)/;

my $path	= shift || '.';
my ($ih, $oh, $bh);
my $stout	= *STDOUT;
my $count	= 1;

my $outputting	= 1;	# set to 1 for making .csv, 0 for test runs

traverse($path);

sub traverse {  # Rummage through the hierarchy for files matching... something...
	my ($thing) = @_;
	if ($thing =~ /$fnBase\..+\.$fnExt$/i) {	
		say $stout "    $count $thing";  
		clean($thing);
		$count++;
	}
	return if not -d $thing;
	opendir my $dh, $thing or die;
	while (my $sub = readdir $dh) {
		next if $sub eq '.' or $sub eq '..' or $sub eq 'CLEANED';
		traverse("$thing/$sub");
	}
	close $dh;
	return;
}

sub clean {
	my ($inFName) = @_;
	my %bad;
	my $line = 1;
	(my $outFName = $inFName) =~ s/\.$fnExt/.csv/;
	# $outFName = lc $outFName;
	my $dataYear = $1;
	(my $badFName = $inFName) =~ s/(.*)\.$fnExt/$1BAD.txt/;
	open($ih, '<', $inFName) or die "Could not open file '$inFName' $!";
	if ($outputting) {
		open($oh, '>', $outFName) or die "Could not open file '$outFName' $!";
		open($bh, '>', $badFName) or die "Could not open file '$badFName' $!";
	}
	say $oh join(',', @columns);

	LINE: while (<$ih>) {
		s/\.0//g;
		s/ \. / 0 /g;
		# my ($year, $line, $plot) = (/$patt/)
		my ($year, $line, $plot,$spec,$ht1,$ht2,$ht3) = (/$patt/)
				or ($bad{$line++} = $_) && next LINE;
		# my $remainder = $';
		# $remainder =~ s/\s\.\s/ 0 /g;
		# say $oh "$year,$line,$plot,", join(',',split(' ',$remainder));
		say $oh "$year,$line,$plot,$spec,$ht1,$ht2,$ht3";
		# while ($remainder =~ /(\d{1,4}(?:\s+(?:(?:\.1)|(?:\d{1,2}))){3})/gc) {	
			# say $oh "$year,$line,$plot,$spec,$ht1,$ht2,$ht3;";
			# say $oh "$year,$line,$plot,", join(',',split(' ',$1));
		# }
		$line++;
		# say $oh join(',', @row) if $outputting;
	}
	close $ih;
	close $oh;
	my $badCt = $outputting ? myBads($inFName, $bh, %bad) : 0;
	say $stout "$inFName, $outFName, $badFName";
	say $stout "$badCt/$line";
}

sub myBads {
	my ($inFName, $bh, %tally)  = @_;
	say $bh "  *Bad Entries for $inFName*";
	my $headCt = 0;
	foreach my $head (sort {$a <=> $b} keys %tally) {
		print $bh "$head: $tally{$head}";
		$headCt++;
	}
	return $headCt;
}


