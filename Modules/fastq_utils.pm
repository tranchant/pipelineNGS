package fastqUtils;

use strict;
use warnings;
use lib qw(.);
use localConfig;
use toolbox;
use Data::Translate;#To convert ASCII to decimal



#########################################
#Functions related to Fastqc file 
#########################################


sub fastqcToHash { #Parse fastqc file header and return a hash
	my $fastqcFile =shift;
	open FASTQC, $fastqcFile;
	my %headerFastqc;
	my @currentLine;

	while(<FASTQC>){
		if(/END_MODULE/){
			exit;
		}else{
			@currentLine = split($_, " ");
			$headerFastqc{$currentLine[0]} = $currentLine[1];
		}		
	}
	return %headerFastqc;
}


#########################################
#Functions related to Fastq file 
#########################################

#########################################
#Sequence count
#########################################

sub checkNumberByWC { #check the sequences number using the wc -l command from bash
    my ($fileName)=@_;
    my $nbLineCommand="wc -l ".$fileName; #Count the line number
    my $nbLine = `$nbLineCommand` or toolbox::exportLog("\nCannot check the sequence number ofr the file $fileName: $!\n",0); #Error check ok
    chomp $nbLine;
    
    #Add a split to only keep the number of line without the file name
    my @splitLine = split (" ", $nbLine);
    $nbLine = $splitLine[0];
    
    my $numberOfReads = $nbLine/4;#Each sequence if made of 4 lines in Fastq
    return $numberOfReads;
    }
#TODO verifier qu on a bien un fichier fastq => checkFormat
# checkFormat => checkEncoding
# checkNumber => numberOfReads

sub checkNumberByFASTQC{ #use the FASTQC reporting hash from the Fastqc module 
    my ($infos)=@_;
    my $fileName=$infos->{Filename};
    my $numberOfReads=$infos->{Total_Sequences};#Call to a key in a reference of an Hash
    return $numberOfReads;
    }


#########################################
# Encode check
#########################################

sub checkEncodeByASCIIcontrol { #Check if the FASTQ format of a given file is PHRED33. Here or in a specific FASTQ module ? 
    my ($fileName)=@_;
    my $translator = new Data::Translate;
    return 0 unless toolbox::readFile($fileName);#Check if file readable. Stop if not
    open(IN, "<", $fileName);
    <IN>;
    <IN>;
    <IN>;
    my $qualityASCII=<IN>; #picking up quality line
    chomp $qualityASCII;
    my @listASCII=split //,$qualityASCII;
    #print "@listASCII","\n";
    my $s; #Requested for Data::Translate to function, don't know why :s
    my $phred33Control = 1;
    while (@listASCII) {
        my (@ASCII) = shift @listASCII;
        my $Decimal;
        ($s,$Decimal)=$translator->a2d(@ASCII);#from ascii to decimal value
        $phred33Control = 0 if $Decimal > 73; #Phred33 maximal value is 33 + 40 = 73
        }
    return $phred33Control;#Return 1 if first line has no PHRED+64 values, 0 else
    }

sub checkEncodeByFASTQC {#Check if the FASTQ format is PHRED33 by parsing the FASTQC hash report.
    my ($infos)=@_;
    my $fileName=$infos->{Filename};
    my $PHREDformat=$infos->{Encoding};#Call to a key in a reference of an Hash
    my $logInfo="The PHRED format for the file ".$fileName." is of ".$PHREDformat."\n";
    toolbox::exportLog($logInfo,1);
    
    if ($PHREDformat =~ m/Sanger/) {#The format is Sanger, or Sanger/Illumina1.9, ie PHRED33
        return 1;
        }
    
    else {#The format is not PHRED33
        return 0;
        }
    
    }

#########################################
# Encode conversion
#########################################

#TODO: create a FASTQ line/sequence parser ?

sub changeEncode {#will change a FASTQ PHRED format in another
    my ($fileIn,$fileOut,$formatInit,$formatOut)=@_;#The format must be numerical (eg 33, 64...)
    
    #Opening files
    my $readRights = toolbox::readFile($fileIn);
    if ($readRights == 0) { #Cannot read file
        toolbox::exportLog("\nCannot read file $fileIn\n",0);
        return 0;
    }
    open (IN,"<",$fileIn); #Can read file
    open(OUT,">", $fileOut) or (toolbox::exportLog("\nCannot create file $fileOut: $!\n",0) and die); #Create the output and verify if any error
    
    while (my $line = <IN>) {#Pick up the Sequence Name Line from the infile
        $line .= <IN>; # Add the IUPAC line
        $line .= <IN>; # Add the '+' line
        my $qualityLine = <IN>;
        chomp $qualityLine;
        my $finalQuality;
        if ($formatInit == 64 and $formatOut == 33) {#From Illumina old PHRED 64 to Sanger PHRED 33
            $finalQuality=convertLinePHRED64ToPHRED33($qualityLine);
            }
        elsif ($formatInit == 33 and $formatOut == 64) {#From Sanger PHRED 33 to Illumina old PHRED 64 
            $finalQuality=convertLinePHRED33ToPHRED64($qualityLine);
            }  
        $line.=$finalQuality."\n";
        print OUT $line; #Outputting in the outfile
        }
    
    close IN;
    close OUT;
    
    #Export Log
    toolbox::exportLog("\nFile $fileIn has been converted from PHRED $formatInit to PHRED $formatOut, in $fileOut\n",1);
    
    return 1;
    }

sub convertLinePHRED64ToPHRED33 { #From a PHRED 64 quality line, will convert in Phred33
    my ($initialQuality)=@_;
    my @listOfQuality = split //, $initialQuality;
    foreach (@listOfQuality)
            {
            tr/\x40-\xff\x00-\x3f/\x21-\xe0\x21/; #convert the scale from ASCII64 to ASCII33
            }
    my $finalQuality = join("",@listOfQuality);
    return $finalQuality;
    }

sub convertLinePHRED33ToPHRED64 {#From a PHRED 33 quality line, will convert in Phred 64
	my ($initialQuality)=@_;
	my @listOfQuality = split //, $initialQuality;
	foreach (@listOfQuality)
		{
		$_  = chr (ord($_)+31); #convert the scale from ASCII33 to ASCII64
		}
	my $finalQuality = join("",@listOfQuality);
	return $finalQuality;
	}

1;