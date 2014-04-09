#!/usr/bin/perl -w
#Will test if picardsTools module work correctly works correctly
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
use_ok('picardTools') or exit;
can_ok( 'samTools','samToolsIndex');
can_ok( 'samTools','samToolsView');
use toolbox;
use picardTools;
