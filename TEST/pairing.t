#/usr/bin/perl

###################################################################################################################################
#
# Licencied under CeCill-C (http://www.cecill.info/licences/Licence_CeCILL-C_V1-en.html) and GPLv3
#
# Intellectual property belongs to IRD, CIRAD and SouthGreen developpement plateform 
# Written by CŽcile Monat, Ayite Kougbeadjo, Mawusse Agbessi, Christine Tranchant, Marilyne Summo, CŽdric Farcy, Franois Sabot
#
###################################################################################################################################

#Will test if pairing.pm works correctly

use strict;
use warnings;
use Test::More tests => 7; #Number of tests, to modify if new tests implemented. Can be changed as 'no_plan' instead of tests=>11 .
use Data::Dumper;

use lib qw(../Modules/);

my $configFile='software.config.txt';

########################################
#use of pairing module ok
########################################

use_ok('pairing');

use pairing;

########################################
#pairRecognition ok
########################################
my $expectedOutput={
          '@CJP75M1:362:C20PVACXX:7:1101:1496:2086' => {
                                                         'ReadGroup' => 'first_forward',
                                                         'forward' => '../DATA-TEST/pairing.t-1/first_forward.fastq',
                                                         'reverse' => '../DATA-TEST/pairing.t-1/first_reverse.fastq'
                                                       },
          '@HWUSI-EAS454_0001:1:1:15:303#0' => {
                                                    'ReadGroup' => 'single',
                                                    'forward' => '../DATA-TEST/pairing.t-1/single.fastq'
                                               },
          '@HWUSI-EAS454_0001:1:1:15:301#0' => {
                                                 'ReadGroup' => 'second_forward',
                                                 'forward' => '../DATA-TEST/pairing.t-1/second_forward.fastq',
                                                 'reverse' => '../DATA-TEST/pairing.t-1/second_reverse.fastq'
                                               },
          '@HWUSI-EAS454_0001:1:1:15:911#0' => {
                                                   'ReadGroup' => 'second_forward_single',
                                                   'forward' => '../DATA-TEST/pairing.t-1/second_forward_single.fastq'
                                                 }
        };

my $observedoutput=pairing::pairRecognition('../DATA-TEST/pairing.t-1');
is_deeply($expectedOutput,$observedoutput,'pairRecognition');

########################################
#repairing ok
########################################
my $testDir='../DATA-TEST/pairing.t-2/';
toolbox::existsDir($testDir);

#Check if running
my $checkValue=pairing::repairing( '../DATA-TEST/pairing.t-1/second_forward.fastq','../DATA-TEST/pairing.t-1/second_reverse.fastq',$testDir);
is ($checkValue,'1','repairing running');

#Check if working
#my $numberOfLinesObserved=`wc -l ../DATA-TEST/pairing.t-2/second_SINGLE-REPAIRED-TEST.fastq`;
my $numberOfLinesObserved=`wc -l second_forward_single.fastq`;
chomp $numberOfLinesObserved;
is ($numberOfLinesObserved,'4 second_forward_single.fastq','repairing line number');

#Check if the files created are the same as planned
my $diffForward=`diff -q ../DATA-TEST/pairing.t-2/second_forward-REPAIRED-TEST.fastq second_forward_forwardRepaired.fastq`;
is ($diffForward,'','repairing diff forward');

#Check if the files created are the same as planned
my $diffReverse=`diff -q ../DATA-TEST/pairing.t-2/second_reverse-REPAIRED-TEST.fastq second_reverse_reverseRepaired.fastq`;
is ($diffReverse,'','repairing diff reverse');

#TODO: Ne pas mettre en dur le chemin, mettre la variable $testDir
system("rm -Rf ../DATA-TEST/pairing.t-2/*REPAIRING*");

########################################
#createDirPerCouple
########################################
my $testDir3='../DATA-TEST/pairing.t-3/';
toolbox::existsDir($testDir3);

my $checkValue3=pairing::createDirPerCouple(pairing::pairRecognition($testDir3),'../DATA-TEST/pairing.t-tmp/');
is ($checkValue3,1,'create directory per couple');

system("cp ../DATA-TEST/pairing.t-1/* ../DATA-TEST/pairing.t-3/");
#system("rm ../DATA-TEST/pairing.t-tmp/* -rf");