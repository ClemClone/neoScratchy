#!/usr/bin/perl

use 5.10.0;
use strict;
use warnings;
use File::Slurp;

my $fnBase	= 'reg25m2';
my $fnExt	= 'dat';
my @columns = ('YEAR','TRAN','PLOT','SPEC','DAM','SZ0','SZ1','SZ2','SZ3','SZ4','SZ5','SZ6','SZ7','SZ8','SZ9');

my $path	= shift || '.';
# $path = '..\..\scratchData\CLEANED';
my ($ih, $oh, $bh);
my $count	= 1;

my $outputting	= 0;
my $test	= 'H11';

traverse($path);

sub traverse {  # Rummage through the hierarchy for files matching... something...
	my ($thing) = @_;
	if ($thing =~ /$fnBase(.+)\.$fnExt$/i) {
		say "$count $thing $&";  
		clean($thing);
		$count++;
	}
	return if not -d $thing;
	opendir my $dh, $thing or die;
	while (my $sub = readdir $dh) {
		next if $sub eq '.' or $sub eq '..';
		traverse("$thing/$sub");
	}
	close $dh;
	return;
}

sub clean {
	my ($inFName) = @_;
	my %bad;
my %good;
	my $line = 1;
	(my $outFName = $inFName) =~ s/([12][90]\d\d)\.dat/$1.csv/;
	my $dataYear = $1;
	(my $badFName = $inFName) =~ s/(.*)\.dat/$1BAD.txt/;
	open($ih, '<', $inFName) or die "Could not open file '$inFName' $!";
	if ($outputting) {
		open($oh, '>', $outFName) or die "Could not open file '$outFName' $!";
		open($bh, '>', $badFName) or die "Could not open file '$badFName' $!";
#		say $oh join(',', @columns);
	}
	while (<$ih>) {
		my ($tran, $plot, $spec, $dam) = (/^([CHLT]G?\d\d?) +(1?\d) +(\d?\d(?:\.1)?) +([0-3]) /g) 
				or ($bad{$line++} = $_) && next;
		my @trees = ($' =~ /(\d?\d\.\d)/g);
		$tran =~ s/G//;
		if ($tran =~ /([CHLT])(\d)$/) {$tran = $1 . '0' . $2}
		my @row = ($dataYear,$tran,$plot,$spec,$dam,0,0,0,0,0,0,0,0,0,0);
		for my $tree (0..$#trees) {
			$trees[$tree] =~ /(\d+)\.(\d)/;
			$row[$2+5] = $1;
		}
		$line++;
#$good{$tran} += 1;
$good{"$dataYear;$line"} = "@row" if ($tran eq $test);
#		say $oh join(',', @row) if $outputting;
	}
	myBads($bh, %bad) if $outputting;
myGoods(%good);
say "$inFName, $outFName, $badFName";
}

sub myBads {
	my ($bh, %tally)  = @_;
	say $bh "\n  *Bad Entries*";
	foreach my $head (sort {$a <=> $b} keys %tally) {
		print $bh "$head: $tally{$head}";
	}
}

sub myGoods {
	my (%tally)  = @_;
	foreach my $head (sort keys %tally) {
		say "$head: $tally{$head}";
	}
}