#!/usr/bin/perl

use strict;
use warnings;

use lib qw (../Modules/);
use pairing;

chdir '~/DATA/RC2/3_PAIRING_SEQUENCES' or die "Impossible to chdir";
my $reverse='~/DATA/RC2/2_CUTADAPT/RC2_1.CUTADAPT.fastq';
my $forward='~/DATA/RC2/2_CUTADAPT/RC2_2.CUTADAPT.fastq';
pairing::repairing($reverse,$forward);