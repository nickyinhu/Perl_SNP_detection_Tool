#!/usr/bin/perl -w
# This script load data from file s_1_eland_extend.txt
#  Assumes sub directory structure  
#		Data file stored under  subdirectory Mut11-Ani_Data/Data/
#		Two resultant file also stroed here
# Command line argument list : ./loadAllRead fileName spCode refCode userName password
use Getopt::Std;	# Standard IO package 
use DBI;			# needed for interfacing with DataBaseInterface
#
# CREATE TABLE
##############
my $inputFileName = $ARGV[0];
my $spCodeUK = $ARGV[1];
my $spCodeRef = $ARGV[2];
my $user = $ARGV[3];
my $passwd = $ARGV[4];
my $filePrefix = $spCodeUK."-".$spCodeRef."_Data/Data/";
my $tableName = $spCodeUK."_".$spCodeRef."_AllReads";
my($query, $queryHandle,@descriptions, @seqs, $seq);
############################################################
# database connection information
my $db = "HarrisGenome";
my $connectionInfo = "dbi:mysql:$db;localhost";
# make connection to MySQL database
print STDERR "\nConnecting to MySQL database $db with the user ID: $user\n";
my $dbHandle = DBI->connect($connectionInfo, $user, $passwd, {RaiseError => 1});
if (!$dbHandle) 
{	print "Cannot connect to the database $db!";
	exit (0);
}
print STDERR "\n\t Connection to Database HarrisGenome is made";
#############################################################
$query = "Drop table if exists $tableName";
print "\n$query";
$queryHandle = $dbHandle->prepare($query);
$queryHandle->execute();
print "\n create table: $tableName";
$query = "Create table $tableName  (id INT NOT NULL AUTO_INCREMENT, primary key(id), spCode VARCHAR(5) NOT NULL, accNum VARCHAR(40) NOT NULL, readSeq VARCHAR(50) NOT NULL,  contig float not null, startPosition int not null, direction VARCHAR(2), descriptor VARCHAR(30) not null)";
print "\n$query";
$queryHandle = $dbHandle->prepare($query);#$queryHandle->execute();
$queryHandle->execute();

my $noMatchFileName = $spCodeRef."_".$spCodeUK."_ALL_NoMatch.csv";
my $multiHitsFileName = $spCodeRef."_".$spCodeUK."_ALL_MutliHits.csv";
my $qcCount = 0;
my $count = 0;
my $currentLine;
my @lines;
$query ="";
######  reading file and splitting up results
open INFILE, "< ".$filePrefix.$inputFileName or die "\n Trouble reading file $inputFileName";
open MULTIFILE, "> ".$filePrefix.$multiHitsFileName or die "\n Trouble reading file $multiHitsFileName";
open NOHITFILE, "> ".$filePrefix.$noMatchFileName or die "\n Trouble reading file $noMatchFileName";$count =0;
while ( <INFILE> )
{	$count++;
	print"\n$count reads processed, DON'T shut down this program please" if $count%10000 == 0;
	$currentLine = $_;
	@lines = split(/\t/, $currentLine);
	if($lines[2] eq "NM")
	{	print NOHITFILE $currentLine;
	}
	elsif($lines[2] eq "QC")
	{	$qcCount++;
	}
	elsif($lines[2] =~ /:/)
	{	#print "\nline 3>>>$lines[3]<<<";
		if( $lines[3] =~ /-/)
		{	print MULTIFILE $currentLine;
		#print "\nInside if -";
			next;
		}
		@hits = split(/,/,$lines[3]);
		if(@hits > 1)
		{	#print"\n Inside multi hit if";
			print MULTIFILE $currentLine;
			next;
		}
		chomp($lines[3]);
		#@slines = split(/:/, $lines[3]);
		my ($accNum, $contig, $descriptor, $readSeq);
		$accNum = $lines[0];
		$readSeq = $lines[1];
		@details = split(/:/,$lines[3]);
		$details[0]=~/1./;
		$contigFull =$';
		$contigFull=~/1./;
		$contig = $';
		$descriptor = $details[1];
		$descriptor =~/[RF]/;
		$startPos = $`;
		$dir = $&;
		$query = "Insert into ".$spCodeUK."_".$spCodeRef."_AllReads (spCode, accNum, readSeq, contig, startPosition, direction, descriptor) values ('$spCodeRef','$accNum', '$readSeq', $contig, $startPos, '$dir',   '$descriptor')" ;
		$queryHandle = $dbHandle->prepare($query);
		$queryHandle->execute();		
	}	
}
close INFILE;
close MULTIFILE;
close NOHITFILE;