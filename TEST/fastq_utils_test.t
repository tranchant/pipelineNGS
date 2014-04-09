#!/usr/bin/perl -w

#Will test if fastq_utils works correctly
use strict;
use warnings;
use Data::Translate;#To convert ASCII to decimal
use Test::More 'no_plan'; #Number of tests, to modify if new tests implemented. Can be changed as 'no_plan' instead of tests=>11 .
use lib qw(../Modules);
use toolbox;

########################################
#use of fastq_utils module ok
########################################

use_ok('fastq_utils');
use fastq_utils;

#########################################
#Sequence count test
#########################################

#checkNumber test with a fastq file
my $fastqFile='../DATA-TEST/RC1_1.fastq';
my $count = fastqUtils::checkNumber($fastqFile);
is ($count,'1226','Ok for checkNumber');

#checkNumber test with a fastqc file
my $fastqcFile='../DATA-TEST/RC1_1_fastqc/fastqc_data.txt';
my %fastqcHash = fastqUtils::fastqcToHash($fastqcFile);

$count = fastqUtils::checkNumber(%fastqcHash);
is ($count,'1226','Ok for checkNumberByFASTQC');

#########################################
# Encode conversion test
#########################################

#generate Test data file
my $fastqFileOut33 = '../DATA-TEST/RC1_1_phred33.fastq';
my $formatInit = 64;
my $formatOut = 33;
fastqUtils::changeEncode($fastqFile,$fastqFileOut33,$formatInit,$formatOut);  

my $fastqFileOut64 = '../DATA-TEST/RC1_1_phred64.fastq';
$formatInit = 33;
$formatOut = 64;
fastqUtils::changeEncode($fastqFileOut33,$fastqFileOut64,$formatInit,$formatOut);  

#########################################
# Encode check test
#########################################

#TODO test with fastqc file

#checkEncode test with a fastq file
is (fastqUtils::checkEncode($fastqFileOut33),'1','Ok for checkEncode');
is (fastqUtils::checkEncode($fastqFileOut64),'0','Ok for checkEncode');

#checkEncode test with a fastqc file
is (fastqUtils::checkEncode(%fastqcHash),'0','Ok for checkEncode with fastqc');