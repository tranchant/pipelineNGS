cd /teams/ggr/pipelineNGS/DATA/RC2/2_CUTADAPT
cutadapt $(<cutadapt.conf ) ../0_PAIRING_FILES/RC2_1.fastq -o RC2_1.CUTADAPT.fastq
cutadapt $(<cutadapt.conf ) ../0_PAIRING_FILES/RC2_2.fastq -o RC2_2.CUTADAPT.fastq
