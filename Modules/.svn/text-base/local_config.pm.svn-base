package localConfig;

use strict;
use warnings;
use Exporter;

our @ISA=qw(Exporter);
our @EXPORT=qw($bwa $picard $samtools $GATK $cuffdir $pacBioToCA $cutadapt $fastqc $java);


#PATH for Mapping on cluster
our $java ="/usr/local/java/latest/bin/java -Xmx12g -jar";
our $bwa = "/usr/local/bwa-0.6.2/bwa";
our $picard = "/usr/local/java/latest/bin/java -Xmx8g  -jar /home/sabotf/sources/picard-tools";
our $samtools = "/usr/local/samtools-0.1.18/samtools-0.1.18/samtools";
our $GATK = "$java /home/sabotf/sources/GenomeAnalysisTK/GenomeAnalysisTK.jar";
our $fastqc = "/usr/local/FastQC/fastqc";


#PATH for Cufflinks bin on cluster
our $cuffdir = "/usr/local/cufflinks-2.0.2.Linux_x86_64";

#Path for pacBioToCa
our $pacBioToCA = "/home/sabotf/sources/wgs/Linux-amd64/bin/pacBioToCA";

#Path for CutAdapt
our $cutadapt = "/usr/local/cutadapt-1.2.1/bin/cutadapt";

1;