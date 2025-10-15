#!/bin/bash
## last check 27-06-2024 by Suleiman_Aminu&AbdulAziz_Ascandari
#! How many whole nodes should be allocated?
#SBATCH --nodes=1
#! How many (MPI) tasks will there be in total? (<= nodes*56)
#SBATCH --ntasks=56
#--exclusive
#! How much wallclock time will be required?
#SBATCH --time=35:00:00
#SBATCH --partition=compute
#SBATCH --output=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/out/slurm-%j.out
#SBATCH --error=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/err/slurm-%j.err2

eval "$(conda shell.bash hook)"
###################################################################################################
project=$1
bacteria_path=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Bacteria_panproteome/$project
sh_path=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Pan_proteome_scripts
##############################################################################
# Define input and output files
species_list="$bacteria_path/CdHit_result/Extracted_seq.txt"
fasta_file="$bacteria_path/CdHit_result/combined_cdhit"
output_file="$bacteria_path/CdHit_result/matched_sequences.fasta"

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$output_file")"

# Read species names into an array
mapfile -t species_names < "$species_list"

# Initialize variables
current_header=""
current_sequence=""

# Function to process each line of the FASTA file
process_fasta_line() {
    local line="$1"

    if [[ $line =~ ^\> ]]; then
        # Process previous sequence if header matched any species name
        if [[ -n $current_header ]]; then
            for name in "${species_names[@]}"; do
                if [[ $current_header == *"$name"* ]]; then
                    echo ">$current_header" >> "$output_file"
                    echo "$current_sequence" >> "$output_file"
                    break
                fi
            done
        fi
        # Reset variables for new header
        current_header="${line:1}"  # Remove '>'
        current_sequence=""
    else
        # Append sequence lines
        current_sequence+="$line"
    fi
}

# Read and process each line of the FASTA file
while IFS= read -r line; do
    process_fasta_line "$line"
done < "$fasta_file"

# Process the last sequence entry
if [[ -n $current_header ]]; then
    for name in "${species_names[@]}"; do
        if [[ $current_header == *"$name"* ]]; then
            echo ">$current_header" >> "$output_file"
            echo "$current_sequence" >> "$output_file"
            break
        fi
    done
fi

echo "Sequences have been successfully extracted to $output_file."
