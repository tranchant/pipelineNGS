#!/usr/bin/perl -w
use strict;
use warnings;

use Test::More tests => 6;
use lib qw(../Modules/);


### Test of cutadapt.pm ###
use_ok('toolbox') or exit;                                                                          # Check if toolbox is usable
use_ok('cutadapt') or exit;                                                                         # Check if cutadapt is usable
can_ok('cutadapt','createConfFile');                                                                # Check if cutadapt::createConfFile is find
can_ok('cutadapt','execution');                                                                     # Check if cutadapt::execution is find

use toolbox;
use cutadapt;
############################


### Files for test ###
my $fileAdaptator = "../DATA-TEST/adaptators.txt";                                                  # File with adaptators sequences
my $fileConf = "../DATA-TEST/cutadapt.conf";                                                        # File for configuration informations
my $fileIn = "../DATA-TEST/RC1_1.fastq";                                                            # Input file with adaptators sequences to remove
my $fileOut = "../DATA-TEST/RC1_1.CUTADAPT.fastq";                                                  # Output file without adaptators sequences
######################


### Test of cutadapt::createConfFile ###
my %optionsRef = ("-q" => "20","-O" => "10","-m" => "35");                                          # Ref for hash containing informations to put into the configuration file
my $optionref = \%optionsRef;
is ((cutadapt::createConfFile($fileAdaptator, $fileConf, $optionref)),0, 'cutadapt::createConfFile');
########################################


### Test of cutadapt::exec ###
is ((cutadapt::execution($fileIn, $fileConf, $fileOut)),0, 'cutadapt::execution');
##############################

exit;