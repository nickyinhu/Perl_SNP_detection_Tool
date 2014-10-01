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
my $countFileName = "matchCounts_contig$contig.csv";

my $dir =$spCodeUK."-".$spCodeRef."_Data/";
print "\nFileName: ".$dir.$matchInFileName;
open MATCHFILE , "<".$dir.$matchInFileName or die "\nCan't open match file for readings: ".$dir.$matchInFileName;
#open MISSFILE , "<".$dir.$missInFileName or die "\nCan't open miss file for redings: ".$dir.$missInFileName;
open COUNTFILE, ">".$dir.$countFileName or die"\n trouble opening ".$dir.$countFileName."for printing header";
print COUNTFILE "Position\tcount";
close(COUNTFILE);
open COUNTFILE, ">>".$dir.$countFileName or die "\ntrouble opening ".$dir.$countFileName." for append" ;

my ( $currentLine, $position, $readChar, $geneChar, $currentPos, $currentCount );
my ( $continueFlag, $nextInc, $nextDec, @endPoss, @lines);
$continueFlag = 1;
$currentCount = 0;
###################
#  Initialize variables with first elements
###################
$currentLine = <MATCHFILE>; ##ignore header line in file
$currentLine = <MATCHFILE>;
if(!$currentLine)
{
	exit 0;
}
print "\nFirst  Line: $currentLine";
@lines = split(/\t/, $currentLine);
$currentPos = $lines[2];  ### set current position as first read start position
$currentCount++;
$nextDec = $currentPos + $readSize;

$currentLine = <MATCHFILE>;
#print "\nSecond  Line: $currentLine";
@lines = split(/\t/, $currentLine);

while($currentPos == $lines[2]) ### if initial matchs  have same start point, load counter and end poss count
{	$currentCount++;
	push(@endPoss,  $lines[2]+$readSize);
	$currentLine = <MATCHFILE>;
	chomp($currentLine);
	#print "\n/Next Initial  Line: $currentLine";
	@lines = split(/\t/, $currentLine);
}
push(@endPoss,  $lines[2]+$readSize);
$nextInc = $lines[2];

my $tempCurrentPos;
my $loopCount = 0;
####  Check that this position starts down the line and not the same point
while ($continueFlag)  # pass end position a param
{	#print "\ncurrentPos:$currentPos,  currentCount:$currentCount,   nextInc->$nextInc,   nextDec->$nextDec<<<  ";		
	if($currentPos == $nextInc   ) ### when several reads have same start point, load counter and end poss count
	{	$currentCount++;
		if(	eof(MATCHFILE) )
		{	$nextInc =-1;}
		else
		{	$currentLine =<MATCHFILE>;
			chomp($currentLine);
			@lines = split(/\t/, $currentLine);
			while($currentPos == $lines[2])
			{	$currentCount++;
				push(@endPoss, $lines[2]+$readSize);
				if(	eof(MATCHFILE) )
				{	$nextInc =-1;
					last;
				}
				else
				{	$currentLine =<MATCHFILE>;
					chomp($currentLine);
					@lines = split(/\t/, $currentLine);
				}
			}
			if($nextInc > -1)
			{	$nextInc = $lines[2];
			}
			push(@endPoss, $lines[2]+$readSize);
		}	
	}
	if($currentPos == $nextDec)
	{	#print "\nInside if cirrent = nextDec";
		$currentCount--;
		if(!@endPoss)
		{	$nextDec = -1;
		}	
		else{
			$nextDec = shift @endPoss;
		}
		while($currentPos == $nextDec )
		{	#print"\n while looping";
			if( @endPoss >0)
			{	$currentCount--;
				$nextDec = shift @endPoss;
				if(!$nextDec)
				{	$nextDec = -1
				}
			}else
			{	$nextDec = -1;
				last;
			}
		}
	}		
	print COUNTFILE "\n".$currentPos."\t".$currentCount;
	#print "<<<<<<<.......   After processing:: currentPos:$currentPos,  currentCount:$currentCount,   nextInc->$nextInc,   nextDec->$nextDec<<";	
	$currentPos++;
	$loopCount++;
	if(eof(MATCHFILE) && $nextInc==-1&& $nextDec == -1)
	{	$continueFlag = 0;
		last;
	}
}

close MATCHFILE;
close COUNTFILE;
