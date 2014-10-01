#!/usr/bin/perl -w
# This script counts the coverage at each position along it's length starting with the first actual match position.

use Getopt::Std;	# Standard IO package 
use strict;
use warnings;

my $readSize = 35;

my $contig = $ARGV[0];
my $spCodeUK = $ARGV[1];
my $spCodeRef = $ARGV[2];
my $matchInFileName = "matchCoverage_contig$contig.csv";
my $missInFileName = "missCoverage_contig$contig.csv";
my $countFileName = "missCounts_contig$contig.csv";

my $dir =$spCodeUK."-".$spCodeRef."_Data/";
print "\nIn FileName: ".$dir.$missInFileName;
print "\nOut FileName: ".$dir.$countFileName;
#open MATCHFILE , "<".$dir.$matchInFileName or die "\nCan't open match file for readings: ".$dir.$matchInFileName;
open MISSFILE , "<".$dir.$missInFileName or die "\nCan't open miss file for redings: ".$dir.$missInFileName;
open COUNTFILE, ">".$dir.$countFileName or die"\n trouble opening ".$dir.$countFileName."for printing header";
print COUNTFILE "Position\tcount";
close(COUNTFILE);
open COUNTFILE, ">>".$dir.$countFileName or die "\ntrouble opening ".$dir.$countFileName." for append" ;

my ( $currentLine, $position, $readChar, $geneChar, $currentPos, $currentCount );
my ( $continueFlag, $nextInc, $dex, %misses, @lines);
$continueFlag = 1;
$currentCount = 0;
###################
#  Initialize variables with first elements
###################

while(<MISSFILE>)
{	$currentLine = $_;
	chomp($currentLine);
	#print "\n".$currentLine;
	@lines = split(/\t/);
	$position = $lines[3];
	if( exists ( $misses{ $position } ))
	{
		$misses{ $position } = $misses{ $position } + 1;	
	}else
	{	$misses{ $position } = 1;
	}
	
	#print "\nposition: ".$position."\t".$misses{ $position };
}
my @orderedSites = keys %misses;
for($dex = 0; $dex < @orderedSites; $dex++)
{	#print "\n".$orderedSites[$dex]."\t".$misses{$orderedSites[$dex]};
	print COUNTFILE "\n".$orderedSites[$dex]."\t".$misses{$orderedSites[$dex]};
}

close MISSFILE;
close COUNTFILE;
