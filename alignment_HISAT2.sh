#!/usr/bin/bash
# Copy Tcongo genome into current working dir, and unzip to get .fasta file
rm -rf Tcongo_genome
echo "Getting Tcongo genome..."
cp -r /localdisk/data/BPSM/MyFirstPipeline/Tcongo_genome .
FQ_1=./raw_data/fq_1_trimmed
FQ_2=./raw_data/fq_2_trimmed
gzip -d ./Tcongo_genome/*Tcongolense*.fasta.gz
echo "Tcongo genome obtained"
# Performing sequence alignment using HISAT2 for trimmed paired-end data (./raw_data/fq_1_trimmed/*_1_trimmed.fq and ./raw_data/fq_2_trimmed/*_2_trimmed.fq)
# using reference Tcongo genome, piping output to samtools for formatting .bam files
# Before alignment, have to build Tcongolense_index with HISAT2 using *Tcongolense*.fasta
# Input: Reference *Tcongolense*.fasta, paired-end data (./raw_data/fq_1_trimmed/*_1_trimmed.fq and ./raw_data/fq_2_trimmed/*_2_trimmed.fq)
# Output: .bam files in HISAT2_out_BAM dir
echo "Performing alignment with HISAT2..."
hisat2-build ./Tcongo_genome/*Tcongolense*.fasta ./Tcongo_genome/Tcongolense_index
gene=./Tcongo_genome/Tcongolense_index
out_dir=./HISAT2_out_BAM
rm -rf ${out_dir}
mkdir -p ${out_dir}
for file in ${FQ_1}/*_1_trimmed.fq; do
  base=$(basename "${file}" "_1_trimmed.fq")
  mate1=${file}
  mate2=$(find ${FQ_2} -type f -name "${base}_2_trimmed.fq" -print -quit)
  if [[ -n ${mate2} ]]; then
    echo "Aligning ${mate1} and ${mate2} pair..."
    hisat2 -q -x ${gene} -1 ${mate1} -2 ${mate2} --quiet | samtools view -bSh > "${out_dir}/${base}.bam"
  else
    echo "Aligning ${mate1} unpaired..."
    hisat2 -q -x ${gene} -U ${mate1} --quiet | samtools view -bSh > "${out_dir}/${base}.bam"
  fi
done
echo "Alignment done!" 
