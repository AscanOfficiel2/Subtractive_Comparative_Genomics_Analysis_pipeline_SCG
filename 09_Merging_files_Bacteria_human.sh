#!/bin/bash
## Last check: 17-07-2024 by Suleiman_Aminu & AbdulAziz_Ascandari
## Purpose: The script performs bioinformatics analysis on bacterial genomes, running Prokka for genome annotation, clustering protein sequences with CD-HIT, and conducting BLAST searches using Diamond against bacterial and human proteomes to identify proteins of interest.

#SBATCH --nodes=1
#SBATCH --ntasks=56
#SBATCH --time=35:00:00
#SBATCH --partition=compute
#SBATCH --output=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/out/slurm-%j.out
#SBATCH --error=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/err/slurm-%j.err

eval "$(conda shell.bash hook)"
# ----------------------------------------------------------------------------------------------------------------------
# Project Setup
# ----------------------------------------------------------------------------------------------------------------------

# Specify all necessary paths for the project
project=$1
bacteria_path=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Bacteria_panproteome/$project
sh_path=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Pan_proteome_scripts

#----------------------------------------------------------------------------------------------------------------------
cd $bacteria_path/diamond_result
#----------------------------------------------------------------------------------------------------------------------

# Define input files
txt_file="human_diamond_output.csv"
tsv_file="bacteria.diamond.final.csv"

# Define output file
output_file="$bacteria_path/diamond_result/final_merged_results.txt" #This is to find the homology or the matching between the bacteria and the human proteins

# Check if output file exists and remove it
if [ -f "$output_file" ]; then
    rm "$output_file"
fi

# Read each line from txt_file and match with tsv_file based on species name
while IFS=$'\t' read -r species_name rest_of_line; do
    # Search for species_name in txt_file
    matched_line=$(grep -m 1 "^${species_name}" "$txt_file")
    
    # Combine the matched lines and output to the final_merged_results.txt
    if [ -n "$matched_line" ]; then
        echo -e "${matched_line}\t${rest_of_line}" >> "$output_file"
    fi
done < "$tsv_file"

echo "Merging complete. Output written to $output_file"