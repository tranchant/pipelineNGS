#/usr/bin/perl

#Will test if pairing.pm works correctly

use strict;
use warnings;
use Test::More tests => 4; #Number of tests, to modify if new tests implemented. Can be changed as 'no_plan' instead of tests=>11 .
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
                                                         'forward' => '../DATA-TEST/Files_for_pairing_test/first_forward.fastq',
                                                         'reverse' => '../DATA-TEST/Files_for_pairing_test/first_reverse.fastq'
                                                       },
          '@HWUSI-EAS454_0001:1:1:15:303#0' => {
                                                 'forward' => '../DATA-TEST/Files_for_pairing_test/single.fastq'
                                               },
          '@HWUSI-EAS454_0001:1:1:15:301#0' => {
                                                 'forward' => '../DATA-TEST/Files_for_pairing_test/second_forward.fastq',
                                                 'reverse' => '../DATA-TEST/Files_for_pairing_test/second_reverse.fastq'
                                               }
        };

print Dumper(\pairing::pairRecognition('../DATA-TEST/Files_for_pairing_test'));
my $observedoutput=pairing::pairRecognition('../DATA-TEST/Files_for_pairing_test');
is_deeply($expectedOutput,$observedoutput,'pairRecognition');

########################################
#repairing ok
########################################

#Check if running
my $checkValue=pairing::repairing( '../DATA-TEST/Files_for_pairing_test/second_forward.fastq','../DATA-TEST/Files_for_pairing_test/second_reverse.fastq');
is ($checkValue,'1','repairing running');

#Check if working
my $numberOfLinesObserved=`wc -l ../DATA-TEST/Files_for_pairing_test/second_forward_single.fastq`;
chomp $numberOfLinesObserved;
is ($numberOfLinesObserved,'4 ../DATA-TEST/Files_for_pairing_test/second_forward_single.fastq','repairing');
system("rm -Rf ../DATA-TEST/Files_for_pairing_test/*repaired*");