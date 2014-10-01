#!/usr/bin/perl -w
# This script counts the coverage at each position along it's length starting with the first actual match position.

use Getopt::Std;	# Standard IO package 
use strict;
use warnings;

my $readSize = 35;

my $contigNum = $ARGV[0];
my $spCodeUK = $ARGV[1];
my $spCodeRef = $ARGV[2];
my $com;
#my $dex = 2;
for (my $dex = 1; $dex < $contigNum+1; $dex++)
{
#	$com  = "./missMatchCount $dex $spCodeUK $spCodeRef";
	$com  = "missMatchCount.pl $dex $spCodeUK $spCodeRef";
	print "\nCom:: ".$com;
	system($com);
#	$com  = "./countMissPerContig $dex $spCodeUK $spCodeRef";
	$com  = "countMissPerContig.pl $dex $spCodeUK $spCodeRef";
	print "\nCom:: ".$com;
	system($com);	
}