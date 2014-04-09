# GATK MODULES #
package gatk;

use strict;
use warnings;
use lib qw(.);
use localConfig;
use toolbox;
use Data::Dumper;

# GATK Base Recalibrator: recalibrate the quality score of bases from informations stemming from SNP VCF file
sub gatkBaseRecalibrator
{
    my ($refFastaFileIn, $bamToRecalibrate, $vcfSnpKnownFile, $tableReport, $optionsHachees) = @_;                                                                                                                          # recovery of information
    if ((toolbox::sizeFile($refFastaFileIn)==1) and (toolbox::sizeFile($vcfSnpKnownFile)==1) and (toolbox::sizeFile($bamToRecalibrate)==1))                                                                                 # check if files exists and arn't empty and stop else
    {
        my $options=toolbox::extractOptions($optionsHachees);                                                                                                                                                                # extraction of options parameters
        #my $comGatkBaseRecalibrator = "$GATK -T BaseRecalibrator -I $bamToRecalibrate -R $refFastaFileIn -knownSites $vcfSnpKnownFile -o $tableReport";
        my $comGatkBaseRecalibrator = "$GATK"."$options"." -I $bamToRecalibrate -R $refFastaFileIn -knownSites $vcfSnpKnownFile -o $tableReport";                                                                            # command line
        toolbox::run($comGatkBaseRecalibrator);
        if(toolbox::run($comGatkBaseRecalibrator)==1){
            toolbox::exportLog("gatkBaseRecalibrator done correctly \n",1);
            return 1;# command line execution
        }else                                                                                                                                                                                                                    # if one or some previous files doesn't exist or is/are empty or if gatkBaseRecalibrator failed
            {
                toolbox::exportLog("gatkBaseRecalibrator failed! Check error lines above", 0);                                                                                                                                      # returns the error message
                return 0;
            }
    }
    else                                                                                                                                                                                                                    # if one or some previous files doesn't exist or is/are empty or if gatkBaseRecalibrator failed
    {
        toolbox::exportLog("gatkBaseRecalibrator failed! Check error lines above", 0);                                                                                                                                      # returns the error message
        return 0;
    }
}

# GATK Realigner Target Creator: determine (small) suspicious intervals which are likely in need of realignment
sub gatkRealignerTargetCreator
{
    my ($refFastaFileIn, $bamToRealigne, $intervalsFile, $optionsHachees) = @_;                                                                                                                                             # recovery of information
    if ((toolbox::sizeFile($refFastaFileIn)==1) and (toolbox::sizeFile($bamToRealigne)==1))                                                                                                                                 # check if files exists and arn't empty and stop else
    {
        my $options=toolbox::extractOptions($optionsHachees);                                                                                                                                                                # extraction of options parameters
        #my $comGatkRealignerTargetCreator = "$GATK -T RealignerTargetCreator -R $refFastaFileIn -I $bamToRealigne -o $intervalsFile --fix_misencoded_quality_scores -fixMisencodedQuals";
        my $comGatkRealignerTargetCreator = "$GATK"."$options"." -R $refFastaFileIn -I $bamToRealigne -o $intervalsFile ";#--fix_misencoded_quality_scores -fixMisencodedQuals";                                                # command line
        if(toolbox::run($comGatkRealignerTargetCreator)==1){                                                                                                                                                                      # command line execution
            toolbox::exportLog("gatkRealignerTargetCreator done correctly \n",1);
            return 1;
        }
    }
    else                                                                                                                                                                                                                    # if one or some previous files doesn't exist or is/are empty or if gatkRealignerTargetCreator failed
    {
        toolbox::exportLog("gatkRealignerTargetCreator failed! Check error lines above", 0);                                                                                                                                # returns the error message
        return 0;
    }
}

# GATK Indel Realigner: run the realigner over the intervals producted by gatk::gatkRealignerTargetCreator (see above)
sub gatkIndelRealigner
{
    my ($refFastaFileIn, $bamToRealigne, $intervalsFile, $bamRealigned, $optionsHachees) = @_;                                                                                                                              # recovery of information
    if ((toolbox::sizeFile($refFastaFileIn)==1) and (toolbox::sizeFile($bamToRealigne)==1) and (toolbox::readFile($intervalsFile)==1))                                                                                      # check if files exists and arn't empty and stop else
    {
        my $options=toolbox::extractOptions($optionsHachees);                                                                                                                                                                # extraction of options parameters
        #my  = "$GATK -T IndelRealigner -R $refFastaFileIn -I $bamToRealigne -targetIntervals $intervalsFile -o $bamRealigned --fix_misencoded_quality_scores -fixMisencodedQuals";
        my $comGatkIndelRealigner = "$GATK"."$options"." -R $refFastaFileIn -I $bamToRealigne -targetIntervals $intervalsFile -o $bamRealigned";# --fix_misencoded_quality_scores -fixMisencodedQuals";                         # command line
        if(toolbox::run($comGatkIndelRealigner)==1){                                                                                                                                                                               # command line execution
            toolbox::exportLog("gatkIndelRealigner done correctly \n",1);
            return 1;
        }
    }
    else                                                                                                                                                                                                                    # if one or some previous files doesn't exist or is/are empty or if gatkIndelRealigner failed
    {
        toolbox::exportLog("gatkIndelRealigner failed! Check error lines above", 0);                                                                                                                                        # returns the error message
        return 0;
    }
}

# GATK Haplotype Caller: Haplotypes are evaluated using an affine gap penalty Pair HMM.
sub gatkHaplotypeCaller
{
    my ($refFastaFileIn, $vcfCalled, $bamsToCall, $optionsHachees, $vcfSnpKnownFile, $intervalsFile) = @_;                                                                                                      # recovery of information
    if (toolbox::sizeFile($refFastaFileIn)==1)     # check if files exist and isn't empty and stop else
    {
        my $dbsnp="";
        if (($vcfSnpKnownFile) and (toolbox::sizeFile($vcfSnpKnownFile)==0)) {
            toolbox::exportLog("gatkHaplotypeCaller failed! Check error lines above", 0);                                                                                                                                       # returns the error message
            return 0;
        }
        if (($vcfSnpKnownFile) and (toolbox::sizeFile($vcfSnpKnownFile)==1)) {
            $dbsnp=" --dbsnp $vcfSnpKnownFile";
        }
        
        my $intervals="";
        if (($intervalsFile) and (toolbox::sizeFile($intervalsFile)==0)) {
            toolbox::exportLog("gatkHaplotypeCaller failed! Check error lines above", 0);                                                                                                                                       # returns the error message
            return 0;
        }
        if (($intervalsFile) and (toolbox::sizeFile($intervalsFile)==1)) {
            $intervalsFile="-L $intervalsFile";
        }
        
        my $bamFiles_names="";
        foreach my $file (@{$bamsToCall}){
            if (toolbox::sizeFile($file)==1){
                $bamFiles_names.="-I ".$file." ";
            }else{
                toolbox::exportLog("gatkHaplotypeCaller failed! Check error lines above", 0);                                                                                                                                       # returns the error message
                return 0;  
            }
        }
        
        my $options="";
        if ($optionsHachees) {
            $options=toolbox::extractOptions($optionsHachees);##Get given options
        }
        # extraction of options parameters
        #my $comGatkHaplotypeCaller = "$GATK -T HaplotypeCaller -R $refFastaFileIn -I $bamToCall -I $bamToCall2 --dbsnp $vcfSnpKnownFile -L $intervalsFile -o $vcfCalled";
        #my $comGatkHaplotypeCaller = "$gatk"."$options"." -R $refFastaFileIn -I $bamToCall -I $bamToCall2 --dbsnp $vcfSnpKnownFile -L $intervalsFile -o $vcfCalled";                                                         # command line
        my $comGatkHaplotypeCaller = "$GATK"."$options"." -R $refFastaFileIn $bamFiles_names $dbsnp $intervals -o $vcfCalled";                                                         # command line
        if(toolbox::run($comGatkHaplotypeCaller)==1){                                                                                                                                                                              # command line execution
            toolbox::exportLog("gatkHaplotypeCaller done correctly \n",1);
            return 1;
        }
        else                                                                                                                                                                                                                    # if one or some previous files doesn't exist or is/are empty or if gatkHaplotypeCaller failed
            {
                toolbox::exportLog("gatkHaplotypeCaller failed! Check error lines above", 0);                                                                                                                                       # returns the error message
                return 0;
            }
    }
    else                                                                                                                                                                                                                    # if one or some previous files doesn't exist or is/are empty or if gatkHaplotypeCaller failed
    {
        toolbox::exportLog("gatkHaplotypeCaller failed! Check error lines above", 0);                                                                                                                                       # returns the error message
        return 0;
    }
}

# GATK Select Variants: Selects variants from a VCF source.
sub gatkSelectVariants
{
    my ($refFastaFileIn, $vcfSnpKnownFile, $vcfVariantsSelected, $optionsHachees) = @_;                                                                                                                                     # recovery of information
    if ((toolbox::sizeFile($refFastaFileIn)==1)  and  (toolbox::sizeFile($vcfSnpKnownFile)==1))                                                                                                                                                                        # check if ref file exist and isn't empty and stop else
    {
        my $options=toolbox::extractOptions($optionsHachees);                                                                                                                                                                # extraction of options parameters
        #my $comGatkSelectVariants = "$GATK -T SelectVariants -R $refFastaFileIn --variant $vcfSnpKnownFile -o $vcfVariantsSelected -selectType SNP";
        my $comGatkSelectVariants = "$GATK"."$options"." -R $refFastaFileIn --variant $vcfSnpKnownFile -o $vcfVariantsSelected";                                                                                             # command line
        if(toolbox::run($comGatkSelectVariants)==1){                                                                                                                                                                             # command line execution
            toolbox::exportLog("gatkSelectVariants done correctly \n",1);
            return 1;
        }else                                                                                                                                                                                                                    # if one or some previous files doesn't exist or is/are empty or if gatkSelectVariants failed
            {
                toolbox::exportLog("gatkSelectVariants failed! Check error lines above", 0);                                                                                                                                        # returns the error message
                return 0;
            }
    }
    else                                                                                                                                                                                                                    # if one or some previous files doesn't exist or is/are empty or if gatkSelectVariants failed
    {
        toolbox::exportLog("gatkSelectVariants failed! Check error lines above", 0);                                                                                                                                        # returns the error message
        return 0;
    }
}

# GATK Variant Filtration: filter variant calls using a number of user-selectable, parameterizable criteria.
sub gatkVariantFiltration
{
    my ($refFastaFileIn, $vcfFiltered, $vcfToFilter, $optionsHachees) = @_;                                                                                                                                                 # recovery of information
    if ((toolbox::sizeFile($refFastaFileIn)==1) and (toolbox::sizeFile($vcfToFilter)==1))                                                                                                                                   # check if ref file exist and isn't empty and stop else
    {
        my $options="";
        if ($optionsHachees) {
            $options=toolbox::extractOptions($optionsHachees);##Get given options
        }
        print Dumper($options);# extraction of options parameters
        #my $comGatkVariantFiltration = "$GATK -R $refFastaFileIn -T VariantFiltration -o $vcfFiltered --variant $vcfToFilter";
        my $comGatkVariantFiltration = "$GATK"."$options"." -R $refFastaFileIn -o $vcfFiltered --variant $vcfToFilter";                                                                                                      # command line
        if(toolbox::run($comGatkVariantFiltration)==1){                                                                                                                                                                          # command line execution
            toolbox::exportLog("gatkVariantFiltration done correctly \n",1);
            return 1;
        }else                                                                                                                                                                                                                    # if one or some previous files doesn't exist or is/are empty or if gatkVariantFiltration failed
            {
                toolbox::exportLog("gatkVariantFiltration failed! Check error lines above", 0);                                                                                                                                     # returns the error message
                return 0;
            }
    }
    else                                                                                                                                                                                                                    # if one or some previous files doesn't exist or is/are empty or if gatkVariantFiltration failed
    {
        toolbox::exportLog("gatkVariantFiltration failed! Check error lines above", 0);                                                                                                                                     # returns the error message
        return 0;
    }
}


# GATK Unified Genotyper:
### I need a reference index in fai format and dictionnary at the same to the reference.fasta file
sub gatkUnifiedGenotyper
{
    my ($refFastaFileIn, $bamFileIn, $vcfFileOut, $optionsHachees) = @_;                                                                                                                                                 # recovery of information
    if ((toolbox::sizeFile($refFastaFileIn)==1) and (toolbox::sizeFile($bamFileIn)==1))                                                                                                                                   # check if ref file exist and isn't empty and stop else
    {
        my $options=toolbox::extractOptions($optionsHachees);
        my $comGatkUnifiedGenotyper = "$GATK"."$options"." -R $refFastaFileIn -I $bamFileIn -o $vcfFileOut";                                                                                                      # command line
        if(toolbox::run($comGatkUnifiedGenotyper)==1){                                                                                                                                                                          # command line execution
            toolbox::exportLog("gatkUnifiedGenotyper done correctly \n",1);
            return 1;
        }
        else{                                                                                                                                                                                                                  # if one or some previous files doesn't exist or is/are empty or if gatkVariantFiltration failed
            toolbox::exportLog("gatkUnifiedGenotyper failed! Check error lines above", 0);                                                                                                                                     # returns the error message
            return 0;
        }
    }
    else                                                                                                                                                                                                                    # if one or some previous files doesn't exist or is/are empty or if gatkVariantFiltration failed
    {
        toolbox::exportLog("gatkUnifiedGenotyper failed! Check error lines above", 0);                                                                                                                                     # returns the error message
        return 0;
    }
}

# GATK Read backedPhasing
sub gatkReadBackedPhasing
{
    my ($refFastaFileIn, $bamFileIn,$vcfVariant, $vcfFileOut, $optionsHachees) = @_;                                                                                                                                                 # recovery of information
    if ((toolbox::sizeFile($refFastaFileIn)==1) and (toolbox::sizeFile($bamFileIn)==1) and (toolbox::sizeFile($vcfVariant)==1))                                                                                                                                   # check if ref file exist and isn't empty and stop else
    {
        my $options=toolbox::extractOptions($optionsHachees);
        my $comGatkReadBackedPhasing = "$GATK"."$options"." -R $refFastaFileIn -I $bamFileIn --variant $vcfVariant -o $vcfFileOut";                                                                                                      # command line
        if(toolbox::run($comGatkReadBackedPhasing)==1){                                                                                                                                                                          # command line execution
            toolbox::exportLog("gatkReadBackedPhasing done correctly \n",1);
        }
    }
    else                                                                                                                                                                                                                    # if one or some previous files doesn't exist or is/are empty or if gatkVariantFiltration failed
    {
        toolbox::exportLog("gatkReadBackedPhasing failed! Check error lines above", 0);                                                                                                                                     # returns the error message
    }
}
1;
