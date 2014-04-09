cd /teams/ggr/pipelineNGS/DATA/2_CUTADAPT
cutadapt $(<cutadapt.conf ) ../0_PAIRING_FILES/RC1_1.fastq -o RC1_1.CUTADAPT.fastq
cutadapt $(<cutadapt.conf ) ../0_PAIRING_FILES/RC1_2.fastq -o RC1_2.CUTADAPT.fastq
