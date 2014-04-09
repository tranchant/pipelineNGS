#!/usr/bin/perl -w
use strict;

#Will test if bwa works correctly
use warnings;
use warnings;

use Test::More tests =>14; #Number of tests, to modify if new tests implemented. Can be changed as 'no_plan' instead of tests=>11 .
use Test::Deep;

use Data::Dumper;

use lib qw(../Modules/);

########################################
#use of bwa module ok
########################################
use_ok('toolbox') or exit;
use_ok('bwa') or exit;
can_ok( 'bwa','bwaIndex');
can_ok('bwa','bwaAln');
can_ok('bwa','bwaSampe');
use toolbox;
use bwa;
toolbox::readFileConf("software.config.txt");
########################################
#use of bwa index ok
########################################
my $fastaRef="../DATA/Reference.fasta";
my $fastqfile1="../DATA/RC1_1.fastq";
my $fastqfile2="../DATA/RC1_2.fastq";
my $datadir="../DATA";
my $samFileOut;
my $fowardSaiFileIn="../DATA/RC1_1.sai";
my $reverseSaiFileIn="../DATA/RC1_2.sai";


#######################################################################################################
####Test for bwa index
my $optionsHachees=$configInfos->{'BWA index'};
is(bwa::bwaIndex($fastaRef,$optionsHachees),1,'Ok for bwaIndex');
###Verify if output are corrct for bwa index
my @expectedOutput=('../DATA/config_file.txt','../DATA/RC1_1.fastq','../DATA/RC1_2.fastq','../DATA/Reference.fasta','../DATA/Reference.fasta.amb','../DATA/Reference.fasta.ann','../DATA/Reference.fasta.bwt','../DATA/Reference.fasta.pac','../DATA/Reference.fasta.sa','../DATA/software.config.txt');
my @outPut=toolbox::readDir($datadir);
is_deeply(\@expectedOutput,@outPut,'Output file ok for bwa index');

#######################################################################################################
###Test for bwa Aln
$optionsHachees=$configInfos->{'BWA aln'};
is (bwa::bwaAln($fastaRef,$fastqfile1,$optionsHachees),'1',"Ok for bwa Aln");
is (bwa::bwaAln($fastaRef,$fastqfile2,$optionsHachees),'1',"Ok for bwa Aln");

###Verify if output are correct for Aln
@expectedOutput=('../DATA/config_file.txt','../DATA/RC1_1.fastq','../DATA/RC1_1.sai','../DATA/RC1_2.fastq','../DATA/RC1_2.sai','../DATA/Reference.fasta','../DATA/Reference.fasta.amb','../DATA/Reference.fasta.ann','../DATA/Reference.fasta.bwt','../DATA/Reference.fasta.pac','../DATA/Reference.fasta.sa','../DATA/software.config.txt');
@outPut=toolbox::readDir($datadir);
is_deeply(\@expectedOutput,@outPut,'Output file ok for bwa aln');

########################################################################################################
####Test for bwa sampe
is(bwa::bwaSampe($samFileOut,$fastaRef,$fowardSaiFileIn,$reverseSaiFileIn,$fastqfile1,$fastqfile2),'1',"Ok for bwa sampe");
####Verify if output are correct for sampe
@expectedOutput=('../DATA/config_file.txt','../DATA/RC1_1.fastq','../DATA/RC1_1.sai','../DATA/RC1_1.sam','../DATA/RC1_2.fastq','../DATA/RC1_2.sai','../DATA/Reference.fasta','../DATA/Reference.fasta.amb','../DATA/Reference.fasta.ann','../DATA/Reference.fasta.bwt','../DATA/Reference.fasta.pac','../DATA/Reference.fasta.sa','../DATA/software.config.txt');
@outPut=toolbox::readDir($datadir);
is_deeply(\@expectedOutput,@outPut,'Output file ok for bwa sampe');
##

#####Remove the file created
unlink ('../DATA/RC1_1.sam');
###################################################################################################################
####Test for bwa Samse
is (bwa::bwaSamse($fastaRef,$fowardSaiFileIn,$fastqfile1),'1',"Ok for bwa samse");
###Verify if output are correct for samse
@expectedOutput=('../DATA/config_file.txt','../DATA/RC1_1.fastq','../DATA/RC1_1.sai','../DATA/RC1_1.sam','../DATA/RC1_2.fastq','../DATA/RC1_2.sai','../DATA/Reference.fasta','../DATA/Reference.fasta.amb','../DATA/Reference.fasta.ann','../DATA/Reference.fasta.bwt','../DATA/Reference.fasta.pac','../DATA/Reference.fasta.sa','../DATA/software.config.txt');
@outPut=toolbox::readDir($datadir);
is_deeply(\@expectedOutput,@outPut,'Output file ok for bwa samse');
unlink('../DATA/RC1_1.sam','../DATA/RC1_1.sai','../DATA/RC1_2.sai');