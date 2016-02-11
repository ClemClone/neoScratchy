#!/usr/bin/perl

#	For checking completeness of the (csv) data files 

use 5.10.0;
# use strict;
use warnings;
use File::Slurp;
use Data::Dumper;

my $path	= shift || '.';
$path = '..\..\scratchData\CLEANED';

my $fnBase	= 'reg200m2';
my $fnExt	= 'csv';
# my @columns = ('YEAR','TRAN','PLOT','SPEC','FIASP','DAM','SZ0','SZ1','SZ2','SZ3','SZ4','SZ5','SZ6','SZ7','SZ8','SZ9');

my $outputting	= 0;
my $test	= 'H11';

my ($ih, $oh, $bh);
my $count	= 0;
my %good;

traverse($path);
myGoods(%good);

sub traverse {  # Rummage through the hierarchy for files matching... something...
	my ($thing) = @_;
	if ($thing =~ /$fnBase(.+)\.$fnExt$/i 
		&& $thing !~ /1984/
		) {
		say ++$count . " $&";  
		inspect($thing);
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

sub inspect {
	my ($inFName) = @_;
	my %bad;
	my $line = 1;
	(my $outFName = $inFName) =~ s/([12][90]\d\d)\.dat/$1.csv/;
	my $dataYear = $1;
	(my $badFName = $inFName) =~ s/(.*)\.dat/$1BAD.txt/;
	open($ih, '<', $inFName) or die "Could not open file '$inFName' $!";
	if ($outputting) {
		open($oh, '>', $outFName) or die "Could not open file '$outFName' $!";
		open($bh, '>', $badFName) or die "Could not open file '$badFName' $!";
	}
	while (<$ih>) {
		# my ($year,$tran,$plot,$spec,$fiasp,$dam,@stems) = split ',';	# 25m2
		# my $sample = join('-', $tran,$plot);							# 25m2
		my ($year,$quad,$spec,$fiasp,$cond,@stems) = split ',';			# 200m2
		my $sample = join('-', $quad);							# 200m2
		# push(@{$good{$sample}}, $year);
# ${$good{$sample}{$year}} += 1;
$good{$sample}{$year} += 1;
# $good{$sample} += 1;
		$line++;
	}
}

sub myGoods {
#print Dumper(\%good);
	my (%tally)  = @_;
	foreach my $sample (sort keys %tally) {
		my $yrCt = keys(%{$tally{$sample}});
		say "$sample: $yrCt";
		foreach my $yr (sort keys %{$tally{$sample}}) {
			# say $yr;
			# say "$sample/$yr: $tally{$sample}{$yr}" if $yrCt < $count;
			# say "$sample/$yr: $yrCt" 
				# # if $yrCt < $count
				;
		}
	}
}

# sub myBads {
	# my ($bh, %tally)  = @_;
	# say $bh "\n  *Bad Entries*";
	# foreach my $head (sort {$a <=> $b} keys %tally) {
		# print $bh "$head: $tally{$head}";
	# }
# }
