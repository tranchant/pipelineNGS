#!/usr/bin/perl -w
#Will test if samTools module work correctly works correctly
use strict;
use warnings;
use warnings;
use Test::More tests =>13; #Number of tests, to modify if new tests implemented. Can be changed as 'no_plan' instead of tests=>11 .
use Test::Deep;
use Data::Dumper;
use lib qw(../Modules/);

########################################
#use of samtools modules ok
########################################
use_ok('toolbox') or exit;
use_ok('samTools') or exit;
can_ok( 'samTools','samToolsIndex');
can_ok( 'samTools','samToolsView');
use toolbox;
use samTools;
########################################
#initialisation and setting configs
########################################
my $fastaRef="../DATA/Reference.fasta";
my $bamFile="../DATA/single.bam";
my $datadir="../DATA";
toolbox::readFileConf("software.config.txt");


################################################################################################
###Samtools faidx
is(samTools::samToolsFaidx($fastaRef),1,'Ok for samToolsFaidx');
###Verify if output are correct for Faidx
my @expectedOutput=('../DATA/config_file.txt','../DATA/paired.sam','../DATA/RC1_1.fastq','../DATA/RC1_2.fastq','../DATA/Reference.dict','../DATA/Reference.fasta','../DATA/Reference.fasta.fai','../DATA/single.bam','../DATA/single.sam','../DATA/software.config.txt');
my @outPut=toolbox::readDir($datadir);
is_deeply(\@expectedOutput,\@outPut,'Output file ok for samToolsFaidx');
##
##
##Samtools index
is(samTools::samToolsIndex($bamFile),1,'Ok for samToolsIndex');
##Verify if output are correct for Index
@expectedOutput=('../DATA/config_file.txt','../DATA/paired.sam','../DATA/RC1_1.fastq','../DATA/RC1_2.fastq','../DATA/Reference.dict','../DATA/Reference.fasta','../DATA/Reference.fasta.fai','../DATA/single.bam','../DATA/single.bam.bai','../DATA/single.sam','../DATA/software.config.txt');
@outPut=toolbox::readDir($datadir);
is_deeply(\@expectedOutput,\@outPut,'Output file ok for samToolsIndex');

##Samtools view
my $optionsHachees=$configInfos->{'samtools index'};
is(samTools::samToolsView($bamFile),1,'Ok for samToolsView');
##Verify if output are correct for View
@expectedOutput=('../DATA/config_file.txt','../DATA/paired.sam','../DATA/RC1_1.fastq','../DATA/RC1_2.fastq','../DATA/Reference.dict','../DATA/Reference.fasta','../DATA/Reference.fasta.fai','../DATA/single.bam','../DATA/single.bam.bai','../DATA/single.sam','../DATA/single_view.bam','../DATA/software.config.txt');
@outPut=toolbox::readDir($datadir);
is_deeply(\@expectedOutput,\@outPut,'Output file ok for samToolsIndex');
unlink('../DATA/single_view.bam','../DATA/single.bam.bai');

##Samtools sort
is(samTools::samToolsSort($bamFile),1,'Ok for samToolsView');
@expectedOutput=('../DATA/config_file.txt','../DATA/paired.sam','../DATA/RC1_1.fastq','../DATA/RC1_2.fastq','../DATA/Reference.dict','../DATA/Reference.fasta','../DATA/Reference.fasta.fai','../DATA/single.bam','../DATA/single.sam','../DATA/single_samtoolSorted.bam','../DATA/software.config.txt');
@outPut=toolbox::readDir($datadir);
is_deeply(\@expectedOutput,\@outPut,'Output file ok for samToolsSort');


my @bamFiles=('../DATA/single.bam','../DATA/single_samtoolSorted.bam');
##Samtools merge
$optionsHachees=$configInfos->{'samtools merge'};
is(samTools::samToolsMerge(\@bamFiles,'../DATA/out.bam',$optionsHachees),1,'Ok for samToolsView');
unlink('../DATA/single_samtoolSorted.bam');
#
#
#
# /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java -Xmx8g  -jar ~/Documents/STAGE_IRD/picard-tools/CreateSequenceDictionary.jar REFERENCE=Reference.fasta OUTPUT=Reference.dict
#/usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java -Xmx8g  -jar ~/Documents/STAGE_IRD/picard-tools/SortSam.jar I=single.sam O=single.bam
