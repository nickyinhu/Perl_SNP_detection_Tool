#!/usr/bin/perl -w
# This script takes genelayout string and creates an exon, intron coordinate file for it.  Parameters include Species Code and Contig number

use Getopt::Std;	# Standard IO package 
use strict;
use warnings;

my $readSize = 35;

my $spCode = $ARGV[0];
my $contig = $ARGV[1];
my $geneID = $ARGV[2];
my $geneLayout = $ARGV[3];
my $spCodeUK = $ARGV[4];


my $dir =$spCodeUK."-".$spCode."_Data/";
my $subdir = $dir."contig$contig/";
if( -d $subdir )
{	#print "\n\t\tSUB_DIRECTORY $subdir already exists";
}
else
{	system("mkdir $subdir"); 
}

my $exonMapFileName = "exonMap_contig".$contig."_gene$geneID.csv";
open EXONMAPFILE, ">".$subdir.$exonMapFileName or die "\nTrouble opening $exonMapFileName for printing header";
print EXONMAPFILE "geneID:$geneID\tcontig:$contig\tspeciesCode:$spCode";
print EXONMAPFILE "\nstart position\tend position";
close(EXONMAPFILE);

open EXONMAPFILE, ">>".$subdir.$exonMapFileName or die "\nTrouble opening $exonMapFileName for append";
my @exons = split (/,/,$geneLayout);
my ($currentExon, $start, $end);
#print "\n\n expression from MAP exons ".$geneLayout."  Segments: ".@exons;
while (@exons)
{	$currentExon = shift @exons;
	$currentExon =~/\.\./;
	$start = $`;
	$end = $';
	print EXONMAPFILE "\n$start\t$end";	
}
close(EXONMAPFILE);

