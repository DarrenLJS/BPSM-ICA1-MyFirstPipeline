#!/usr/bin/bash
# Pipeline for running all the shell scripts sequentially
find . -type f -name "*.sh" -exec sed -i 's/\r$//' {} \;
./QC_FAST.sh && \
  ./QC_trimming_bbduk.sh && \
  ./alignment_HISAT2.sh && \
  ./countreads_bedtools.sh && \
  ./groupings.sh && \
  ./meancount_per_gene.sh
