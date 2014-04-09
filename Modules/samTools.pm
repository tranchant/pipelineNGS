package samTools;

use strict;
use warnings;
use lib qw(.);
use localConfig;
use toolbox;
use Data::Dumper;

##############################################
##SamTools
##Module containing SamTools functions
##############################################
##
##
##SAMTOOLS Faidx
#Index reference sequence in the FASTA format or extract subsequence from indexed reference sequence.
sub samToolsFaidx{
     my($refFastaFileIn)=@_;
     if (toolbox::sizeFile($refFastaFileIn)==1){ ##Check if entry file exist and is not empty
          #Execute command
          my $command=$samtools." faidx ".$refFastaFileIn;
          if(toolbox::run($command)==1){
               toolbox::exportLog("samtools faidx done correctly \n",1);
               return 1;
          }else{
               toolbox::exportLog("samtools faidx  failed! Chech your parameters and line above",0);
               return 0;
          }
     }else{
        toolbox::exportLog("samtools faidx  failed! Chech your parameters and line above",0);
        return 0;
     }
}
##
##
##SAMTOOLS INDEX
#Index sorted alignment for fast random access.
sub samToolsIndex{
     my($bamFileIn)=@_;
     if (toolbox::sizeFile($bamFileIn)==1){ ##Check if entry file exist and is not empty
          #Execute the command
          my $command=$samtools." index ".$bamFileIn;
          #Execute command
          if(toolbox::run($command)==1){
               toolbox::exportLog("samtools index done correctly \n",1);
               return 1;
          }else{
               toolbox::exportLog("samtools index failed! Chech your parameters and line above",0);
               return 0;
               }
     }else{
        toolbox::exportLog("samtools index failed! Chech your parameters and line above",0);
        return 0;
    }
}

##
##
##SAMTOOLS VIEW
#Extract/print all or sub alignments in SAM or BAM format.
sub samToolsView{
     my($bamFileIn,$bamFileOut,$optionsHachees)=@_;
     if (toolbox::sizeFile($bamFileIn)==1){ ##Check if entry file exist and is not empty

          my $options="";
          if ($optionsHachees) {
               $options=toolbox::extractOptions($optionsHachees); ##Get given options
          }
          my $command=$samtools." view ".$options." -o ".$bamFileOut." ".$bamFileIn;
          #Execute command
          if(toolbox::run($command)==1){
               toolbox::exportLog("samtools view done correctly \n",1);
               return 1;
          }else{
               toolbox::exportLog("samtools view failed! Chech your parameters and line above",0);
               return 0;
               }
     }else{
        toolbox::exportLog("samtools view failed! Chech your parameters and line above",0);
        return 0;
    }
}
#TODO: here will function only on SingleEnd data for cleaning!


##
##
##SAMTOOLS SORT
#Sort alignments by leftmost coordinates.
sub samToolsSort{
     my($bamFileIn,$optionsHachees)=@_;
     if (toolbox::sizeFile($bamFileIn)==1){ ##Check if entry file exist and is not empty
          my $bamFileOut=toolbox::extractName($bamFileIn)."_samtoolSorted.bam";
          my $options="";
          if ($optionsHachees) {
               $options=toolbox::extractOptions($optionsHachees);
          }
          my $command=$samtools." sort ".$options." ".$bamFileIn." ".$bamFileOut;
          #Execute command
          if(toolbox::run($command)==1){
               toolbox::exportLog("samTools sort done correctly \n",1);
               return 1;
          }else{
                    toolbox::exportLog("samtools sort failed! Chech your parameters and line above",0);
                    return 0;
               }
     }else{
        toolbox::exportLog("samtools sort failed! Chech your parameters and line above",0);
        return 0;
     }
}

##
##
##SAMTOOLS MERGE
#Merge multiple sorted alignments.
sub samToolsMerge{
     my($bamFiles,$bamOutFile,$optionsHachees)=@_;
     print Dumper($bamFiles);
     my $bamFiles_names="";
     my $fileExist=1;
     foreach my $file (@{$bamFiles}){
          $fileExist=$fileExist * toolbox::sizeFile($file);
          $bamFiles_names.=" ".$file;
     }
     print Dumper($bamFiles_names);
     if ($fileExist==1) {
          my $options="";
          if ($optionsHachees) {
               $options=toolbox::extractOptions($optionsHachees);
          }
         
          my $command=$samtools." merge ".$options." ".$bamOutFile." ".$bamFiles_names;
          #Execute command
          if(toolbox::run($command)==1){
               toolbox::exportLog("samTools Merge done correctly \n",1);
               return 1;
          }else{
                    toolbox::exportLog("samtools merge failed! Chech your parameters and line above",0);
                    return 0;
               }
     }else{
        toolbox::exportLog("samtools merge failed! Chech your parameters and line above",0);
        return 0;
     }
}

##
##
##SAMTOOLS FLAGSTATS
#Provide simple stats on a BAM/SAM file.



##
##
##SAMTOOLS DEPTH
#Compute the depth on a BAM file.



##
##
##SAMTOOLS RMDUP
#Remove Duplicates in a SAM/BAM files based on outmost coordinates.


##
##
##SAMTOOLS REHEADER
#Replace a BAM header


1;
  