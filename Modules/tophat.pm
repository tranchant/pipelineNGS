package tophat;

use strict;
use warnings;
use lib qw(.);
use localConfig;
use toolbox;
use Data::Dumper;
###################################
##############################################
##TOPHAT
##Module containing TOPHAT functions
##############################################
##
####Create Index
sub indexRef
    {
    my ($FastaRef) = @_;
    my $prefixRef;
        if ($FastaRef  =~ /^(.*)\.fa/)
            { $prefixRef=$1;
            }
        
    my $command= "$bowtieIndex   -f $FastaRef  $prefixRef ";
      
        toolbox::run($command);

        
      
    }
    

####Run Tophat




