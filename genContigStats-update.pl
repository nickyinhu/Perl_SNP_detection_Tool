#!/usr/bin/perl -w
# This script calcualtes the avaerge error and coverage per read alignment information
# parameters:  contig number
# command line: genContigStats.pl 250 New2 Ani Passwd
use Getopt::Std;	# Standard IO package 
use strict;
use warnings;
use DBI;			# needed for interfacing with DataBaseInterface

#####################################################################
my $contig = $ARGV[0];
my $spCodeUK = $ARGV[1];
my $spCodeRef = $ARGV[2];
my $user = $ARGV[3];
my $passwd = $ARGV[4];
#############################################################
# database connection information
my $db = "newFungi";
my $connectionInfo = "dbi:mysql:$db;localhost";
# make connection to MySQL database
print STDERR "\nConnecting to MySQL database $db with the user ID: $user\n";
my $dbHandle = DBI->connect($connectionInfo, $user, $passwd, {RaiseError => 1});
if (!$dbHandle) 
{	print "Cannot connect to the database $db!";
	exit (0);
}
print STDERR "\n\t Connection to Database HarrisGenome made";
#############################################################
my $matchCountFileName = "matchCounts_contig$contig.csv";
my $missCountFileName = "missCounts_contig$contig.csv";
my $dir =$spCodeUK."-".$spCodeRef."_Data/";
my $subdir = $dir."contig$contig/";

my $inGeneFileName = "polysInGene.csv";
my $outGeneFileName = "polysInterGene.csv";
my $contigStatsFileName="contigStats.csv";


my @results;

my($query, $queryHandle,@descriptions, @starts, @ends,@genes, $seq);
$query = "select geneID,start,stop from GeneCoordinates where contig = $contig order by start";
$queryHandle = $dbHandle->prepare($query);#$queryHandle->execute();
$queryHandle->execute();
my $count = 0;
while(@results = $queryHandle->fetchrow_array() )
{	
	push(@genes, $results[0]);
	if($results[1] > $results[2])
	{	push(@starts, $results[2]);
		push(@ends, $results[1]);
	}else
	{	push(@starts, $results[1]);
		push(@ends, $results[2]);	
	}
	$count++;
}



open INGENEFILE, ">>".$dir.$inGeneFileName or die "\ntrouble opening $dir $inGeneFileName for append";
open OUTGENEFILE, ">>".$dir.$outGeneFileName or die "\ntrouble opening $dir $outGeneFileName for append";
open CONFILE, ">>".$dir.$contigStatsFileName or die "\ntrouble opening $dir $contigStatsFileName for append";

open MATCHCOUNTFILE, "<".$dir.$matchCountFileName or die"\n trouble opening ".$dir.$matchCountFileName." for reading";
open MISSCOUNTFILE, "<".$dir.$missCountFileName or die"\n trouble opening ".$subdir.$missCountFileName." forreadoing";
my ( $currentLine,$currentPos );
my ( @lines, @matchDex,@matchCounts, %missCounts, @polymorphs);
###################
#  load MISS COUNTS TO ARRAY
###################
$currentLine = <MISSCOUNTFILE>;
my $totalMissCount = 0;
while(<MISSCOUNTFILE>)
{	$currentLine = $_;
	chomp($currentLine);
	#print"\nCurrent input:: $currentLine";
	@lines = split(/\t/,$currentLine);
	$totalMissCount = $totalMissCount + $lines[1];
	$missCounts{$lines[0]} = $lines[1];
}
my $totalMatchCounts =0;

$currentLine = <MATCHCOUNTFILE>;
while(<MATCHCOUNTFILE>)
{	$currentLine = $_;
	chomp($currentLine);
	#print"\nCurrent input:: $currentLine";
	@lines = split(/\t/,$currentLine);
	$totalMatchCounts = $totalMatchCounts + $lines[1];
	push (@matchDex, $lines[0]);
	push (@matchCounts, $lines[1]);
}
my $firstMatch = $matchDex[0];
my $lastMatch = $matchDex[@matchDex-1];
####################
# Calculate contig stats
####################
my $totalPositions = $lastMatch-$firstMatch;
my $averageCover = $totalMatchCounts/$totalPositions; 
my $totalSitesWithError = scalar keys %missCounts;
my $ratioSitesWithErrors = $totalSitesWithError/$totalPositions;
my $averageErrorAtErrorSites = $totalMissCount/$totalSitesWithError;
print"\nSTATISTICS  for contig #$contig";
print"\n              Total Positions:\t $totalPositions ";
print"\n             Average Coverage:\t $averageCover";
print"\n       Total Sites With Error:\t $totalSitesWithError";
print"\n  Ratio of Sites with errors :\t $ratioSitesWithErrors ";
print"\n Average error at error sites:\t $averageErrorAtErrorSites";
print"\n\nPosition\tmisses\tcover";
print CONFILE "\n$contig\t$totalMatchCounts\t$totalPositions\t$averageCover\t$totalSitesWithError\t$ratioSitesWithErrors\t$averageErrorAtErrorSites";
#####################
# look for polymorphism
#####################
my (@polyMorphPos, @missCount, @matchCount);
my ($dex, $currentMatchCount, $currentMatchPosition, $position, $value, $currentMissCount);
#foreach $position (%missCounts)
while(($position, $value) = each %missCounts)
{	if($position eq "contigPosition")
	{}else{
		$dex=$position - $firstMatch ;
		$currentMatchCount = $matchCounts[$dex];
		$currentMissCount = $missCounts{$position};	
		if($currentMatchCount*.5 < $currentMissCount)
		{	#print"\nhash position->>$position<<     index->>$dex<<    matchDex->>$matchDex[$dex]<<     misses->>$currentMissCount<<    matchCounts->>$currentMatchCount<<";   
			#print"\nPosition-> $position      misses-> $currentMissCount     matchCounts-> $currentMatchCount "; 
			#print"\n$position\t\t$currentMissCount\t$currentMatchCount"; 
			push(@polyMorphPos, $position);
			push(@missCount, $currentMissCount);
			push(@matchCount, $currentMatchCount);
		}
	}
}

my $polyPos;
for(my $dex = 0; $dex < @polyMorphPos; $dex++)
{	
	$polyPos = $polyMorphPos[$dex];
	my $geneFlag = 0;
	for(my $dex2 = 0; $dex2 < @genes; $dex2++)
	{
		if( $polyPos > $starts[$dex2] && $polyPos < $ends[$dex2])
		{	print "\ncontig: $contig\tgeneID: $genes[$dex2]\tpolyPos: $polyPos\tmisses: $missCount[$dex]\tmatch: $matchCount[$dex]\tstart: $starts[$dex2]\tend: $ends[$dex2] ";
			print INGENEFILE "\n$contig\t$genes[$dex2]\t$starts[$dex2]\t$ends[$dex2]\t$polyPos\t$matchCount[$dex]\t$missCount[$dex]"; 
			$geneFlag = 1;
		}
	}
	if($geneFlag == 0)
	{	print "\n  NOT IN GENE:\tpolyPos: $polyPos\tmisses: $missCount[$dex]\tmatch: $matchCount[$dex]";
		print OUTGENEFILE "\n$contig\t$polyPos\t$matchCount[$dex]\t$missCount[$dex]";
	}
	
}
print"\n\n";
close CONFILE;
close OUTGENEFILE;
close INGENEFILE;