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
## Licencied under CeCill-C (http://www.cecill.info/licences/Licence_CeCILL-C_V1-en.html) and GPLv3 #
## Intellectual property belongs to IRD, CIRAD and SouthGreen developpement plateform #
## Written by Cécile Monat, Ayite Kougbeadjo, Mawusse Agbessi, Christine Tranchant, Marilyne Summo, Cédric Farcy, François Sabot 

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
sub tophat{}




