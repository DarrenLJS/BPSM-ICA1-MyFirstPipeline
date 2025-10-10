#!/usr/bin/bash
# Iterate through each dir in bed_out_counts_clean, use awk to merge the samples and calculate the mean count for each gene for each group (3/4 replicates)
# Input: ./counts_data/bed_out_counts_clean/* dirs
# Output: ./meancount_per_gene/*.txt files
in_dir=./counts_data/bed_out_counts_clean
out_dir=./meancount_per_gene
rm -rf ${out_dir}
mkdir -p ${out_dir}
echo "Calculating mean per gene..."
for dir in ${in_dir}/*; do
  base=$(basename "${dir}")
  awk 'BEGIN {FS="\t"; OFS="\t"} {
    geneid=$2
    counts[geneid]+=$4
    n[geneid]++
    gene[geneid]=$1
    description[geneid]=$3
  }
  END {
    print "GeneName", "GeneID", "Description", "MeanCount"
    for (i in counts) {
      print gene[i], i, description[i], counts[i]/n[i]
    }
  }
  ' ${dir}/*_counts.txt | sort -k1,1 -k2,2 > "${out_dir}/${base}.txt"
done
echo "Mean count per gene calculated!"
