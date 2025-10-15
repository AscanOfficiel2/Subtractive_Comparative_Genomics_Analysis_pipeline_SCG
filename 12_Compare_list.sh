#!/bin/bash
## Last check: 22-07-2024 by Suleiman_Aminu & AbdulAziz_Ascandari
## Purpose: Compares species lists from two files and outputs species not found in both.

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
bacteria_path="/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Bacteria_panproteome/$project"
sh_path="/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Pan_proteome_scripts"

# ----------------------------------------------------------------------------------------------------------------------
# Move to the directory containing the diamond results
# ----------------------------------------------------------------------------------------------------------------------
cd "$bacteria_path/diamond_result" || { echo "Failed to change directory to $bacteria_path/diamond_result"; exit 1; }

# ----------------------------------------------------------------------------------------------------------------------
# Define the input and output files
# ----------------------------------------------------------------------------------------------------------------------

# Getting the list of Bacteria from bacteria.diamond.final.csv and final_merged_results.txt
awk -F "\t" '{print $2}' "$bacteria_path/diamond_result/bacteria.diamond.final.csv" > "$bacteria_path/diamond_result/Bacteria_List_Final.csv"
awk -F "\t" '{print $1}' "$bacteria_path/diamond_result/final_merged_results.txt" > "$bacteria_path/diamond_result/Bacteria_final_merged_results.txt"

#Defining the input files
list1="Bacteria_List_Final.csv"
list2="Bacteria_final_merged_results.txt"
output="List_Non_match.csv"

# Check if files exist
if [ ! -f "$list1" ]; then
    echo "File $list1 does not exist."
    exit 1
fi

if [ ! -f "$list2" ]; then
    echo "File $list2 does not exist."
    exit 1
fi

# Extract species names from both files
# Assuming species names are in the first column of both files
awk -F, '{print $1}' "$list1" | sort | uniq > list1_species.txt
awk -F, '{print $1}' "$list2" | sort | uniq > list2_species.txt

# Find species in list1 that are not in list2
comm -23 <(sort list1_species.txt) <(sort list2_species.txt) > list1_only.txt

# Find species in list2 that are not in list1
comm -13 <(sort list1_species.txt) <(sort list2_species.txt) > list2_only.txt

# Combine the results and remove duplicates
cat list1_only.txt list2_only.txt | sort | uniq > "$output"

# Clean up temporary files
rm list1_species.txt list2_species.txt list1_only.txt list2_only.txt



# File paths
list1="List_Non_match.csv"
list2="bacteria.diamond.final.csv"
output="Matched2.csv"

# Extract species names from list1.csv (assuming they're in the first column)
cut -f1 -d' ' "$list1" | sort | uniq > list1_species.txt

# Extract species names from list2.csv (assuming they're in the first column)
cut -f1 -d' ' "$list2" | sort | uniq > list2_species.txt

# Find species in list2 that are also in list1
grep -F -f list1_species.txt "$list2" > "$output"

# Clean up
rm list1_species.txt list2_species.txt

echo "Matching species written to $output"
