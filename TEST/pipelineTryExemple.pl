#!usr/bin/perl

##import of libraries
use strict;
use warnings;
use lib qw(../Modules/);
use toolbox;
use fastqc;
use cutadapt;
use pairing;
use bwa;
use samTools;
use gatk;
use Data::Dumper;
use picardTools;
##initialization of parameters
toolbox::readFileConf("software.config.txt");
my $optionsIndex=$configInfos->{'BWA index'};
my $optionsAln=$configInfos->{'BWA aln'};
my $optionsCutadapt=$configInfos->{'cutadapt'};
my $optionsGatkUnifiedgenotyper=$configInfos->{'GATK UnifiedGenotyper'};
my $optionsGatkSelectVariant=$configInfos->{'GATK selectVariants'};
my $optionsGatkReadBackedPhasing=$configInfos->{'GATK ReadBackedPhasing'};
my $optionsSamToolsViewSingle=$configInfos->{'samtools view single'};
my $optionsSamToolsViewPair=$configInfos->{'samtools view pair'};
my $optionsGatkRealignerTargetCreator=$configInfos->{'GATK gatkRealignerTargetCreator'};
my $optionsGatkHaplotypeCaller=$configInfos->{'GATK HaplotypeCaller'};
my $optionsGatkVariantFiltration=$configInfos->{'GATK VariantFiltration'};
my $optionsGatkSelectVariants=$configInfos->{'GATK SelectVariants'};
my $optionsgatkIndelRealigner=$configInfos->{'GATK gatkIndelRealigner'};
my $optionsgatkReadBackedPhasing=$configInfos->{'GATK ReadBackedPhasing'};
my $optionsPicarToolSortSamPair=$configInfos->{'picardTools sortsampair'};
my $optionsPicarToolSortSamSingle=$configInfos->{'picardTools sortsamsingle'};
my $optionsPicarToolMarkDuplicate=$configInfos->{'picardTools markduplicate'};


###################################
#print toolbox::checkFormatFastq($outputDir."reverse.fastq");
###Etape 1
###Fastqc
my $outputDir=""; ##Variable qui contient le chemin du dossier principale
if (@ARGV==0) { ## on vérifie si le dossier est bien passé en paramêtre
    print "I don't have any file to work on!!! Please give me some :-) \n";
    toolbox::exportLog("I don't have any file to work on!!! Please give me some  :-) \n",0);
}else{
    $outputDir=shift @ARGV;
    if (toolbox::existsDir($outputDir)==1) {
        print "Demarrage du pipeLine";
        
    }else{
        die "je ne trouve pas le dossier";
    }
}

####BWA INDEX on reference
my $refFastaFileIn=shift toolbox::readDir($outputDir,".fasta");
bwa::bwaIndex($refFastaFileIn,$optionsIndex);

###samTools Faidx (index) on reference
samTools::samToolsFaidx($refFastaFileIn);

###picardTools Create Sequence Dictionnary from reference
picardTools::picardToolsCreateSequenceDictionary($refFastaFileIn);

############################################################################
############################################################################
##Pairing and repairer
my $dictionnairePair=pairing::pairRecognition($outputDir);
pairing::createDirPerCouple($dictionnairePair);


my @pairFolders=split "\n", `ls -d $outputDir/*/ `;

foreach my $pairFolder (@pairFolders){
   
    ##FastqC
    my $fastqFiles=toolbox::readDir($pairFolder,".fastq");
    foreach my $fastqfile (@{$fastqFiles}){
        if(toolbox::sizeFile($fastqfile)==1){
            if (toolbox::checkFormatFastq($fastqfile)==1) {
                fastqc::exec($fastqfile,$pairFolder);
            }else{
                toolbox::exportLog("$fastqfile  is not a fastq file",0)
            }
        }else{
            toolbox::exportLog("$fastqfile doesn't exist or is empty ",0)
        }
    }   


######################################################################
    ###Cut Adapt
    my $fileAdaptator= shift toolbox::readDir($outputDir,".conf");
    print Dumper($fileAdaptator);
    my $confFile=toolbox::extractName($fileAdaptator)."Conf.conf";
    if (cutadapt::createConfFile($fileAdaptator,$confFile , $optionsCutadapt)==1){
    
        my $fastqFiles=toolbox::readDir($pairFolder,".fastq");
        foreach my $fastqfile (@{$fastqFiles}){
            if(toolbox::sizeFile($fastqfile)==1){
                if (toolbox::checkFormatFastq($fastqfile)==1) {
                    my $fileOut=toolbox::extractName($fastqfile)."_cutadapt.fastq";
                    cutadapt::exec( $fastqfile,$confFile,$fileOut);
                }else{
                    toolbox::exportLog("$fastqfile  is not a fastq file",0)
                }
            }else{
                toolbox::exportLog("$fastqfile doesn't exist or is empty ",0)
            }
        }
    }
    
    ###Repairing
    $fastqFiles=toolbox::readDir($pairFolder,"_cutadapt.fastq");
    my $forward=shift @{$fastqFiles};
    my $reverse=shift @{$fastqFiles};
    pairing::repairing($forward,$reverse);
    
    
    ##
    ###########################
    ##############################################################
    ###Align
    ###Aln des deux fichiers pairer
    $fastqFiles=toolbox::readDir($pairFolder,"_repaired.fastq");
    foreach my $fastqfile (@{$fastqFiles}){
        if(toolbox::sizeFile($fastqfile)==1){
                if (toolbox::checkFormatFastq($fastqfile)==1) {
                    bwa::bwaAln($refFastaFileIn,$fastqfile,$optionsAln);
                }else{
                    toolbox::exportLog("$fastqfile  is not a fastq file",0)
                }
            }else{
                toolbox::exportLog("$fastqfile doesn't exist or is empty ",0)
            }
    }
    ###SAMPE
    $forward=shift @{$fastqFiles};
    $reverse=shift @{$fastqFiles};
    my $forwardSaiFileIn=toolbox::extractName($forward).".sai";
    my $reverseSaiFileIn=toolbox::extractName($reverse).".sai";
    my $samFileOut=toolbox::extractName($forward).".sam";
    my $readGroup=$pairFolder;
    $readGroup=~ s/\///g;
    $readGroup=~ s/\.\.//g;
    bwa::bwaSampe($samFileOut,$refFastaFileIn,$forwardSaiFileIn,$reverseSaiFileIn,$forward,$reverse,$readGroup);
    
    ###SortSam
    my $samFileIn=$samFileOut;
    my $bamFileOut=toolbox::extractName($samFileIn)."_sorted.bam";
    picardTools::picardToolsSortSam($samFileIn,$bamFileOut,$optionsPicarToolSortSamPair);
     
    ###Samtools View
    my $bamFileIn=$bamFileOut;
    samTools::samToolsView($bamFileIn,$optionsSamToolsViewPair);
       
    
    
    
    
    
    ##Single
    ###########################
    ##############################################################
    ###Aln du fichier single
    ### A supprimer si le fichier single s appelle nom_single_repaired
    $fastqFiles=toolbox::readDir($pairFolder,"_single.fastq");
    foreach my $fastqfile (@{$fastqFiles}){
        if(toolbox::sizeFile($fastqfile)==1){
                if (toolbox::checkFormatFastq($fastqfile)==1) {
                    bwa::bwaAln($refFastaFileIn,$fastqfile,$optionsAln);
                }else{
                    toolbox::exportLog("$fastqfile  is not a fastq file",0)
                }
            }else{
                toolbox::exportLog("$fastqfile doesn't exist or is empty ",0)
            }
    }
    
     ###SAMSE
    my $single=shift @{$fastqFiles};
    my $singleSaiFileIn=toolbox::extractName($single).".sai";
    $samFileOut=toolbox::extractName($single).".sam";
    $readGroup=$pairFolder;
    $readGroup=~ s/\///g;
    $readGroup=~ s/\.\.//g;
    bwa::bwaSamse($samFileOut,$refFastaFileIn,$singleSaiFileIn,$single,$readGroup);
    
    ######Sort sam
    $samFileIn=$samFileOut;
    $bamFileOut=toolbox::extractName($samFileIn)."_sorted.bam";
    picardTools::picardToolsSortSam($samFileIn,$bamFileOut,$optionsPicarToolSortSamSingle);
 
    ###Samtools View
    $bamFileIn=$bamFileOut;
    samTools::samToolsView($bamFileIn,$optionsSamToolsViewSingle);
    ##################################################################################################################
    
    
    #####Suite du mapping
    ###Samtools Index
    my $bamFiles=toolbox::readDir($pairFolder,"_view.bam");
    foreach my $bamFile (@{$bamFiles}){
        if(toolbox::sizeFile($bamFile)==1){
            samTools::samToolsIndex($bamFile);
        }else{
            toolbox::exportLog("$bamFile doesn't exist or is empty ",0);
        }
    }
    
    ########################################################################
    ##Target CReator
    foreach my $bamFile (@{$bamFiles}){
        my $intervalsFile=toolbox::extractName($bamFile).".list";
        if(toolbox::sizeFile($bamFile)==1){
            gatk::gatkRealignerTargetCreator($refFastaFileIn, $bamFile, $intervalsFile, $optionsGatkRealignerTargetCreator);
        }else{
            toolbox::exportLog("$bamFile doesn't exist or is empty ",0);
        }
    }
    
    
    ########################################################################
    ##Target Indel REaligner
    foreach my $bamFile (@{$bamFiles}){
        my $intervalsFile=toolbox::extractName($bamFile).".list";
        my $bamRealigned=toolbox::extractName($bamFile)."_realigned.bam";
        if(toolbox::sizeFile($bamFile)==1){
            gatk::gatkIndelRealigner($refFastaFileIn, $bamFile, $intervalsFile, $bamRealigned, $optionsgatkIndelRealigner);
        }else{
            toolbox::exportLog("$bamFile doesn't exist or is empty ",0);
        }
    }
    
    ###Samtools Index
    $bamFiles=toolbox::readDir($pairFolder,"_realigned.bam");
    foreach my $bamFile (@{$bamFiles}){
        if(toolbox::sizeFile($bamFile)==1){
            samTools::samToolsIndex($bamFile);
        }else{
            toolbox::exportLog("$bamFile doesn't exist or is empty ",0);
        }
    }
    
    ####Remove duplicates
    foreach my $bamFile (@{$bamFiles}){
        my $bamOut=toolbox::extractName($bamFile)."_duplicateRemoved.bam";
        my $metrics=toolbox::extractName($bamFile).".metrics";
        if(toolbox::sizeFile($bamFile)==1){
            picardTools::picardToolsMarkDuplicates($bamFile, $bamOut, $metrics, $optionsPicarToolMarkDuplicate);
        }else{
            toolbox::exportLog("$bamFile doesn't exist or is empty ",0);
        }
    }
    
    ###Samtools Index
    $bamFiles=toolbox::readDir($pairFolder,"_duplicateRemoved.bam");
    foreach my $bamFile (@{$bamFiles}){
        if(toolbox::sizeFile($bamFile)==1){
            samTools::samToolsIndex($bamFile);
        }else{
            toolbox::exportLog("$bamFile doesn't exist or is empty ",0);
        }
    }  
}

###################################################################################################
    ###Merge bam
    my $bamOutFile=$outputDir."/merged.bam";
    my @bamFiles;
    foreach my $pairFolder (@pairFolders){
        foreach my $bamfile (toolbox::readDir($pairFolder,"_duplicateRemoved.bam")){
            push @bamFiles, $bamfile;
        }
    }
   
   
   my $bamFiles= shift \@bamFiles;
###   
    samTools::samToolsMerge($bamFiles,$bamOutFile);
    

########


    ##Samtools Index
    $bamFiles=toolbox::readDir($outputDir,"merged.bam");
    foreach my $bamFile (@{$bamFiles}){
        if(toolbox::sizeFile($bamFile)==1){
            samTools::samToolsIndex($bamFile);
        }else{
            toolbox::exportLog("$bamFile doesn't exist or is empty ",0);
        }
    }
    
    ###################################################################################################
    ####################################################################################################
    ################################### Calling ########################################################
    
    ######Happlotype Caller
    my $vcfCalled=$outputDir."/haplotype.vcf";
    my $bamsToCall=toolbox::readDir($outputDir,"merged.bam");
    
    gatk::gatkHaplotypeCaller($refFastaFileIn, $vcfCalled, $bamsToCall,$optionsGatkHaplotypeCaller);
    
    
    
    ######Variant filtrator
    my $vcfToFilter=$vcfCalled;
    my $vcfFiltered=toolbox::extractName($vcfToFilter)."_filtred.vcf";
    gatk::gatkVariantFiltration($refFastaFileIn, $vcfFiltered, $vcfToFilter, $optionsGatkVariantFiltration);
    
    
    
    ###############Select Variant
    my $vcfSnpKnownFile=$vcfFiltered;
    my $vcfVariantsSelected=$vcfFiltered=toolbox::extractName($vcfSnpKnownFile)."_SNP.vcf";
    gatk::gatkSelectVariants($refFastaFileIn, $vcfSnpKnownFile, $vcfVariantsSelected, $optionsGatkSelectVariants);
    
    my $vcfVariant=$vcfVariantsSelected;
    my $vcfFileOut=toolbox::extractName($vcfVariant)."_phased.vcf";
    my $bamFileIn=shift toolbox::readDir($outputDir,"merged.bam");
    #gatk::gatkReadBackedPhasing($refFastaFileIn, $bamFileIn,$vcfVariant, $vcfFileOut, $optionsgatkReadBackedPhasing);


