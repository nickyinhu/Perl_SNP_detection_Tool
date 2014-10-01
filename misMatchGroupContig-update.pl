#!/usr/bin/perl -w
# This script extracts all gene location information by gene ID and contig# indicated in parameters 
#	write to file
# Command line argument list : misMatchGroupContig  2 Har Ani passwd
use Getopt::Std;	# Standard IO package 
use DBI;			# needed for interfacing with DataBaseInterface
#############################################################
# run data
##########
my $contigNum = $ARGV[0];
my $spCodeUK =  $ARGV[1];
my $spCodeRef = $ARGV[2];
my $dir = $spCodeUK."-".$spCodeRef."_Data/";
my $tableName = "GeneCoordinates";
my($query, $queryHandle,@descriptions, @seqs, $seq);
$query = "Select geneID, start, stop, geneLayout, ChromNum from  $tableName where contig = $contigNum  order by start";
########################################################
# database connection information
my $db = "newFungi";
my $connectionInfo = "dbi:mysql:$db;localhost";
my $user = $ARGV[3];
my $passwd = $ARGV[4];
# my $passwd="schumzie-01";
# make connection to MySQL database
print STDERR "\nConnecting to MySQL database $db with the user ID: $user\n";
my $dbHandle = DBI->connect($connectionInfo, $user, $passwd, {RaiseError => 1});
if (!$dbHandle) 
{	print "Cannot connect to the database $db!";
	exit (0);
}
print STDERR "\n\t Connection to Database HarrisGenome made\n\n";

#############################################################
print "\n$query";
$queryHandle = $dbHandle->prepare($query);
$queryHandle->execute();
my $count = 0;
while(@results = $queryHandle->fetchrow_array() )
{	$ID = $results[0];
	#$ID = substr($ID, 1, length($ID)-1);
#	my $com ="./missMatchGroup $contigNum $ID $results[1] $results[2] $spCodeUK $spCodeRef";
	my $com ="missMatchGroup.pl $contigNum $ID $results[1] $results[2] $spCodeUK $spCodeRef"
	#print "\n\tCOM::: $com";
	system($com);
#	my $com2 ="./missOnlyGroup $contigNum $ID $results[1] $results[2] $spCodeUK $spCodeRef";
	my $com2 ="missOnlyGroup.pl $contigNum $ID $results[1] $results[2] $spCodeUK $spCodeRef";
	#	print "\n\tCOM2::: $com2";
	system($com2);
#	my $com3 ="./MapExons $spCodeRef $contigNum $ID $results[3] $spCodeUK";
	my $com3 ="MapExons.pl $spCodeRef $contigNum $ID $results[3] $spCodeUK";

	#	print "\n\tCOM3::: $com3\n\n";
	system($com3);
	$count++;
	print"\n $count Genes processed" if $count%50 == 0;
}
$queryHandle->finish;
$dbHandle->disconnect;