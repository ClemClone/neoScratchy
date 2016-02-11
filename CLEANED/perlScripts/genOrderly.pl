#!/usr/bin/perl

use 5.10.0;
use strict;
use warnings;
use File::Slurp;
		
		# Left in non-working state, half through rearranging for sorting lines and concatenating

my $fnBase	= 's1Seedl';
my $fnExt	= 'csv';
my @columns = ('YEAR','QUAD','SPEC','COND','SZ2','SZ3','SZ4','SZ5','SZ6','SZ7','SZ8','SZ9');
my $patt	= qr/^([3-8][A-J][1-4]) +(\d?\d(?:\.1)?) +([0-3]) /;
my $rowIncr	= 4 - 2;	# 4 cols before size classes minus 0 and 1 classes absent.  Kludgy!
	(my $outFName = $inFName) =~ s/s1Seedl[NS]\.(201\d)(COR)?\.csv/s1Seedling.$1.csv/;

my $path	= shift || '.';
my ($ih, $oh, $bh);

my $count	= 1;
my $outputting	= 0;

traverse($path);

sub traverse {  # Rummage through the hierarchy for files matching... something...
	my ($thing) = @_;
	if ($thing =~ /$fnBase(.+)\.$fnExt$/i) {
		say "$count $thing";  
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
	open($ih, '<', $inFName) or die "Could not open file '$inFName' $!";
	if ($outputting) {
		open($oh, '>', $outFName) or die "Could not open file '$outFName' $!";
		say $oh join(',', @columns);
	}
	while (<$ih>) {
##25m2	my ($tran, $plot, $spec, $dam) = (/$patt/g) 
		my ($quad, $spec, $cond) = (/$patt/g) 
				or ($bad{$line++} = $_) && next;
		my @trees = ($' =~ /(\d?\d\.\d)/g);
##25m2		$tran =~ s/G//;
##25m2		if ($tran =~ /([CHLT])(\d)$/) {$tran = $1 . '0' . $2}
##25m2		my @row = ($dataYear,$tran,$plot,$spec,$dam,0,0,0,0,0,0,0,0,0,0);
		my @row = ($dataYear,$quad,$spec,$cond,0,0,0,0,0,0,0,0);
		for my $tree (0..$#trees) {
			$trees[$tree] =~ /(\d+)\.(\d)/;
			$row[$2+$rowIncr] = $1;
		}
		$line++;
		say $oh join(',', @row) if $outputting;
	}
	my $badCt = $outputting ? myBads($inFName, $bh, %bad) : 0;
say "$inFName, $outFName";
say "$badCt/$line";
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


