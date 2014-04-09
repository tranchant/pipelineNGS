# PICARD TOOLS MODULES #
package picardTools;

use strict;
use warnings;
use lib qw(.);
use localConfig;
use toolbox;


# PicardTools Mark Duplicates: Examines aligned records in the supplied BAM file to locate duplicate molecules. All records are then written to the output file with the duplicate records flagged
sub picardToolsMarkDuplicates
{
    my ($bamToAnalyze, $bamAnalyzed, $bamDuplicates, $optionsHachees) = @_;                                                                                                                                                                                                                  # recovery of information
    if (toolbox::sizeFile($bamToAnalyze)==1)                                                                                                                                                                                                                                # check if files exists and arn't empty and stop else
    {
        my $options="";
          if ($optionsHachees) {
               $options=toolbox::extractOptions($optionsHachees,"=");
          }
        my $comPicardToolsMarkDuplicates = "$picard/MarkDuplicates.jar $options INPUT=$bamToAnalyze OUTPUT=$bamAnalyzed METRICS_FILE=$bamDuplicates ";# VALIDATION_STRINGENCY=SILENT";                                                                                                   # command line
        toolbox::run($comPicardToolsMarkDuplicates);                                                                                                                                                                                                                        # command line execution
    }
    else                                                                                                                                                                                                                                                                    # if previous files doesn't exists or are empty or if picardToolsMarkDuplicates failed
    {
        toolbox::exportLog("picardToolsMarkDuplicates failed! Check error lines above", 0);                                                                                                                                                                                 # returns error message
    }
}

# PicardTools Merge BAM Alignment: Merges alignment data from a BAM file with additional data stored in an unmapped BAM file and produces a third BAM file of aligned and unaligned reads. 
sub picardToolsMergeBamAlignment
{
    my ($bamWithAdditionalData, $bam1, $bam2, $refFastaFileIn, $option, $bamFinal) = @_;                                                                                                                                                                                    # recovery of information
    if ((toolbox::sizeFile($bam1)==1) and (toolbox::sizeFile($bam2)==1) and (toolbox::sizeFile($refFastaFileIn)==1))                                                                                                                                                        # check if files exists and arn't empty and stop else
    {
        my $comPicardToolsMergeBamAlignment = "$picard/MergeBamAlignment.jar UNMAPPED_BAM=$bamWithAdditionalData READ1_ALIGNED_BAM=$bam1 READ2_ALIGNED_BAM=$bam2 OUTPUT=$bamFinal REFERENCE_SEQUENCE=$refFastaFileIn PAIRED_RUN=$option VALIDATION_STRINGENCY=SILENT";      # command line
        toolbox::run($comPicardToolsMergeBamAlignment);                                                                                                                                                                                                                     # command line execution
    }
    else                                                                                                                                                                                                                                                                    # if previous files doesn't exists or are empty or if picardToolsMarkDuplicates failed
    {
        toolbox::exportLog("picardToolsMergeBamAlignment failed! Check error lines above", 0);                                                                                                                                                                              # returns error message
    }
}


sub picardToolsCreateSequenceDictionary{
    my($refFastaFile,$dictFileOut,$optionsHachees)= @_;
    if (toolbox::sizeFile($refFastaFile)==1) {
        my $options="";
        if ($optionsHachees) {
             $options=toolbox::extractOptions($optionsHachees);
        }
        my $command="$picard/CreateSequenceDictionary.jar $options REFERENCE=$refFastaFile OUTPUT=$dictFileOut";
        #Execute command
        if(toolbox::run($command)==1){
             toolbox::exportLog("picardTools CreateSequenceDictionary sort done correctly \n",1);
             return 1;
        }
    }else{
        toolbox::exportLog("picardTools CreateSequenceDictionary failed! Chech your parameters and line above",0);
        return 0;
    }
}


sub picardToolsSortSam{
    my($bamOrSamFileIn,$bamOrSamFileOut,$optionsHachees)= @_;
    if (toolbox::sizeFile($bamOrSamFileIn)==1) {
        my $options="";
        if ($optionsHachees) {
            $options=toolbox::extractOptions($optionsHachees,"=");
        }
        my $command="$picard/SortSam.jar $options INPUT=$bamOrSamFileIn OUTPUT=$bamOrSamFileOut";
        #Execute command
        if(toolbox::run($command)==1){
             toolbox::exportLog("picardTools SortSam sort done correctly \n",1);
             return 1;
        }
    }else{
        toolbox::exportLog("picardTools SortSam failed! Chech your parameters and line above",0);
        return 0;
    }
}
1;