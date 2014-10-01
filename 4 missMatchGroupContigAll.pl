#!/usr/bin/perl -w
# This script run ./missMatchGroupContig for each contig

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

#############################################################
# Erasing existing file
##########
my $averageCoveragePerGeneFileName = "averageCoveragePerGene.csv";
open TOTFILE, "> ". $dir.$averageCoveragePerGeneFileName or die "\n trouble opening average coverage record file for overwrite:  $dir$averageCoveragePerGeneFileName";
close (TOTFILE);

for (my $dex = 1; $dex < ($contigNum+1); $dex++)
{
	my $com = "misMatchGroupContig-update.pl $dex $spCodeUK $spCodeRef $user $password";
	print"\n$com";
	system($com);
}


