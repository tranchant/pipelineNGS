#!/usr/bin/perl

use strict;
use warnings;

use lib qw (../Modules/);
use pairing;

chdir '/teams/ggr/pipelineNGS/DATA/3_PAIRING_SEQUENCES' or die "Impossible to chdir";
my $reverse='/teams/ggr/pipelineNGS/DATA/2_CUTADAPT/RC1_1.CUTADAPT.fastq';
my $forward='/teams/ggr/pipelineNGS/DATA/2_CUTADAPT/RC1_2.CUTADAPT.fastq';
pairing::repairing($reverse,$forward);