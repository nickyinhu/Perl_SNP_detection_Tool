#!/usr/bin/perl -w
# This script extract read info from AllReads table in database and sends them to MissMatch2File script
#	which sorts them to file
# Command line argument list : ./misMatchSortRunAll.pl contig# spCode refCode
# Example : ./misMatchSortRunAll 250 New2 Ani
use Getopt::Std;	# Standard IO package 
use DBI;			# needed for interfacing with DataBaseInterface

# run data
##############
my $totalContigs = $ARGV[0];
my $spCodeUK = $ARGV[1];
my $spCodeRef = $ARGV[2];
my $user = $ARGV[3];
my $passwd = $ARGV[4];
my $dir = $spCodeUK."-".$spCodeRef."_Data/";
#############################################################
# database connection information#
my $db = "HarrisGenome";
my $connectionInfo = "dbi:mysql:$db;localhost";
# make connection to MySQL database
print STDERR "\nConnecting to MySQL database $db with the user ID: $user\n";
my $dbHandle = DBI->connect($connectionInfo, $user, $passwd, {RaiseError => 1});
if (!$dbHandle) 
{	print "Cannot connect to the database $db!";
	exit (0);
}
print STDERR "\n\t Connection to Database HarrisGenome made";
#############################################################
for(my $contig = 1; $contig < $totalContigs; $contig++)
{# # Beginning outer loop	
	my $matchOutFileName = "matchCoverage_contig$contig.csv";
	my $missOutFileName = "missCoverage_contig$contig.csv";
	open MATCHFILE , ">".$dir.$matchOutFileName;
	print MATCHFILE "Contig#\tid\tcontigPosition\tdirection"; 
	open MISSFILE , ">".$dir.$missOutFileName;
	print MISSFILE "Contig#\tid\tstartPosition\tcontigPosition\treadChar\tGeneChar\tdirection"; 
	my $tableName = $spCodeUK."_".$spCodeRef."_AllReads";
	my($query, $queryHandle,@descriptions, @seqs, $seq);
	$query = "Select * from  $tableName where contig = $contig  order by startPosition";
	print "\n$query";
	$queryHandle = $dbHandle->prepare($query);
	$queryHandle->execute();
	my $count = 0;
	while(@results = $queryHandle->fetchrow_array() )
	{	
#		print $queryHandle->execute(),"\n";
		$ID = $results[2];
		$ID = substr($ID, 1, length($ID)-1);
		$count++;
		my $com ="missMatch2File.pl $results[7] $contig $results[3] $ID $spCodeUK $spCodeRef";
		print "\n$contig:  $count reads processed, PLEASE DON'T SHUT DOWN THIS PROGRAM" if $count%1000==0;
		system($com);
	}
	print "\nThere are $count records in file";
#	$queryHandle->finish;
	close (MATCHFILE);
	close (MISSFILE); 
} # End outer For loop

$dbHandle->disconnect;