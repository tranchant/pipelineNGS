package pairing;

use strict;
use warnings;
use lib qw(.);
use localConfig;
use toolbox;

#This module will ensure the repairing of Fastq files and the recognition of the pairs

#Pair recognition: from a large set of files in a folder, will recognize forward, reverse and associate them.
#A single file will be alone in its subhash, but can be named forward or reverse (generally forward)
sub pairRecognition {
    my ($folder)=@_;
    my %pairs;
    use Data::Dumper;
    
    #Reading the files in the folder
    my $listFiles_ref=toolbox::readDir($folder);
    my @listFiles=@{$listFiles_ref};
    
    foreach my $currentFile (@listFiles)
	{
	    
	#check fastq format of the file
	my $checkFastq=toolbox::checkFormatFastq($currentFile);
	if ($checkFastq == 0)
	    {
	    #The file is not a Fastq File, we cannot consider it
	    next; # go to the next sequence
	    }
	
	
	#Fetching the first line to obtain the ID sequence
	my $firstLineComplete=`head -n 1 $currentFile`;
	chomp $firstLineComplete;

	#Infos for the type of modification
	my $namingConvention;
	
	#Removing the end of line
	my $sequenceName=$firstLineComplete;
	$sequenceName =~ s/\/.$// and $namingConvention = 1; # ancienne convention /1 /2
	$sequenceName =~ s/\s\d:\w:\d:\w{1,10}$// and $namingConvention = 2; # convention actuelle 1:N:A-Z]& to 10

	#Keeping the end of line
	my $typeOfStrand=$firstLineComplete;
	$typeOfStrand =~ s/.+\/(.)$/$1/ if $namingConvention == 1;
	$typeOfStrand =~ s/.+\s(\d:\w:\d:\w{1,10})$/$1/ if $namingConvention == 2;
		
	#Converting the end of Line in forward and reverse
	my $nameOfStrand = "unknown";
	$nameOfStrand = "forward" if $typeOfStrand =~ m/^1/;
	$nameOfStrand = "reverse" if $typeOfStrand =~ m/^2/;

	#Completing the hash
	$pairs{$sequenceName}{$nameOfStrand}=$currentFile;
	
	#Adding the ReadGroup in the hash for latter use
	my $readGroupName=$pairs{$sequenceName}{"forward"} if (exists $pairs{$sequenceName}{"forward"})  ; #Picking up the forward name to generate the RG tag
	$readGroupName=$pairs{$sequenceName}{"reverse"} unless $readGroupName;#If only reverse seq
	$readGroupName=$pairs{$sequenceName}{"unknown"} unless $readGroupName;#if only unknown strand
	$readGroupName = extractName($readGroupName);#Remove the .fastq from the name
	$pairs{$sequenceName}{"ReadGroup"}=$readGroupName; #Adding the readGroup to the name
	
	}
    #Exporting log
    my $dumpCoupleList = Dumper(\%pairs);
    toolbox::exportLog($dumpCoupleList,1);
    #returning infos
    return (\%pairs);
    
}

#From a hash (reference to) of paired sequences, will constrct and organize couples in separated folders, named with their RG.
sub createDirPerCouple {
    my ($hashOfPairs,$targetDirectory)=@_;
    my @listOfSequences = keys %{$hashOfPairs}; #Pick up the names of first sequences (key values of the reference)
    foreach my $couple (@listOfSequences)
    {
	if ($couple=~ /^@/) {
	print Dumper($hashOfPairs->{$couple});
	#Extract infos
	my $forwardFile=$hashOfPairs->{$couple}{"forward"};
	$forwardFile=$hashOfPairs->{$couple}{"unknown"} unless $forwardFile; #Forward name may not exists
	
	my $reverseFile;
	$reverseFile=$hashOfPairs->{$couple}{"reverse"} if exists $hashOfPairs->{$couple}{"reverse"}; #Reverse may not exists
	
	my $ReadGroup=$hashOfPairs->{$couple}{"ReadGroup"};
	$ReadGroup=$targetDirectory."/".$ReadGroup;
	#
	#   
	#    #Creating subfolder based on ReadGroup name
	    my $makeDirCheck=toolbox::makeDir($ReadGroup,0); #Will not erase if created
	    if ($makeDirCheck != 1)
		{
		#An error occured, we do not have a 1 return value
		toolbox::exportLog("Cannot create the folder for RG $ReadGroup and the couple $couple",0);
		return 0;
		}
	    #Everything is Ok, we copy and deduplicate the files after copy. No mv use, mv saylemal
	    my $forwardCopyCommand="cp $forwardFile ".$ReadGroup."/. && rm -Rf $forwardFile";
	    toolbox::run($forwardCopyCommand);
	    my $reverseCopyCommand="cp $reverseFile ".$ReadGroup."/. && rm -Rf $reverseFile" if $reverseFile;#reverse file may be absent
	    toolbox::run($reverseCopyCommand) if $reverseFile;
	}
    }
    return 1;
}

#From two de-paired files, forward + reverse, will create three files, forward, reverse and single
sub repairing {#The repairer itself
    my($forward,$reverse)=@_;
    
    #TODO : verifier checkFormatFastq
    #Extraction of the name and creation of output names
    my $forwardOut = extractName($forward);
    
    my $singleOut=$forwardOut."_single.fastq";
    $forwardOut .= "_forwardRepaired.fastq";
    
    my $reverseOut = extractName($reverse);
    $reverseOut .= "_reverseRepaired.fastq";
    
    #Opening infiles
    open(FOR, "<", $forward) or errorAndDie($!);
    open(REV, "<", $reverse) or errorAndDie($!);
    
    #Opening outfiles
    open(MATEF, ">",$forwardOut) or errorAndDie($!);
    open(MATER, ">",$reverseOut) or errorAndDie($!);
    open(SINGLE,">",$singleOut) or errorAndDie ($!);
    
    #Creating counters
    my $pairedSequences=0;
    my $singleSequences=0;
    
    #Variables
    my %forwardSequences;
    
    #Reading forward input file
    while (<FOR>)
	{
	my $line = $_;
	chomp $line;
        next if ($line =~ m/^$/);
        my $next = $line."\n";
	$line =~ s/\/\d$//;
        $line =~ s/\s\d:\w:\d:\w{1,10}$//;
	$next .= <FOR>;
	$next .= <FOR>;
	$next .= <FOR>;
	$forwardSequences{$line}=$next;
	}

    #Comparing with the reverse seq ID
    while (<REV>)
            {
            my $line = $_;
            chomp $line;
            next if ($line =~ m/^$/);
            my $next = $line."\n";
            $line =~ s/\/\d$//;
            $line =~ s/\s\d:\w:\d:\w{1,10}$//;
            $next .= <REV>;
            $next .= <REV>;
            $next .= <REV>; 
            #printing outputs for paired files
            if (exists $forwardSequences{$line})
                    {
                    my $out = $forwardSequences{$line};
                    print MATEF $out;
                    my $out2 = $next;
                    print MATER $out2;
                    delete $forwardSequences{$line}; # To save memory and to conserve only the singles
                    $pairedSequences++; #Increment the number of pairs
                    }
            #printing output for singles from reverse file
            else
                    {
                    my $out2 = $next;
                    print SINGLE $out2;
                    $singleSequences++;#Increment the number of single sequences
                    }
            }
    
    #printing output for singles from forward file
    foreach my $remainingNames (keys %forwardSequences)
            {
            my $out = $forwardSequences{$remainingNames};
            print SINGLE $out;
            $singleSequences++;#Increment the number of single sequences
            }

    #Closing files
    close MATEF;
    close MATER;
    close SINGLE;
    close FOR;
    close REV;
    
    #Export Log
    exportLogLocal($pairedSequences,$singleSequences,1);
    return 1;
    
    }

sub extractName{#remove fastq from the name, and clean the name
    my ($name)=@_;
    chomp $name;
    $name =~ s/\.\./\+\+/;#to workaround the next command if the way is in relatvie (eg ../DATA/file)
    my @listName=split /\./, $name;
    pop @listName;#removing last value, ie the format
    my $shortName=join ("_",@listName);#allows removing of format (fastq) and of all "." remaining in the name.
    #cleaning name
    $shortName=~ s/ /_/g;#removing spaces
    $shortName=~ s/[é|è|ê]/e/g;#removing non utf8 accents from e
    $shortName=~ s/à/a/g;#removing non utf8 accents from a
    $shortName=~s/\+\+/\.\./;#readding the .. instead of ++, in ref to the fisrt modification.
    return $shortName;
    }

sub exportLogLocal{#To export logs...
    my ($pairedSequences,$singleSequences,$controlValue)=@_;
    if ($controlValue == 1) {#Everything is ok
        #Creation of the output
        my $outlog=$pairedSequences." pairs were recovered (".($pairedSequences*2)." sequences), and ".$singleSequences." were extracted.\n";
        #Exporting the output
        toolbox::exportLog($outlog,1);
        }
    else {#Problem with something
        #Creating the output
        my $outlog = "Error during repairing!! The following error was encountered:\n".$controlValue."\n";
        #Exporting the output
        toolbox::exportLog($outlog,0);
        }
    
    }

sub errorAndDie {#Error managing, to improve !!TODO
    my ($error)=@_;
    exportLogLocal(0,0,$error);
}

1;