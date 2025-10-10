#!/usr/bin/bash
# Iterate through each dir in bed_out_counts_clean, use awk to merge the samples and calculate the mean count for each gene for each group (3/4 replicates)
# Input: *_counts.txt files in each dir
# Output: Mean count per gene per group_name.txt in meancount_per_gene dir
rm -rf meancount_per_gene
mkdir -p meancount_per_gene
in_dir=./bed_out_counts_clean
out_dir=./meancount_per_gene
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
