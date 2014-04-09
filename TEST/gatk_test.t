#!/usr/bin/perl -w
use strict;

#Will test if bwa works correctly
use warnings;
use warnings;

use Test::More 'no_plan'; #Number of tests, to modify if new tests implemented. Can be changed as 'no_plan' instead of tests=>11 .
use Test::Deep;

use Data::Dumper;

use lib qw(../Modules/);


use_ok('toolbox') or exit;
use_ok('gatk') or exit;
can_ok( 'gatk','gatkBaseRecalibrator');
can_ok('gatk','gatkRealignerTargetCreator');
can_ok('gatk','gatkIndelRealigner');
can_ok('gatk','gatkHaplotypeCaller');
can_ok('gatk','gatkSelectVariants');
can_ok('gatk','gatkVariantFiltration');
can_ok('gatk','gatkUnifiedGenotyper');
use toolbox;
use gatk;

toolbox::readFileConf("software.config.txt");
#
#
#
####Test for gatk variant filtrator
my $bamFileIn="../DATA-TEST/gatk/merged.bam";
my $refFastaFileIn="../DATA-TEST/gatk/cprice.fasta";
my $optionsHachees=$configInfos->{'GATK UnifiedGenotyper'};
is(gatk::gatkUnifiedGenotyper($refFastaFileIn, $bamFileIn, "../DATA-TEST/gatk/raw.vcf", $optionsHachees),1,'Ok for gatkUnifiedGenotyper');
##
##
##
####Test for gatk haplotype caller
$optionsHachees=$configInfos->{'GATK HaplotypeCaller'};
my $vcfCalled="../DATA-TEST/gatk/raw2.vcf";
$bamFileIn=toolbox::readDir("../DATA-TEST/gatk","merged.bam");

is(gatk::gatkHaplotypeCaller($refFastaFileIn, $vcfCalled, $bamFileIn, $optionsHachees),1,"Ok for gatk Haplotype Caller");


#####Test for gatk variant filtrator
my $vcfToFilter="../DATA-TEST/gatk/raw2.vcf";
$optionsHachees=$configInfos->{'GATK VariantFiltration'};
is(gatk::gatkVariantFiltration($refFastaFileIn, "../DATA-TEST/gatk/raw_filtred.vcf", $vcfToFilter, $optionsHachees),1,'Ok for gatk Variant Filtratrion');
##
##
##
#####Test for gatk Select Variant
$optionsHachees=$configInfos->{'GATK SelectVariants'};
my $vcfSnpKnownFile="../DATA-TEST/gatk/raw_filtred.vcf";
my $vcfVariantsSelected="../DATA-TEST/gatk/raw_variantsSelected.vcf";
is(gatk::gatkSelectVariants($refFastaFileIn, $vcfSnpKnownFile, $vcfVariantsSelected, $optionsHachees),1, 'Ok for gatk Select Variants');
##
##
##
#####Test for gatk Read Backed Phasing
$optionsHachees=$configInfos->{'GATK ReadBackedPhasing'};
$bamFileIn="../DATA-TEST/gatk/merged.bam";
my $vcfVariant="../DATA-TEST/gatk/raw_variantsSelected.vcf";
my $vcfFileOut="../DATA-TEST/gatk/phased.vcf";
is(gatk::gatkReadBackedPhasing($refFastaFileIn, $bamFileIn,$vcfVariant, $vcfFileOut, $optionsHachees),1, 'Ok for gatk Select Variants');
##
##
##
#####Test for gatkRealignerTargetCreator
$optionsHachees=$configInfos->{'GATK gatkRealignerTargetCreator'};
my $bamToRealigne="../DATA-TEST/gatk/merged.bam";
my $intervalsFile="forIndelRealigner.intervals";
is(gatk::gatkRealignerTargetCreator($refFastaFileIn, $bamToRealigne, $intervalsFile, $optionsHachees),1, 'Ok for gatk BaseRecalibrator');
##
##
##
##
#####Test for gatkIndelRealigner
$optionsHachees=$configInfos->{'GATK gatkIndelRealigner'};
$bamToRealigne="../DATA-TEST/gatk/merged.bam";
$intervalsFile="forIndelRealigner.intervals";
my $bamRealigned="../DATA-TEST/gatk/merged_rea.bam";
is(gatk::gatkIndelRealigner($refFastaFileIn, $bamToRealigne, $intervalsFile, $bamRealigned, $optionsHachees),1, 'Ok for gatk BaseRecalibrator');
##
##
#####Test for gatkBaseRecalibrator
$optionsHachees=$configInfos->{'GATK gatkBaseRecalibrator'};
my $bamToRecalibrate="../DATA-TEST/gatk/merged.bam";
my $tableReport="../DATA-TEST/gatk/recal_data.table";
$vcfSnpKnownFile="../DATA-TEST/gatk/raw_variantsSelected.vcf";
is(gatk::gatkBaseRecalibrator($refFastaFileIn, $bamToRecalibrate, $vcfSnpKnownFile, $tableReport, $optionsHachees),1, 'Ok for gatk BaseRecalibrator');
##
##
##