#!/usr/bin/perl -w
# This script load data from file to  table GeneCoordinates
# Command line argument list : loadExport2Table aspergillus_nidulans_fgsc_a4_1_transcripts.gtf Ani 
use Getopt::Std;	# Standard IO package 
use DBI;			# needed for interfacing with DataBaseInterface# database connection

system ("DeleteDBgeneCoordina.pl");
system ("CreateDBgeneCoordina.pl");
my $db = "newFungi";
my $connectionInfo = "dbi:mysql:$db;localhost";
my $user = ARGV[2];
my $passwd=ARGV[3];
# make connection to MySQL database
print STDERR "\nConnecting to MySQL database $db with the user ID: $user\n";
my $dbHandle = DBI->connect($connectionInfo, $user, $passwd, {RaiseError => 1});
if (!$dbHandle) 
{	print "Cannot connect to the database $db!";
	exit (0);
}
print STDERR "\n\t Connection to Database HarrisGenome made";
my $inputFileName = $ARGV[0];
my $spCode = $ARGV[1];
######  query with no return
my($query, $queryHandle,@descriptions, @seqs, $seq);
open INFILE, "< ".$inputFileName or die "\n Trouble reading file $inputFileName";
my( $geneID, $transID, $contig, $currentID, $startPosition,  $stopPosition,  $direction, $frame, $segmentNum, $exonSignature, $geneCount, $curGene);
$seq ="";
$query="";
$segmentNum = 0;
$firstFlag =1;
$exonSignature = "";
$direction = "";
$geneCount = 0;
$started = 0;  # used tot rack split start codons
my $splitcount = 0;
while ( <INFILE>)
{	$currentLine = $_;
	@lines = split( /\t/, $currentLine);
	@ids = split(/"/, $lines[8]);
	#	$ids[0] =~ /"\""/;  This statement added only to get the color of editor back. 
	if($currentLine =~ /start_codon/)
	{	if( $started == 0 )  # line ignore if this is the second start codon seen per ID
		{
			if($firstFlag == 0)
			{	my $exonSignature3 = substr $exonSignature, 1;
				$query = "insert into GeneCoordinates (spCode,  geneID, transID,contig, start, stop, segNum, geneLayout) values ('$spCode', '$geneID', '$transID', $contig, $startPosition, $stopPosition , $segmentNum, '$exonSignature3' )";		
				$geneCount++;
				if( $geneCount% 1000 == 0) {print "\n genes loaded: $geneCount" ;}
				$queryHandle = $dbHandle->prepare($query);
				$queryHandle->execute();
			}
			@tags = split(/%/, $lines[0]);
			$tagSize = @tags;
			my $temp = $tags[($tagSize-1)];
			$temp =~/\./;
			$contig = $';
			$geneID = $ids[1];
			$curGene = $geneID;
			$transID = $ids[3];
			$direction = $lines[6];
			if($direction eq'+')
			{	$startPosition = $lines[3];
			}
			else
			{	$startPosition = $lines[4];
			}
			$currentID = $geneID;
			$segmentNum=0;
			$firstFlag = 0;
			$exonSignature = "";
			$started = 1;
		}
		else
		{	$splitcount++;
			print "\n$splitcount  skipped split start codon  gene ID $geneID";
			
		}
	}
	elsif($currentLine =~ /stop_codon/)
	{	$geneID = $ids[1];
		$transID = $ids[3];
		if($direction eq '+')
		{	$stopPosition = $lines[4];
		}
		else
		{	$stopPosition = $lines[3];
		}		
	}elsif($currentLine =~ /exon/)
	{	$started =0;  # used to track split start codons
		if ($curGene eq $ids[1])  # screens segments from predicted genes without 'start or stop' codon from being added to this gene;
		{	$geneID = $ids[1];
			$transID = $ids[3];
			# need to add a line to 
			if($direction eq '+')
			{	$currentStop = $lines[4];
				$currentStart =$lines[3];
				$exonSignature = $exonSignature.",".$currentStart."..".$currentStop;
				#print "\n Inside Signature plus loop: start->".$currentStart."<-  Stop->".$currentStop."<-";
			}
			else
			{	$currentStop = $lines[3];
				$currentStart =$lines[4];
				$exonSignature = $exonSignature.",".$currentStart."..".$currentStop;
			}	
		}	
	}	elsif($currentLine =~ /CDS/)	
	{ $segmentNum++;
	}
}
my $exonSignature2 = substr $exonSignature, 1;
$query = "insert into GeneCoordinates (spCode,  geneID, transID,contig, start, stop, segNum, geneLayout) values ('$spCode', '$geneID', '$transID', $contig, $startPosition, $stopPosition , $segmentNum, '$exonSignature2' )";		
print "\n Query: ".$query;
$queryHandle = $dbHandle->prepare($query);
$queryHandle->execute();
$genecount++;
print "\n total genes loaded: $geneCount" ;
$dbHandle->disconnect();
print "\ndisconnected  database\n";	




