#!/usr/bin/perl

use 5.10.0;
use strict;
use warnings;
use File::Slurp;

	# This script is for reading Holt species codes and adding FIA codes;
	# maybe some other similar things too.  The list going into %fiaSpecies
	# comes from TreeRegeneration200m2_Meta.txt, plus extras.
my %fiaSpecies = (
	0 => '000', # occasional explicit zeros in data for null counts
	1 => '129', # WP    /*Pinus strobus (white pine)              */
	2 => '097', # RS    /*Picea rubens (red spruce)               */
	3 => '012', # BF    /*Abies balsamia (balsam fir)             */
	4 => '261', # HE    /*Tsuga canadensis (hemlock)              */
	5 => '833', # RO    /*Quercus rubra (red oak)                 */
	6 => '802', # WO    /*Quercus alba (white oak)                */
	7 => '316', # RM    /*Acer rubrum (red maple)                 */
	8 => '371', # YB    /*Betula alleghaniensis (yellow birch)    */
	9 => '375', # PB    /*Betula papyrifera (paper birch)         */
	10 => '379', # GB    /*Betula populifolia (gray birch)         */
	11 => '531', # BE    /*Fagus grandifolia (beech)               */
	12 => '541', # WA    /*Fraxinus americana (white ash)          */
	13 => '315', # MM    /*Acer pensylvanicum (striped maple)      ???*/
	14 => '743', # btasp /*Populus grandidentata (bigtooth aspen)  */
	15 => '746', # qa    /*Populus tremuloides (quaking aspen)     */
	16 => '762', # bc    /*Prunus serotina (black cherry)          */
	17 => '660', # apl   /*Pyrus malus (apple)                     */
	18 => '701', # HH    /*Ostrya virginiana (hop hornbeam)        */
	19 => '125', # PP    /*Pinus resinosa (red pine)               */
	20 => '126', # RP    /*Pinus rigida (pitch pine)               */
	25 => '585', # witch /*Hamamelis virginiana (witch hazel)      */
	26 => '350', # alder /*Alnus sp. (alder sp.)                   */
	21 => '241', # 		/* Thuja occidentalis (northern white-cedar)	*/
	22 => '095', # 		/* Picea mariana (black spruce)	*/
	23 => '544', # 		/* Fraxinus pennsylvanica (green ash)	*/
	24 => '318', # 		/* Acer saccharum (sugar maple)	*/
	27 => '837', # 		/* Quercus velutina (black oak)	*/
	28 => '330', # 		/* Aesculus (horsechestnut)	*/
	29 => '502', # 		/* Corylus cornuta (beaked hazelnut)	*/
);
#say "\%speciesCodes = @{[%speciesCodes]}\n";

	# The following chunks match the formatting for the several types
	# of dataset that want this translation
my $fnBase	= 'reg4m2GP';
my $fnExt	= 'dat';
my @columns = ('YEAR','GAP','PLOT','SPEC','FIASP','HT1','HT2','HT3','HT4');
my $patt	= qr/^([3-8][A-J][1-4][A-Z])\.?(\d) +(\d?\d(?:\.\d)?) /;
my $szRng	= qr/[1-4]/;
my $rowIncr	= 5 - 1;	# index of first sz minus min of $szRng

# my $fnBase	= 'reg4m2';
# my $fnExt	= 'dat';
# my @columns = ('YEAR','QUAD','PLOT','SPEC','FIASP','HT1','HT2','HT3','HT4');
# my $patt	= qr/^([3-8][A-J][1-4])(\d) +(\d?\d(?:\.\d)?) /;
# my $szRng	= qr/[1-4]/;
# my $rowIncr	= 5 - 1;	# index of first sz minus min of $szRng

# my $fnBase	= 'reg25m2';
# my $fnExt	= 'dat';
# my @columns = ('YEAR','TRAN','PLOT','SPEC','FIASP','DAM','SZ0','SZ1','SZ2','SZ3','SZ4','SZ5','SZ6','SZ7','SZ8','SZ9');
# my $patt	= qr/^([CHLT]G?\d\d?) +(1?\d) +(\d?\d(?:\.1)?) +([0-3]) /;
# my $szRng	= qr/[0-9]/;
# my $rowIncr	= 6 - 0;	# index of first sz minus min of $szRng

# my $fnBase	= 'REG200M2';
# my $fnExt	= 'dat';
# my @columns = ('YEAR','QUAD','SPEC','FIASP','COND','SZ2','SZ3','SZ4','SZ5','SZ6','SZ7','SZ8','SZ9');
# my $patt	= qr/^([3-8][A-J][1-4]) +(\d?\d(?:\.1)?) +([0-3]) /;
# my $szRng	= qr/[2-9]/;
# my $rowIncr	= 5 - 2;	# index of first sz minus min of $szRng

my $path	= shift || '.';
my ($ih, $oh, $bh);
my $count	= 1;
my $outputting	= 1;

traverse($path);

sub traverse {  # Rummage through the hierarchy for files matching... something...
	my ($thing) = @_;
	if ($thing =~ /$fnBase\.\d\d\d\d(COR)?\.$fnExt$/i) {	# made year match explicit for 4m2 to stop GP files
		say "    $count $thing";  
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
	(my $outFName = $inFName) =~ s/([12][90]\d\d)(COR)?\.dat/$1.csv/;
	my $dataYear = $1;
	(my $badFName = $inFName) =~ s/(.*)(COR)?\.dat/$1BAD.txt/;
	open($ih, '<', $inFName) or die "Could not open file '$inFName' $!";
	if ($outputting) {
		open($oh, '>', $outFName) or die "Could not open file '$outFName' $!";
		open($bh, '>', $badFName) or die "Could not open file '$badFName' $!";
		say $oh join(',', @columns);
	}
	LINE: while (<$ih>) {
		my ($quad, $plot, $spec) = (/$patt/g)			# 4m2
		# my ($tran, $plot, $spec, $dam) = (/$patt/g)	# 25m2
		# my ($quad, $spec, $cond) = (/$patt/g)			# 200m2
				or ($bad{$line++} = $_) && next LINE;
		my @trees = ($' =~ /(\d?\d\.\d)/g);
		if ($spec =~ /\.0/) { $spec = $`}
		$spec =~ /^(\d?\d)\.?/;
		my $fiaSp = ($fiaSpecies{$1} or '999');
		# $tran =~ s/G//;										# 25m2
		# if ($tran =~ /([CHLT])(\d)$/) {$tran = $1 . '0' . $2}	# 25m2
		my @row = ($dataYear,$quad,$plot,$spec,$fiaSp,0,0,0,0);						# 4m2
		# my @row = ($dataYear,$tran,$plot,$spec,$fiaSp,$dam,0,0,0,0,0,0,0,0,0,0);	# 25m2
		# my @row = ($dataYear,$quad,$spec,$fiaSp,$cond,0,0,0,0,0,0,0,0);			# 200m2
		for my $tree (0..$#trees) {				# Through the array of trees
			$trees[$tree] =~ /(\d+)\.($szRng)/	# break out count ($1) and size class ($2),
				or ($bad{$line++} = $_) && next LINE;
			$row[$rowIncr + $2] = $1;				# incr past other cols and put count in class column
		}
		$line++;
		say $oh join(',', @row) if $outputting;
	}
	close $ih;
	my $badCt = $outputting ? myBads($inFName, $bh, %bad) : 0;
	say "$inFName, $outFName, $badFName";
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

