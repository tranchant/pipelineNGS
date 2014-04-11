package fastqc;
use strict;
use warnings;
use Data::Dumper;

use lib qw(.);
use localConfig;
use toolbox;


## fastqc::exec: run fastqc program
sub exec
{
	die "WARNING! fastqc::exec should get two arguments!\n" if (@_ < 2);
	my ($filein,$dirOut)=@_; #shift;
	
	toolbox::exportLog("## FASTQC EXEC STEP", 1);
	
    	my $cmd_line=$fastqc." -q --extract -o $dirOut $filein";
	toolbox::exportLog(": $cmd_line\n",1); 
	#toolbox::run($cmd_line);
	
	if (toolbox::run($cmd_line)==1) {
		return 1;
	}
	else {return 0;}
}


## fastqc::parse : parse fastqc output file and return information in hash
sub parse
{
	my ($dirOut)=@_; 	#shift;
	my (%stat); 		#Hash retourné par la fonction
	my ($fastqcFile)=$dirOut."/"."fastqc_data.txt";	## Fichier de sortie fastqc

	die "WARNING! fastqc::exec should get exactly two arguments!\n" if (@_ < 1); ## Test nombre d'arguments attendu
	toolbox::exportLog("\n## FASTQC PARSE STEP : ", 1);
	toolbox::exportLog(" : $fastqcFile\n\n", 1);
	
	toolbox::existsFile($fastqcFile);
	
	#########################################
	#Exemple d'entete du fichier a parser
	# FastQC        0.10.1
	#>>Basic Statistics      pass
	#Measure        Value   
	#Filename        sample_1.fq     
	#File type       Conventional base calls 
	#Encoding        Illumina 1.5    
	#Total Sequences 750000  
	#Filtered Sequences      0       
	#Sequence length 36      
	#%GC     43      
	#>>END_MODULE
	#########################################
	
	open(FASTQC,"<", $fastqcFile) or die "Probleme d'ouverture du fichier $fastqcFile : $! ";
	while (<FASTQC>)
	{
		#print $_;
		chomp $_;
		if (/Encoding\t(.*)\s$/) { $stat{'Encoding'}=$1; next; }
		
#		elsif (/Filename\t(.+)$/) { $file=$1; next; }
		
		elsif (/Total Sequences[^\d]+(\d+)/) { $stat{'Sequence_number'}=$1; next; }
		
		elsif (/^Sequence length\s(.*)\s/) {$stat{'Sequence_length'}=$1; next; }

		elsif (/%GC[^\d]+(\d+)/) { $stat{'GC'}=$1; next; }
		
		last if (/END_MODULE/);
	}
	
	return(\%stat); ## renvoie le hash

}

1;

=head1 NOM

package I<fastqc> 

=head1 SYNOPSIS

	use fastqc;

	fastqc::exec($fqFile,$fastqcDir);;

=head1 DESCRIPTION

Ce module regroupe un ensemble de fonctions liées au logiciel fastqc http://www.bioinformatics.babraham.ac.uk/projects/fastqc/





=head2 Fonctions

=over 4


=item exec()

Cette fonction prend en entree un fichier de sequence fastq et le repertoire de sortie dans lequel le logiciel fastqc va stocker ses fichiers de sortie.
Elle lance le programme fastqc.                
Exemple : 
C<fastqc::exec($fqFile,$fastqcDir);> 	

=item parse()

Cette fonction prend en entree le repertoire de sortie dans lequel le logiciel fastqc a stocker ses fichiers de sortie.
Elle parse le fichier texte genere par le programme fastqc pour chaque sequence fastq analysee et renvoie un hash avec les principales
informations (encoding, nombre de sequence %gc, longueur de la sequence).
Exemple : 
C<my $statRef=fastqc::parse($fasqcDirOut)> 

=back

=head1 AUTEUR

Christine Tranchant-Dubreuil, UMR DIADE

L<http://bioinfo.mpl.ird.fr/>

=head1 VOIR AUSSI

blablabla

=cut

#L<mon autre documentation |doc>

#L<Retour en haut de page |/"NOM">