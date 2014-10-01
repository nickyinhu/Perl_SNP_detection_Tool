#!/usr/bin/perl -w
# This script takes a matchCount file for a single contig and groups the individual position into ranges with similiar coverage count  
#	saves grouped count segments to file with fields:   start end count    and file name 'matchGroup_contig#X.csv'
# parameters:  contig number
use Getopt::Std;	# Standard IO package 
use strict;
use warnings;

my $readSize = 35;


my $contig = $ARGV[0];
my $geneID = $ARGV[1];
my $geneStart = $ARGV[2];
my $geneEnd = $ARGV[3];
# my $geneLayout = $ARGV[5];

my $countFileName = "matchCounts_contig$contig.csv";
my $geneCountFileName = "geneCounts_contig".$contig."_$geneID.csv";
my $geneGroupFileName = "geneGroups_contig".$contig."_$geneID.csv";
my $averageCoveragePerGeneFileName = "averageCoveragePerGene.csv";
my $noMatchFileName = "noReadGenes.csv";

my $spCodeUK = $ARGV[4];
my $spCodeRef = $ARGV[5];
my ($direction, $actStart, $actEnd, $geneLen, $totCount);
if($geneStart>$geneEnd)
{	$direction = "R";
	$actStart = $geneEnd;
	$actEnd = $geneStart;
	$geneLen = $geneStart - $geneEnd+1;
}else
{	$direction ="F";
	$actStart = $geneStart;
	$actEnd = $geneEnd;
	$geneLen = $geneEnd - $geneStart+1;
}


my $dir =$spCodeUK."-".$spCodeRef."_Data/";
my $subdir = $dir."contig$contig/";
if( -d $subdir )
{	#print "\n$subdir already exists";
}else
{	system("mkdir $subdir"); 
}
#print "\nActual Start: $actStart    End: $actEnd";

open TOTFILE, ">> ". $dir.$averageCoveragePerGeneFileName or die "\n trouble opeing average coverage record file for append:  $dir$averageCoveragePerGeneFileName";
open FULLCOUNTFILE, "<".$dir.$countFileName or die"\n trouble opening ".$dir.$countFileName." for reading";
open GENECOUNTFILE, ">".$subdir.$geneCountFileName or die"\n trouble opening ".$subdir.$geneCountFileName." for printing id info and header";
print GENECOUNTFILE ">contig:$contig....geneID:$geneID....geneStart:$geneStart....geneEnd:$geneEnd....direction:$direction";
close(GENECOUNTFILE);
open GENECOUNTFILE, ">>".$subdir.$geneCountFileName or die "\ntrouble opening ".$subdir.$geneCountFileName." for append" ;

open GENEGROUPFILE, ">".$subdir.$geneGroupFileName or die"\n trouble opening ".$subdir.$geneGroupFileName." for printing id info and header";
print GENEGROUPFILE ">contig:$contig....geneID:$geneID....geneStart:$geneStart....geneEnd:$geneEnd....direction:$direction";
print GENEGROUPFILE "start\tend\tcount";
close(GENEGROUPFILE);
open GENEGROUPFILE, ">>".$subdir.$geneGroupFileName or die "\ntrouble opening ".$subdir.$geneGroupFileName." for append" ;

open NOMATCHFILE, ">> ". $dir.$noMatchFileName or die "\n trouble opening no match  file for append:  $dir$noMatchFileName";


my ( $currentLine, $endPos, $startPos, $currentCount );
my ( @lines, @geneCounts);
my $continueFlag = 1;
$currentCount = 0;
###################
#  looking for gene start in contig count file 
###################
$currentLine = <FULLCOUNTFILE>; ### ignore header line in file
$currentLine = <FULLCOUNTFILE>;
if(!$currentLine)
{	print NOMATCHFILE "\nGene ID: ".$geneID;	
	close NOMATCHFILE;
	exit;
}
chomp($currentLine);

@lines = split(/\t/, $currentLine);
while ( $lines[0] < $actStart && !eof(FULLCOUNTFILE) )
{	$currentLine = <FULLCOUNTFILE>;
	chomp($currentLine);
	@lines = split(/\t/, $currentLine);
}
if ( eof(FULLCOUNTFILE))
{	$continueFlag = 0;
	print "\nEnd of file Before gene start position!!\n\n";
	print NOMATCHFILE "\nGene ID: ".$geneID;	
}
if(  !$currentLine eq "\n" && !$currentLine eq "\t")
{
	print GENECOUNTFILE "\n".$currentLine;
}
$startPos = $lines[0];
$endPos = $startPos;
$currentCount = $lines[1];
$totCount = $lines[1];
my $maxCount = 0;
###################
#  load match coverage info for gene
###################
if($continueFlag == 1)
{	$currentLine = <FULLCOUNTFILE>;
	chomp($currentLine);
	@lines = split(/\t/, $currentLine);
}
while($continueFlag == 1 && $lines[0] < $actEnd)
{	print GENECOUNTFILE "\n".$currentLine;
	if($currentCount == $lines[1])
	{	$endPos = $lines[0];
	}
	else
	{	if($currentCount > 0)
		{	print GENEGROUPFILE "\n$startPos\t$endPos\t$currentCount";
		}
		$startPos = $lines[0];
		$endPos = $startPos;
		$currentCount = $lines[1];
		$totCount = $totCount + $lines[1];
		if( $currentCount > $maxCount)
		{	$maxCount = $currentCount;
		}
	}
	if( eof(FULLCOUNTFILE) )
	{	last;
	}
	else
	{	$currentLine = <FULLCOUNTFILE>;
		if(!$currentLine || $currentLine eq "\n" || $currentLine eq "\t")
		{	last;
		}
		chomp($currentLine);
		#print "\nGrouping for gene: $currentLine      currentCount:$currentCount   start:$startPos    end:$endPos";
		@lines = split(/\t/, $currentLine);
	}
}
if($continueFlag == 0)
{	#print GENECOUNTFILE "\n".$currentLine;
	if(  !$currentLine eq "\n" && !$currentLine eq "\t")
	{
		print GENECOUNTFILE "\n".$currentLine;
	}
}
#if($currentCount > 0 )
{	if(  !$currentLine eq "\n" && !$currentLine eq "\t")
	{
		print GENEGROUPFILE "\n$startPos\t$endPos\t$currentCount";
	}
}
if ($maxCount == 0)
{	print NOMATCHFILE "\nGene ID: ".$geneID;	
}
my $aveCov = $totCount/$geneLen;
print TOTFILE "\n$geneID\t$geneLen\t$totCount\t$aveCov";
#print "\n$geneID\t$geneLen\t$totCount\t$aveCov";
close GENECOUNTFILE;
close GENEGROUPFILE;
close TOTFILE;
close NOMATCHFILE;
