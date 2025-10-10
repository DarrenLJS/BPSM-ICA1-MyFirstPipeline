# Using bbduk sequence trimming script, to trim right and left, and trim bases with less than 10 Phred quality score
# Input: .fq files in ./raw_data/fq_1 and ./raw_data/fq_2 dirs
# Output: Trimmed .fq files in ./raw_data/fq_1_trimmed and ./raw_data/fq_2_trimmed dir
in_1=./raw_data/fq_1
in_2=./raw_data/fq_2
out_1=./raw_data/fq_1_trimmed
out_2=./raw_data/fq_2_trimmed
rm -rf ${out_1} ${out_2}
mkdir -p ${out_1} ${out_2}
echo "Initiating bbduk.sh trimming process..."
for file in ${in_1}/*_1.fq; do
  base=$(basename "${file}" "_1.fq")
  read1="${in_1}/${base}_1.fq"
  read2="${in_2}/${base}_2.fq"
  if [[ -f ${read2} ]]; then
    echo "Trimming ${read1} and ${read2} pair..."
    bbduk.sh in=${read1} in2=${read2} out="${out_1}/${base}_1_trimmed.fq" out2="${out_2}/${base}_2_trimmed.fq" qtrim=rl trimq=10
  else
    echo "Trimming ${read1} unpaired..."
    bbduk.sh in=${read1} out="${out_1}/${base}_1_trimmed.fq" qtrim=rl trimq=10
  fi
done
echo "Trimming done!"
