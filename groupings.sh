#!/usr/bin/bash
# Necessary to group count files by SampleType (Clone1, Clone2, WT), Time (0, 24, 48), and Treatment (Induced, Uninduced)
# First, copy raw Tco2.fqfiles to groupings dir
# Next, separate rows by SampleType (Clone1, Clone2, WT), appending to respective clone1.txt, clone2.txt, and wt.txt files
rm -rf groupings
mkdir -p groupings
cp /localdisk/data/BPSM/MyFirstPipeline/fastq/Tco2.fqfiles ./groupings
while read -r wholeline; do
  if [[ "${wholeline:0:6}" != "Sample" ]]; then
    read -r Name Type Rep Time Treatment End1 End2 <<< ${wholeline}
    case ${Type} in
      Clone1)
        echo -e "${wholeline}" >> ./groupings/clone1.txt
        ;;
      Clone2)
        echo -e "${wholeline}" >> ./groupings/clone2.txt
        ;;
      WT)
        echo -e "${wholeline}" >> ./groupings/wt.txt
    esac
  fi
done < ./groupings/Tco2.fqfiles
echo "Clone1, Clone2, WT grouped"
# Finally, for each SampleType, separate rows by Time (0, 24, 48) and Treatment (Induced, Uninduced)
# Change SampleName to include "-" for easier organisation of count files
# Output: For each SampleType (Clone1, Clone2, WT), Uninduced at 0h, Induced at 24h, Uninduced at 24h, Induced at 48h, and Uninduced ay 48h groups. Total = 15 groups
for file in ./groupings/*.txt; do
  while read -r Name Type Rep Time Treatment End1 End2; do
    Name="${Name/Tco/Tco-}"
    wholeline=$(echo -e "${Name}\t${Type}\t${Rep}\t${Time}\t${Treatment}\t${End1}\t${End2}")
    base=$(basename "${file}" ".txt")
    if (( Time == 0 )); then
      echo -e "${wholeline}" >> ./groupings/${base}_0.txt
    elif (( Time == 24 )); then
      if [[ "${Treatment}" == "Induced" ]]; then
        echo -e "${wholeline}" >> ./groupings/${base}_24_induced.txt
      else
        echo -e "${wholeline}" >> ./groupings/${base}_24_uninduced.txt
      fi
    else
      if [[ "${Treatment}" == "Induced" ]]; then
        echo -e "${wholeline}" >> ./groupings/${base}_48_induced.txt
      else
        echo -e "${wholeline}" >> ./groupings/${base}_48_uninduced.txt
      fi
    fi
  done < ${file}
done
rm -f ./groupings/clone1.txt ./groupings/clone2.txt ./groupings/wt.txt
echo "Grouping lists done!"
# Using group_name.txt files, move *_count.txt files in ./counts_data/bed_out_counts_clean dir to respective group_name dirs within the same parent dir
# Input: ./groupings/group_name.txt files, and ./counts_data/bed_out_counts_clean/*_counts.txt files
# Output: ./counts_data/bed_out_counts_clean/* dirs, containing organised *_counts.txt files
echo "Organising counts files..."
counts_dir=./counts_data/bed_out_counts_clean
for group in ./groupings/*.txt; do
  group_name=$(basename "${group}" ".txt")
  dest_dir="${counts_dir}/${group_name}"
  mkdir -p "${dest_dir}"
  while read -r Name Type Rep Time Treatment End1 End2; do
    counts_file="${counts_dir}/${Name}_counts.txt"
    if [[ -f "${counts_file}" ]]; then
      mv ${counts_file} ${dest_dir}/
    fi
  done < ${group}
done
echo "Organised counts files!"
