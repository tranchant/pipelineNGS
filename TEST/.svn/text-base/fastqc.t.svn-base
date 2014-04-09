#/usr/bin/perl

#Will test if the modue fastqc work correctly

use strict;
use warnings;

use Test::More  tests => 6;
use Test::Deep;
use Data::Dumper;
use lib qw(../Modules/);

########################################
#use of fastqc module ok
########################################
use_ok('toolbox') or exit;
use_ok('fastqc') or exit;
can_ok( 'fastqc','exec');
can_ok('fastqc','parse');

use toolbox;
use fastqc;
toolbox::readFileConf("software.config.txt");

########################################
#Input files
########################################
my $fastqcfile1="../DATA-TEST/RC1_2_fastq/";
my $outdir="../DATA-TEST/test_fastqc";



##########################################
#Fastqc exec test
##########################################
toolbox::makeDir($outdir);
is(fastqc::exec($fastqcfile1,$outdir),1,'Ok for exec');
#Verify if output are correct for Exec
my @expectedOutput=('../DATA/RC1_2_fastqc/');


#########################################
#Fastqc  parse test
#########################################
my $expectedOutput={'Encoding' => 'Illumina 1.5','Sequence_number'=> '1226','Sequence_length' => '76','GC'=> '50'};

my $observedoutput=fastqc::parse('../DATA-TEST/RC1_2_fastqc/');
print Dumper($observedoutput);
is_deeply($expectedOutput,$observedoutput,'parse');