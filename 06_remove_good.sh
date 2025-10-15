#!/bin/bash
## Last check: 17-07-2024 by Suleiman_Aminu & AbdulAziz_Ascandari
## Purpose: This script reads through protein clusters and filters out the clusters of interest without any contaminant or sequence we are not interested in.

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
###########################################################################################################

input_file="$bacteria_path/CdHit_result/non_redundant_clusters.txt"
output_file="$bacteria_path/CdHit_result/Unique_clusters.txt"     ##### This is cluster without good bacteria
output_file1="$bacteria_path/CdHit_result/extracted_seq.txt"  ##### This is the bacteria IDs/names for fetching their sequences

# Initialize variables
write_cluster=false
cluster_data=""

# Read the input file line by line
while IFS= read -r line; do
    # Check if the line starts a new cluster
    if [[ $line == \>Cluster* ]]; then
        # If the previous cluster should be written, append it to the output file
        if $write_cluster && [ -n "$cluster_data" ]; then
            echo "$cluster_data" >> "$output_file"
        fi
        
        # Reset variables for the new cluster
        write_cluster=true
        cluster_data="$line"$'\n'
    else
        # Check if the line contains the word "good"
        if [[ $line =~ [Gg]ood ]]; then
            write_cluster=false
        fi
        # Append the line to the current cluster data
        cluster_data+="$line"$'\n'
    fi
done < "$input_file"

# Write the last cluster if it should be written
if $write_cluster && [ -n "$cluster_data" ]; then
    echo "$cluster_data" >> "$output_file"
fi



# Extract lines containing specific "name" attached to it (see the non-redundant file to see the name to grep) into the output file
grep "Bacteria_panproteome CD-hit_installation_README" "$output_file" > "$output_file1"

echo "Extraction complete. Clusters without 'good' species are saved in $output_file."