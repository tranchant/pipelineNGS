package bwa;

use strict;
use warnings;
use lib qw(.);
use localConfig;
use toolbox;
use Data::Dumper;
################################### coucou ^^
##############################################
##BWA
##Module containing BWA functions
##############################################
## Beurk!!!!!!!
##
##BWA INDEX
#Index database sequences in the FASTA format.
sub bwaIndex{
    my($refFastaFileIn,$optionsHachees)=@_;
    if (toolbox::sizeFile($refFastaFileIn)==1){     ##Check if the reference file exist and is not empty
        my $options=toolbox::extractOptions($optionsHachees, " "); ##Get given options
        my $command=$bwa." index ".$options." ".$refFastaFileIn; ##command
        #Execute command
        if(toolbox::run($command)==1){  ##The command should be executed correctly (ie return) before exporting the log
            toolbox::exportLog("bwaIndex done correctly \n",1);
            return 1;
        }else{
                toolbox::exportLog("bwaIndex failed! Check your parameters and line aboves \n",0);
                return 0;
            }
    }else{
        toolbox::exportLog("bwaIndex failed! Check your parameters and line aboves \n",0);
        return 0;
    }
}

##
##
##BWA ALN
#Find the SA coordinates of the input reads.
sub bwaAln{
    my($refFastaFileIn,$FastqFileIn,$saiFileOut,$optionsHachees)=@_;
    if ((toolbox::sizeFile($refFastaFileIn)==1) and (toolbox::sizeFile($FastqFileIn)==1)) {     ##Check if entry files exist and are not empty
        $saiFileOut=toolbox::extractName($FastqFileIn).".sai" unless $saiFileOut;      ##Name the output
        my $options="";
        if ($optionsHachees) {
            $options=toolbox::extractOptions($optionsHachees);##Get given options
        }
        my $command=$bwa." aln ".$options." -f ".$saiFileOut." ".$refFastaFileIn." ".$FastqFileIn;
        #Execute command
        if(toolbox::run($command)==1){ ## if the command has been excuted correctly, export the log
        toolbox::exportLog("bwaAln done correctly \n",1);
        return 1;
        }else{
            toolbox::exportLog("bwaAln failed! Check your parameters and line aboves \n",0);
            return 0;     
        }
    }else{
        toolbox::exportLog("bwaAln failed! Check your parameters and line aboves \n",0);
        return 0;     
    }
}
##
##
##BWA SAMPE
#Generate alignments in the SAM format given paired-end reads. Repetitive read pairs will be placed randomly. 
####TO DO: Do we suppose that the file have  convention names????
####if yes (ie forwardfile=name_1.fq,reversefile=name_2.fq), we give an generated name (ex:name.sam?) to the samFileOut
sub bwaSampe{
    my($samFileOut,$refFastaFileIn,$forwardSaiFileIn,$reverseSaiFileIn,$forwardFastqFileIn,$reverseFastqFileIn,$readGroupLine,$optionsHachees)=@_;
    if ((toolbox::sizeFile($refFastaFileIn)==1) and (toolbox::sizeFile($forwardSaiFileIn)==1) and (toolbox::sizeFile($forwardFastqFileIn)==1) and (toolbox::sizeFile($reverseFastqFileIn)==1)){     ##Check if entry files exist and are not empty
        my $options="";
        if ($optionsHachees) {
            $options=toolbox::extractOptions($optionsHachees);##Get given options
        }
        
        $readGroupLine="" unless $readGroupLine;
         
        $samFileOut=toolbox::extractName($forwardFastqFileIn).".sam" unless $samFileOut;
        my $command=$bwa." sampe ".$options." -f ".$samFileOut."  -r '\@RG\\tID:".$readGroupLine."\\tSM:".$readGroupLine."\\tPL:Illumina' ".$refFastaFileIn." ".$forwardSaiFileIn." ".$reverseSaiFileIn." ".$forwardFastqFileIn." ".$reverseFastqFileIn;
        #Execute command
        if(toolbox::run($command)==1){ ## if the command has been excuted correctly, export the log
        toolbox::exportLog("bwaSampe done correctly \n",1);
        return 1;
        }else{
            toolbox::exportLog("bwaSampe failed! Check your parameters and lines above \n",0);
            return 0;
        }
    }else{
        toolbox::exportLog("bwaSampe failed! Check your parameters and lines above \n",0);
        return 0;
        
    }
}
##
##
##BWA SAMSE
#Generate alignments in the SAM format given single-end reads. Repetitive hits will be randomly chosen.
sub bwaSamse{
    my($samFileOut,$refFastaFileIn,$saiFileIn,$fastqFileIn,$readGroupLine,$optionsHachees)=@_;
    if ((toolbox::sizeFile($refFastaFileIn)==1) and (toolbox::sizeFile($saiFileIn)==1)and (toolbox::sizeFile($fastqFileIn)==1)){     ##Check if entry files exist and are not empty
        #Name the output
        $samFileOut=toolbox::extractName($fastqFileIn).".sam" unless $samFileOut;
        my $options="";
        if ($optionsHachees) {
            my $options=toolbox::extractOptions($optionsHachees);##Get given options
        }
        
        $readGroupLine="" unless $readGroupLine;
        
        my $command=$bwa." samse ".$options." -f ".$samFileOut." -r '\@RG\\tID:".$readGroupLine."\\tSM:".$readGroupLine."\\tPL:Illumina' ".$refFastaFileIn." ".$saiFileIn." ".$fastqFileIn;
        #Execute command
        if(toolbox::run($command)==1){        ## if the command has been excuted correctly, export the log
        toolbox::exportLog("bwaSamse done correctly \n",1);
        return 1;
        }else{
            toolbox::exportLog("bwaSamse failed! Check your parameters and lines above \n",0);
            return 0;
        }
    }else{
        toolbox::exportLog("bwaSamse failed! Check your parameters and lines above \n",0);
        return 0;
    }
}
1;

=head1 NOM

package I<bwa> 

=head1 SYNOPSIS

    

=head1 DESCRIPTION

Module bwa
BWA is a software package for mapping low-divergent sequences against a large reference genome, such as the human genome.





=head2 Fonctions

=over 4

=item bwaIndex()

=item bwaAln()

=item bwaSampe()

=item bwaSamse()

=back

=head1 AUTEUR

Ayité KOUGBEADJO, UMR DIADE

L<http://bioinfo.mpl.ird.fr/>

=head1 VOIR AUSSI

blablabla

=cut

#L<mon autre documentation |doc>

#L<Retour en haut de page |/"NOM">