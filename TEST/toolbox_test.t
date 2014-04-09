#/usr/bin/perl

#Will test if toolbox works correctly
#Modified version by Francois version2
#test du 02/04/14

use strict;
use warnings;
use Test::More tests => 15; #Number of tests, to modify if new tests implemented. Can be changed as 'no_plan' instead of tests=>11 .


use lib qw(../Modules/);
use toolbox;

my $configFile='software.config.txt';

########################################
#use of toolbox module ok
########################################

use_ok('toolbox');




########################################
#File infos tests
########################################

#existsFile
is (toolbox::existsFile($configFile,1),'1','Ok for existsFile');

#readFile test
is (toolbox::readFile($configFile),'1','Ok for readFile');

#writeFile test TODO to verify

TODO: {
    local $TODO = 'writeFile seems to act weird, check';
    is (toolbox::writeFile($configFile),'1','Ok for writeFile');
}

#sizeFile test
ok (toolbox::sizeFile($configFile) > 0,'Ok for sizeFile');


########################################
#Directory test
########################################

#existsDir
is (toolbox::existsDir('../DATA'),'1','Ok for existsDir');

#makeDir
is (toolbox::makeDir('../TEST/test_dir'),'1','Ok for makedir');
system ("rm -Rf ../TEST/test_dir");

#readDir
my $listCom = `ls ../DATA/*`;
chomp $listCom;
my @listExpected = split /\n/, $listCom;
my @listObserved = toolbox::readDir('../DATA');
is_deeply(\@listExpected,\@listObserved,'Ok for readDir');

########################################
#Path test
########################################

#Path test
my @expectedList=("toto","/home/username/");
my @testList=toolbox::extractPath('/home/username/toto');
is_deeply (\@expectedList,\@testList,'Ok for extractPath');

########################################
#Config file test
########################################

#Config file to use
my $configFileTest=$configFile;

#Compiling config file infos
toolbox::readFileConf($configFileTest);

#checking if $configInfos exists

is (ref($configInfos),'HASH','Ok for the reference to be a HASH');

#checking how many software configs
my @listOfSoftwares=keys ($configInfos);#Soft are BWA and samtoolsView
my $numberOfSoft= scalar (@listOfSoftwares); #expecting 3
ok ($numberOfSoft == 3, 'Ok for the number of software to configure');

#checking for info retrieval, directly, ie data stracture
is ($configInfos->{"samtools view"}{-f},'0x02','Ok for samtools view infos retrieval');

#checking for info extract
my $optionLine=toolbox::extractOptions($configInfos->{BWA}," ");
ok ($optionLine =~ m/-n 4/ && $optionLine =~ m/-e 5/,'Ok for extractOptions'); #Test as an ok form because of randomness of hash sorting, to be sure of controlling the data



########################################
#Run command test
########################################

#testing rendering ie return 1
my $testCom="date +%D >> log.txt"; # print the date in the log, format MM/DD/YYYY
my $returnValue=toolbox::run($testCom);
ok ($returnValue== 1, 'Ok for toolbox::run return value');

#testing correct behaviour
my $date=`date +%D`; # The previous test will print the date in the log, format MM/DD/YYYY
chomp $date;
my $endOfLog=`tail -n 2 log.txt | head -n 1`; #The last line of log is always "Command Done", so pick up the two last and keep the n-1 line
chomp $endOfLog;
ok($date eq $endOfLog,'Ok for toolbox::run command behaviour')
    
#test commit