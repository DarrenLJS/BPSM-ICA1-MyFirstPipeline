#!/usr/bin/bash
# Run FASTQC on raw .fq.gz files, extracting and deleting any zipped file
# Input: Raw .fq.gz files from raw_dir
# Output: Unzipped fastqc folders containing all QC data of each sample, including .html file, in ./QC_data dir
raw_dir=/localdisk/data/BPSM/MyFirstPipeline/fastq
QC_dir=./QC_data
rm -rf ${QC_dir}
mkdir -p ${QC_dir}
echo "Performing FASTQC..."
for file in ${raw_dir}/*.fq.gz; do
  base=$(basename "${file}")
  echo "${base}"
  fastqc ${file} -o ${QC_dir} -t 4 -q --extract --delete
done
echo "Done FASTQC!"
# Copy raw data files into ./raw_data/fq_1 and ./raw_data/fq_2 dirs, and unzip
# Input: Raw .fq.gz files from raw_dir
# Output: Raw .fq files, separating the paired-end data *_1.fq and *_2.fq into ./raw_data/fq_1 and ./raw_data/fq_2 dirs respectively
raw_files=./raw_data
FQ_1=./raw_data/fq_1
FQ_2=./raw_data/fq_2
rm -rf ${raw_files}
mkdir -p ${raw_files} ${FQ_1} ${FQ_2}
echo "Copying raw files..."
for file in ${raw_dir}/*; do
  if [[ ${file} == *_1.fq.gz ]]; then
    cp ${file} ${FQ_1}
  elif [[ ${file} == *_2.fq.gz ]]; then
    cp ${file} ${FQ_2}
  fi
done
echo "Copied raw files!"
echo "Unzipping..."
for file in ${FQ_1}/*.fq.gz; do
  gzip -d ${file}
done
for file in ${FQ_2}/*.fq.gz; do
  gzip -d ${file}
done
echo "Unzipped raw files!"
