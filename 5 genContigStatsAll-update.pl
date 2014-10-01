#!/usr/bin/perl -w
# This script runs ./genContigStats for each contig

use Getopt::Std;	# Standard IO package 
use strict;
use warnings;

my $readSize = 35;

my $contigNum = $ARGV[0];
my $spCodeUK = $ARGV[1];
my $spCodeRef = $ARGV[2];
my $user = $ARGV[3];
my $password = $ARGV[4];
my $dir =$spCodeUK."-".$spCodeRef."_Data/";
my $inGeneFileName = "polysInGene.csv";
my $outGeneFileName = "polysInterGene.csv";
my $contigStatsFileName="contigStats.csv";

open INGENEFILE, ">".$dir.$inGeneFileName or die "\ntrouble opening $dir $inGeneFileName for writing header";
open OUTGENEFILE, ">".$dir.$outGeneFileName or die "\ntrouble opening $dir $outGeneFileName for writing header";
open CONFILE, ">".$dir.$contigStatsFileName or die "\ntrouble opening $dir $contigStatsFileName for writing header";
print INGENEFILE "\nContig#\tGene ID\tGene start\tGene end\tPolymorphism Position \tMatch count\tMiss count"; 
print OUTGENEFILE "\nContig#\tPolymorphism Position \tMatch count\tMiss count"; 
print CONFILE "\ncontig#\tTotal Match Counts\tLen Coveraged\tAverage Cover\tTotal Sites With Error\tRatio Sites With Errors\tAverage Error At Error Sites";

close INGENEFILE;
close OUTGENEFILE;
for (my $dex = 1; $dex < ($contigNum+1); $dex++)
{
	my $com = "genContigStats-update.pl $dex $spCodeUK $spCodeRef $user $password";
	print"\n$com";
	system($com);
}


