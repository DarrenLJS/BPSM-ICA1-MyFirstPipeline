#!/usr/bin/bash
# Copy Tcongolense bedfile to current working dir
# Before counting with bedtools, make sure to sort Tcongolense bedfile by gene name and 0-base start position (to lighten the workload for bedtools) 
rm -f *Tcongolense*.bed
echo "Getting Tcongolense bedfile..."
cp /localdisk/data/BPSM/MyFirstPipeline/*Tcongolense*.bed .
echo "Sorting Tcongolense bedfile..."
basebed=$(basename ./*Tcongolense*.bed ".bed")
bed=./${basebed}.bed
sort -k1,1 -k2,2n ${bed} > ./${basebed}_sorted.bed
echo "Sorted Tcongolense bedfile obtained!"
# Using bedtools coverage to count reads overlapping each gene in Tcongolense genome.
# Using awk to only print useful cols (gene, geneid, description, counts)
# Input: .bam files from HISAT2_out_BAM dir
# Output: Raw *_bedout.txt count files in bed_out_counts dir, and cleaned *_counts.txt files in bed_out_counts_clean dir
echo "Generating counts data..."
rm -rf bed_out_counts bed_out_counts_clean
mkdir -p bed_out_counts bed_out_counts_clean
in_dir=./HISAT2_out_BAM
out_dir=./bed_out_counts
counts_dir=./bed_out_counts_clean
bed=./${basebed}_sorted.bed
for bam in ${in_dir}/*.bam; do
  base=$(basename "${bam}" ".bam")
  echo "Counting reads for ${base}..."
  bedtools coverage -a ${bed} -b ${bam} -counts > "${out_dir}/${base}_bedout.txt"
  awk 'BEGIN {FS="\t"; OFS="\t";} {print $1, $4, $5, $NF}' "${out_dir}/${base}_bedout.txt" > "${counts_dir}/${base}_counts.txt"
done
echo "Counts data generated!"
