#!/usr/bin/perl -w
# This script determines if poly is in Exon or intron of gene
# parameters:  contig number
# command line: genExonStats.pl New2 Ani
use Getopt::Std;	# Standard IO package 
use strict;
use warnings;

my $spCodeUK = $ARGV[0];
my $spCodeRef = $ARGV[1];
my $polyFileName = "polysInGene.csv";
my $exonPolyFileName = "exonPolysInGene.csv";
my $dir =$spCodeUK."-".$spCodeRef."_Data/";


open POLYIN , "<".$dir.$polyFileName or die "\ntrouble opening $dir$polyFileName for append";
open POLYOUT , ">".$dir.$exonPolyFileName or die "\ntrouble opening $dir $exonPolyFileName for write";
print POLYOUT "Contig#\tGene ID\tGene start\tGene end\tPolymorphism Position \tMatch count\tMiss count\tIn Exon"; 
my ( $currentLine,$currentPos );
my ( @lines, @exonLines, @exonStart, @exonEnd, $geneID, $polyPos, $contig, $currentExon, $polyInExonFlag);
###################
#  loop: read line from polyfile, parse contig, eneID and poly posiiton, open exon map file, determine if poly is in exon.
###################
<POLYIN>;
<POLYIN>;
while ($currentLine = <POLYIN>)
{	chomp ($currentLine);
	print "\n>>>$currentLine<<<";
	$polyInExonFlag = 0;
	@lines = split(/\t/,$currentLine);
	$geneID = $lines[1];
	$polyPos =$lines[4];
	$contig = $lines[0];
	
	my $subdir = $dir."contig$contig/";
	my $exonMapFileName = $subdir."exonMap_contig".$contig."_gene".$geneID.".csv";
	open EXONFILE, "<".$exonMapFileName or die "\trouble opening $exonMapFileName for read";
	<EXONFILE>;
	<EXONFILE>;
	while( $currentExon = <EXONFILE> )
	{	print "\nInsdie while for  $geneID -->>>$currentExon<<";
		@exonLines = split(/\t/, $currentExon);
		if( $polyPos >= $exonLines[0]  && $polyPos <= $exonLines[1] )
		{	$polyInExonFlag = 1;
			print"\n\t\t\t\tPOLYINEXONFLAG +++++++++++++>>  $polyInExonFlag  ++++++++++++++++++";
		}
	}
	print POLYOUT "\n$currentLine\t$polyInExonFlag";
	print"\n#####################";
	print"\n$currentLine\t$polyInExonFlag";
	print"\n#####################";

	
}
close (POLYOUT);
close (POLYIN);