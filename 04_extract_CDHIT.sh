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
#SBATCH --output=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/err/out/slurm-%j.out2
#SBATCH --error=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/err/slurm-%j.err2

eval "$(conda shell.bash hook)"
###################################################################################################
# Specify all necessary paths for the project
project=$1
bacteria_path=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Bacteria_panproteome/$project
sh_path=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Pan_proteome_scripts

##################################################################################################
# Path to the .clstr file
clstr_file="$bacteria_path/CdHit_result/combined_cdhit.clstr"
# Output file to store clusters with more than one species
output_file1="$bacteria_path/CdHit_result/non_redundant_clusters.txt"
output_file2="$bacteria_path/CdHit_result/extracted_seq.txt"

# Initialize variables
output=""

# Function to process and output clusters with more than one species
process_cluster() {
    if [ ${#species_list[@]} -gt 1 ]; then
        output+="${cluster_info}\n"  # Output original cluster information
        for (( i=0; i<${#species_list[@]}; i++ )); do
            species_line="${species_list[$i]}"
            if [[ $species_line == *' '* ]]; then
                species=$(echo "$species_line" | cut -d' ' -f1)
                percent_info=$(echo "$species_line" | cut -d' ' -f2-)
                output+="Species: ${species} ${percent_info}\n"
            else
                output+="Species: ${species_line}\n"
            fi
        done
        output+="\n"
    fi
}

# Read the .clstr file line by line
while IFS= read -r line; do
    if [[ $line == \>*Cluster* ]]; then
        # Process the previous cluster
        process_cluster
        # Reset for the new cluster
        cluster_info="$line"  # Store original cluster information
        species_list=()
    else
        # Extract species information from the sequence line
        species=$(echo $line | grep -o ">.*..." | sed 's/>//;s/\.\.\.//')
        species_list+=("$species")
    fi
done < "$clstr_file"

# Process the last cluster
process_cluster

# Write the output to the file
echo -e "$output" > "$output_file1"


# Extract lines containing specific "name" attached to it (see the non-redundant file to see the name to grep) into the output file
grep "Bacteria_panproteome CD-hit_installation_README" "$output_file1" > "$output_file2"

#Now take the extracted_seq.txt file into your local PC or copy its content and find and replace the names attached to your bacteria of interest. Now copy and paste it back to the file and we are done.

echo "Extraction completed. Results saved in: $output_file2"