# CUFFLINKS MODULE BEUUUURRRRKKK LE RETOUR! #
package cufflinks;

use strict;
use warnings;
use lib qw(.);
use localConfig;
use toolbox;
use Data::Dumper;
###################################
##############################################
##CUFFLINKS
##Module containing CUFFLINKS functions
##############################################
##
##
##Assembly with Cufflinks
sub cufflinks
    {
    my($refFasta, $annotation, $alignementFile, $optionsHachees)=@_;
    #if (toolbox::sizeFile($refFastaFileIn)==1){     ##Check if the reference file exist and is not empty
        my $options=toolbox::extractOptions($optionsHachees, " "); 
        my $command= "$cufflinks/cufflinks"." $options"." -b $refFasta -g $annotation $alignementFile";
        
        toolbox::run($command);
        if(toolbox::run($command)==1)
            {
            toolbox::exportLog("Assembly with Cufflinks done \n",1);
            return 1;
            }
        else                                                                                                                                                                                                                    # if one or some previous files doesn't exist or is/are empty or if gatkBaseRecalibrator failed
            {
            toolbox::exportLog("Error when running cufflinks", 0);                                                                                                                                      # returns the error message
                return 0;
            }
     }
    


##
##
##Merging with Cuffmerge
sub cuffmerge{
    my ($refFasta, $annotationGff, $inputDir, $inputFile, $outdir)=@_;
    #
    #create the outputdir
    toolbox::makeDir($outdir);
    #creation the assemblies.txt file
    system  ("ls $inputDir | grep '*.gtf' > list.txt");
    
    open (IN, "list.txt");
    open (OUT, ">assemblies.txt");
    while (<IN>) {
	if ($_ =~/^(.*)$/){
		my $file=$1; print OUT "./$file\n" ;}
	  }
    my $cuffmergecommand =  $cufflinks."/cuffmerge". "-o $outdir  -s $refFasta -g $annotationGff  assemblies.txt";
    #
    #execution of the command
    toolbox::run($cuffmergecommand);
        if(toolbox::run($cuffmergecommand)==1)
            {
            toolbox::exportLog("Mering with Cuffmerge done \n",1);
            return 1;
            }
        else                                                                                                                                                                                                                    # if one or some previous files doesn't exist or is/are empty or if gatkBaseRecalibrator failed
            {
            toolbox::exportLog("Error when running Merging files", 0);                                                                                                                                      # returns the error message
                return 0;
            }

}
##
##
##Cuffdiff
#Index database sequences in the FASTA format.
sub cuffdiff{
    my($refFasta, $mergedFile, $bamFileIn, $annotation, $outdir, $optionsHachees)=@_;
    #if (toolbox::sizeFile($refFastaFileIn)==1){     ##Check if the reference file exist and is not empty
        my $options=toolbox::extractOptions($optionsHachees, " "); 
       # my $command=$bwa." index ".$options." ".$refFastaFileIn; ##command
        my $command=$cufflinks."/cuffdiff". $options." -o $outdir -b $refFasta -u $mergedFile" ; 

        toolbox::run($command);
        if(toolbox::run($command)==1)
            {
            toolbox::exportLog("Assembly with Cufflinks done \n",1);
            return 1;
            }
        else                                                                                                                                                                                                                    # if one or some previous files doesn't exist or is/are empty or if gatkBaseRecalibrator failed
            {
            toolbox::exportLog("Error when running cufflinks", 0);                                                                                                                                      # returns the error message
                return 0;
            }
     }
    

