#!/bin/bash
## Last check: 17-07-2024 by Suleiman_Aminu & AbdulAziz_Ascandari
## Purpose: The script performs bioinformatics analysis on bacterial genomes, running Prokka for genome annotation, clustering protein sequences with CD-HIT, and conducting BLAST searches using Diamond against bacterial and human proteomes to identify proteins of interest.

#SBATCH --nodes=1
#SBATCH --ntasks=56
#SBATCH --time=35:00:00
#SBATCH --partition=compute
#SBATCH --output=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/out/slurm-%j.out
#SBATCH --error=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/err/slurm-%j.err

# Load Conda environment
eval "$(conda shell.bash hook)"
conda activate your_environment_name  # Replace with your actual Conda environment name

# ----------------------------------------------------------------------------------------------------------------------
# Project Setup
# ----------------------------------------------------------------------------------------------------------------------

# Specify all necessary paths for the project
project=$1
bacteria_path=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Bacteria_panproteome/$project
sh_path=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Pan_proteome_scripts

# Change directory to the location of the FASTA file
cd $bacteria_path/CdHit_result || { echo "Failed to change directory to $bacteria_path/CdHit_result"; exit 1; }

# Run the Python code
python3 - <<EOF
import pandas as pd

# Define file paths
input_file = "combined_cdhit.clstr"
converted_clusters_file = "PanGP_converted_clusters.txt"
formatted_clusters_file = "PanGP_formatted_clusters.txt"
output_matrix_file = "PanGP_matrix.txt"

# Step 1: Convert the cluster file to a simple format
with open(input_file, 'r') as infile, open(converted_clusters_file, 'w') as outfile:
    current_cluster = None
    for line in infile:
        line = line.strip()
        if line.startswith('>Cluster'):
            # Write the cluster header to the output file
            current_cluster = line
            outfile.write(f"{current_cluster}\n")
        elif line:
            # Write sequence information to the output file
            outfile.write(f"{line}\n")

print(f"Conversion complete. Data saved to: {converted_clusters_file}")

# Step 2: Format the converted clusters for PanGP
# Initialize variables
clusters = {}
header = set()

# Read and process the converted cluster file
with open(converted_clusters_file, 'r') as infile:
    current_cluster = None
    for line in infile:
        line = line.strip()
        if line.startswith('>Cluster'):
            # New cluster detected
            current_cluster = line
            clusters[current_cluster] = {}
        elif line:
            # Debug information to inspect problematic lines
            print(f"Processing line: {line}")

            # Attempt to split the line and handle different cases
            strain_info = line.split('\t')
            if len(strain_info) < 2:
                print(f"Warning: Line format is too short (skipping): {line}")
                continue

            # Further debugging to handle different formats
            strain_parts = strain_info[0].split('...')
            if len(strain_parts) < 1:
                print(f"Warning: Unable to split strain info (skipping): {line}")
                continue
            
            strain_name = strain_parts[0].strip()
            header.add(strain_name)
            clusters[current_cluster][strain_name] = strain_info[0]

# Create header line
header = sorted(header)
header_line = '\t'.join(['Cluster'] + header) + '\n'

# Write to the formatted output file
with open(formatted_clusters_file, 'w') as outfile:
    outfile.write(header_line)
    for cluster_id, strains in clusters.items():
        line = [cluster_id] + [strains.get(h, '-') for h in header]
        outfile.write('\t'.join(line) + '\n')

print(f"Formatting complete. Data saved to: {formatted_clusters_file}")

# Step 3: Convert the formatted clusters to a 0/1 matrix
clusters_df = pd.read_csv(formatted_clusters_file, sep='\t')

# Convert the dataframe to a 0/1 matrix
# Replace all '-' with 0 and anything else with 1
matrix_df = clusters_df.set_index('Cluster').replace('-', 0).applymap(lambda x: 1 if x != 0 else 0)

# Save the 0/1 matrix to a file
matrix_df.to_csv(output_matrix_file, sep='\t', header=False, index=False)
print(f"Matrix conversion complete. Data saved to: {output_matrix_file}")

EOF
