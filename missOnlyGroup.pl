#!/usr/bin/perl -w
# This script splits the miss file into gene files depending where the misses occure.

use Getopt::Std;	# Standard IO package 
use strict;
use warnings;

my $readSize = 35;
my $contig = $ARGV[0];
my $geneID = $ARGV[1];
my $geneStart = $ARGV[2];
my $geneEnd = $ARGV[3];

my $spCodeUK = $ARGV[4];
my $spCodeRef = $ARGV[5];

my $missInFileName = "missCoverage_contig$contig.csv";
my $geneMissFileName = "geneMissCounts_contig".$contig."_$geneID.csv";my ($direction, $actStart, $actEnd);
if($geneStart>$geneEnd)
{	$direction = "R";
	$actStart = $geneEnd;
	$actEnd = $geneStart;
}else
{	$direction ="F";
	$actStart = $geneStart;
	$actEnd = $geneEnd;
}
my $dir =$spCodeUK."-".$spCodeRef."_Data/";
my $subdir = $dir."contig$contig/";
if( -d $subdir )
{	#print "\n\t\tSUB_DIRECTORY $subdir already exists";
}else
{	system("mkdir $subdir"); 
}

open MISSINFILE, "<".$dir.$missInFileName or die"\n trouble opening ".$dir.$missInFileName." for reading";
open GENEMISSCOUNTFILE, ">".$subdir.$geneMissFileName or die"\n trouble opening ".$subdir.$geneMissFileName." for printing id info and header";
print GENEMISSCOUNTFILE ">contig:$contig....geneID:$geneID....geneStart:$geneStart....geneEnd:$geneEnd....direction:$direction";
close(GENEMISSCOUNTFILE);
open GENEMISSCOUNTFILE, ">>".$subdir.$geneMissFileName or die "\ntrouble opening ".$subdir.$geneMissFileName." for append" ;


my ( $currentLine, $endPos, $startPos, $currentCount );
my ( @lines, @geneCounts);
$currentCount = 0;
###################
#  looking for gene start in contig count file 
###################
$currentLine = <MISSINFILE>; ### ignore header line in file
$currentLine = <MISSINFILE>;
if(!$currentLine)
{
	exit;
}
chomp($currentLine);
#print "\n\tFirst  Line: $currentLine";
#print "\n\t\tlooking for start loop  Line: $currentLine";
@lines = split(/\t/, $currentLine);
while ( $lines[3] < $actStart )
{	
	$currentLine = <MISSINFILE>;
	if(!$currentLine)
	{	print"\nEnd of file before gene start found";
		close GENEMISSCOUNTFILE;
		exit 0;
	}
	chomp($currentLine);
	@lines = split(/\t/, $currentLine);
}

#print"\nAfter it should have exitedf\n";
print GENEMISSCOUNTFILE "\n".$currentLine;
$startPos = $lines[0];
$endPos = $startPos;
$currentCount = $lines[1];
###################
#  load match coverage info for gene
###################
$currentLine = <MISSINFILE>;
chomp($currentLine);
#print "\n\tloading gene: $currentLine";
@lines = split(/\t/, $currentLine);
while($lines[3] < ($actEnd +1))
{	
	print GENEMISSCOUNTFILE "\n".$currentLine;
	if( eof(MISSINFILE) )
	{
		last;
	}
	else
	{	$currentLine = <MISSINFILE>;
		chomp($currentLine);
		#print "\nGrouping for gene: $currentLine      currentCount:$currentCount   start:$startPos    end:$endPos";
		@lines = split(/\t/, $currentLine);
	}
}

close GENEMISSCOUNTFILE;

