###################################################################################################################################
#
# Licencied under CeCill-C (http://www.cecill.info/licences/Licence_CeCILL-C_V1-en.html) and GPLv3
#
# Intellectual property belongs to IRD, CIRAD and SouthGreen developpement plateform 
# Written by Cécile Monat, Ayité Kougbeadjo, Mawusse Agbessi, Christine Tranchant, Marilyne Summo, Cédric Farcy, François Sabot
#
###################################################################################################################################


package toolbox;

use strict;
use warnings;
use lib qw(.);
use localConfig;
use Exporter;
use Data::Dumper;


#Global infos
our @ISA=qw(Exporter);
our @EXPORT=qw($configInfos);
our $configInfos; #Config informations, ref of an hash

#########################################
#Global functions
#########################################
sub exportLog		#For log printing
{
    
    my ($logLines,$controlValue)=@_;
    
    open (my $STDOUT_, '>&', STDOUT);
    open (my $STDERR_, '>&', STDERR);
    open (STDOUT, '>>', 'log.txt');
    open (STDERR, '>>', 'log.txt');
    
    
    ##TO DO:: Peut-on ameliorer exportLog??????
    
    
    open(FILE, ">>log.txt") or die("cannot open log.txt : $!\b");
	
	if ($controlValue eq "1")		#Everything is Ok
	{
	    print FILE $logLines;
	}
	elsif ($controlValue eq "0")		#Something wrong
	{
	    print FILE "\n\n<---->An Error Occured!!<---->\n\n\t";
	    print FILE $logLines;
	    print FILE "\nBye...\n";
	    #die("\nBye...\n");        
	}
	close(FILE);
	
    open (STDOUT, '>&', $STDOUT_);
    open (STDERR, '>&', $STDERR_);
}

#########################################
#Functions related to file, generic
#########################################

###
### CM: la fonction checkFile en regroupe plusieurs, est-elle vraiment nécessaire ???? ###
###
sub checkFile		#Check if a file exists, is readable/writable, and has something in
{
    my ($file)=@_;
    
    #Check existence
    my $existence = existsFile($file);
    if ($existence == 0)		#File does not exist
    {
        return 0;
    }
    
    #Check size
    my $size = sizeFile($file);
    if ($size == 0)		#Empty file
    {
        my $infoSize ="$file is empty!\n";
        return $infoSize;
    }
    
    #Check read and write right   
    my $readingRights = readFile($file);
    my $writingRights = writeFile($file);
    
    my $logOut;
    
    if ($readingRights == 1 and $writingRights == 1)
    {
        $logOut= "The file $file is readable and writable\n";
    }
    elsif($readingRights == 1 and $writingRights == 0)
    {
        $logOut="The file $file is readable but not writable\n";
    }
    elsif($readingRights == 0 and $writingRights ==1)
    {
        $logOut="Strangely, you cannot read $file but you can edit it ??\n";
        exportLog($logOut,0);
        return 1;
    }
    else
    {
        $logOut="You cannot read nor edit the file $file!\n";
        exportLog($logOut,0);
        return 1;
    }
    
    exportLog($logOut,1);   
    return 1;
}

sub readFile		#Check if a file is readable
{
    my ($file)=@_;
    existsFile($file); #Check if exists
    #File exists
    if (-r $file){return 1;}
    else {return 0;}
}

sub writeFile		#check if a file is writable
{
    my ($file)=@_;
    existsFile($file); #Check if exists
    if (! -w $file){return 1;}
    else {return 0};
}

sub sizeFile		#check if a file is not empty
{
    my ($file) = @_;
    existsFile($file); #Check if exists
    if (-s $file) {return 1;}#File exists and is more than 0 bytes
    else {return 0;}    #file does not exists or has a size of 0
}


##################################################################################
# toolbox::existFile : Check if the file exists
#	in: fileToCheckIfExist
#	out: log, boolean
##################################################################################
# CHANGE 11-04-2014 / CD : Remove argument $typeCheck 
# CD : ajout du test -T
sub existsFile		#Check if the file exists
{
    
    my ($file)=@_;
    if ((-e $file and -T $file) or (-e $file and -B $file))
    {return 1;} #file exists
    else
    {
        #file does not exists
        my $logOut =" $file does not exists or it's not a file! \n";
        exportLog($logOut,0); #report an error to exportLog
        return 0;
    }
}

##### CD
# check if a directory exists
sub existsDir 
{
    my ($dir)=@_;
  
    if (-e $dir and -d $dir) { return 1; }
    else
    {
        my $logOut = "Directory $dir does not exist : $! \n";
        toolbox::exportLog($logOut,0); #report an error to exportLog
        #return 0;
    }
}

sub makeDir
{
    die "WARNING! toolbox::makeDir should get one argument at least!\n" if (@_ < 1 );
    
    my ($dir, $erase)=@_;
    
    $erase = 0 if (not defined $erase);
    
    system("rm -rf $dir") == 0 or die "Can't remove $dir"  if ($erase and existsDir($dir));

    unless (mkdir $dir)  
    {
	my $logOut = "Unable to create directory $dir $! \n";
        toolbox::exportLog($logOut,0); #report an error to exportLog
        #return 0;
    }
    return 1;

}


sub readDir
{
    die "WARNING! toolbox::readDir should get at one argument at least!\n" if (@_ < 1 );
    
    my ($dir)= shift @_;
    
    my $path = defined ($_[0]) ? $dir.'/*'.$_[0] : $dir."/*";
    my $file=`ls $path` or die "Can't open the directory $path $!";
    chomp $file;
    my @fileList = split /\n/, $file; #print Dumper(\@fileList);
    return(\@fileList);

}

###
### CM :
## TODO Fonction pour enlever // path
### ok non ?
###

sub extractPath {
  
  my ($path) = shift @_;
  
  my @pathTab = split /\//, $path;
  my $file = $pathTab[$#pathTab];
  
  $path =~ s/$file//;
  
  return ($file,$path);
}

## TODO Fonction affiche liste tableau hash? ex: Option ex: Liste fichier traité

#########################################
#Function related to a conf file
#########################################
sub readFileConf		#Read the FileConf and export the value in a hash of hashes
{
    my($fileConf) = @_;
    
    readFile($fileConf) or (exportLog("\nCannot read the config file $fileConf : $!\nAborting...\n",0));
    my @lines;
    open (FILE,"<",$fileConf);
    @lines = <FILE>;
    close FILE;
    
    #Generating the hash with all infos
    
    my $currentProgram;#Need to be declared outside the loop
    
    while (@lines)		#Reading all lines
    {
        my $currentLine=shift @lines;
        chomp $currentLine;
        
        #Avoided lines
        next if $currentLine =~ m/^$/;#Empty line
        next if $currentLine =~ m/^#/;#Commented line
           
        if ($currentLine =~ m/^\$/)		#New program to be configured
	{
            $currentProgram=$currentLine;
            $currentProgram =~ s/\$//;#remove the "$" in front of the name
        }
        else		#Config lines
	{
            my($optionName,$optionValue)=split /=/,$currentLine, 2;
            $optionValue = "NA" unless $optionValue; # For option without value, eg -v for verbose
            #Populating the hash
            $configInfos->{$currentProgram}{$optionName}=$optionValue;
        }
    }
  
    return $configInfos;

}


#########################################
#Function for exatring options (parameters that'll be given to the tools command)
#########################################
sub extractOptions
{
    my($optionsHashees,$separateur)=@_; ##Getting the two parameters, the options hash and the option separators
    if ($optionsHashees)		# if the option are not empty I mean if the hash is set you can extract the options 
    {
	my %options=%{$optionsHashees};
	my $option=" ";
	$separateur=" " unless $separateur; ## if any separtor is given set it as one space
	try
	{                               
	    foreach my $cle (keys %options)
	    {
		if ($options{$cle} eq 'NA')
		{
		    $option=$option.$cle.$separateur." ";
		}
		else
		{
		    $option=$option.$cle.$separateur.$options{$cle}." ";
		}
	    }
	    return $option;
	}
	catch
	{
	    exportLog("caught error: $_",0);
	}
    }
    else
    {
	return "";
    }
}
#########################################
#Function for exatring Name (remove the extentio and return the name)
#########################################
sub extractName
{
    my $bruteName=shift @_;
    $bruteName=~ s/^.+\/(.+)\..+/$1/;
    print Dumper($bruteName);
    return $bruteName;
}
#########################################
#run function: This function execute the command you guve him and export the log via toolbox::exportLog() function
#########################################
sub run
{
    # copy STDOUT and STDERR to another filehandle
    open (my $STDOUT_, '>&', STDOUT);
    open (my $STDERR_, '>&', STDERR);

    # redirect STDOUT and STDERR to log.txt
    open (STDOUT, '>>', 'log.txt');
    open (STDERR, '>>', 'log.txt');


    my($command)=@_;
    exportLog("\n The command you gave me is: $command \n \n",1);
    
    ##Execute the command
    my $result=` $command `;
    
    ##Log export according to the error
    if ($?==0)
    {
	exportLog($result,1);
	return 1;
    }
    else
    {
	exportLog($result,0);
	return 0;
    }   

    # restore STDOUT and STDERR
    open (STDOUT, '>&', $STDOUT_);
    open (STDERR, '>&', $STDERR_);
    
}

#########################################
# Check Format: check if file is really a FASTQ file
#########################################
sub checkFormatFastq
{
    my $notOk = 0;                      # counter of error(s)
    my ($fileToTest) = @_;              # recovery of file to test
    my $readOk = readFile($fileToTest); # check if the file to test is readable
    open (F1, $fileToTest);             # open the file to test
    while (<F1>)                 	# for the first line of the sequence with normally, ID info
    {
        if ($_=~m/^$/)                  # if ID info's are not present ...
        {
            toolbox::exportLog("The ID infos line is not present, your file -> $fileToTest <- is not a FASTQ file, please check your file \n", 0);
            $notOk++;                   # one error occured, so count it
        }
        my $line2=<F1>;                 # for second line of the sequence with the sequence
        my $line3=<F1>;                 # for the third line of the sequence with normally, "+" for quality infos
        if ($_=~m/^$/)                  # if "+" not present...
        {
            toolbox::exportLog("The \"+\" line, header of quality line is not present, your file -> $fileToTest <- is not a FASTQ file, please check your file \n",0);
            $notOk++;                   # one error occured, so count it
        }
        my $line4=<F1>;                 # for the fourth line of the sequence with quality score
    }
    if ($notOk == 0)                    # if no error occured in the whole file, ok
    {
        toolbox::exportLog("checkFormatFastq ok, your file -> $fileToTest <- is a FASTQ file, go on \n",1);
	return 1;
    }
    else                                # if one or some error(s) occured on the whole file, not ok
    {
        toolbox::exportLog("checkFormatFastq not ok, your file -> $fileToTest <- is not a FASTQ file, please check your file \n",0);
	return 0;
    }
    close F1;
}
#########################################
# Experimental feature: adding tag infos in a SAM/BAM file
#########################################
#Will add infos in the '@CO' field in a SAM or a BAM file
#Highly experimental for now!!
sub addInfoHeader
{
    my ($samFile,$textToAdd)=@_;
    
    #Is the file sam of bam ?
    my $formatCheck=checkSamOrBamFormat($samFile);
    if ($formatCheck == 0)	#The file is not a BAM nor a SAM and cannot be treated here
    {
	toolbox::exportLog("$samFile is not a SAM/BAM file for adding info in the header.\nPlease check your file\n",0);
	return 0;
    }
    
    #Requested for the -S option in samtools view
    my $inputOption;
    if ($samFile =~ m/\.bam$/) #The file is a BAM file
    {
	$inputOption = ""; #no specific option in samtools view requested
    }
    elsif ($samFile =~ m/\.sam$/) #the file is a SAM file
    {
	$inputOption = " -S ";#-S mean input is SAM
    }
    #Picking up current header
    my $headerCommand="$samtools view $inputOption -H $samFile > headerFile.txt"; #extract the header and put it in the headerFile.txt
    run($headerCommand);
    
    #Adding the @CO field to the header
    my $addingCoLineCommand = "echo \"\@CO $textToAdd\" | cat - >> headerFile.txt";#Adding the text at the end of the file.
    run($addingCoLineCommand);
    
    #reheading the sam/bam file
    my $reheaderCommand = "$samtools reheader headerFile.txt $samFile";
    run($reheaderCommand);
    
    #returning if OK
    
    return 1;
}

#########################################
# Verifying the SAM/BAM format based on samtools view system
# samtools view gave an error in case of non SAM or BAM format
#########################################

sub checkSamOrBamFormat {
    
    my ($samFile)=@_;
    
    #Is the file sam of bam ? Requested for the -S option in samtools view
    my $inputOption;
    if ($samFile =~ m/\.bam$/) #The file is a BAM file
    {
	$inputOption = ""; #no specific option in samtools view requested
    }
    elsif ($samFile =~ m/\.sam$/) #the file is a SAM file
    {
	$inputOption = " -S ";#-S mean input is SAM
    }
    my $checkFormatCommand='$samtools view $inputOption $samFile -H > /dev/null';
    # The samtools view will ask only for the header to be outputted (-H option), and the STDOUT is redirected to nowher (>/dev/null);
    my $formatValidation=run($checkFormatCommand);
    
    if ($formatValidation == 1)                    # if no error occured in extracting header, ok
    {
        toolbox::exportLog("checkSamOrBam ok, your file -> $samFile <- is a SAM/BAM file, go on \n",1);
	return 1;
    }
    else                                # if one or some error(s) occured in extracting header, not ok
    {
        toolbox::exportLog("checkSamOrBam not ok, your file -> $samFile <- is not a SAM/BAM file, please check your file \n",0);
	return 0;
    }
}

1;