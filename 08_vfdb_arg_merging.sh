#!/bin/bash
## Last check: 22-07-2024 by Suleiman_Aminu & AbdulAziz_Ascandari
## Purpose: Compares IDs from accession_numbers.txt with lines in ids_vfdb and writes matching lines to matched_vfdb.

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
###############################Take the VFDB_output.csv file into local PC and get only the "VFG" ids and bring it baclk to put it in the accession_numbers.txt file before beginning!!!################################

# Specify all necessary paths for the project
project=$1
bacteria_path="/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Bacteria_panproteome/$project"
sh_path=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Pan_proteome_scripts

cd "$bacteria_path/Essential_proteins" || { echo "Failed to change directory to $bacteria_path/Essential_proteins"; exit 1; }

# Check if the necessary files exist
#if [[ ! -f accession_numbers_vf.txt || ! -f ids_vfdb ]]; then
    #echo "One or both input files do not exist."
    #exit 1
#fi

# Create or empty the matched_vfdb file
#> matched_vfdb

# Read each ID from accession_numbers.txt
#while IFS= read -r id; do
    #id=$(echo "$id" | xargs)  # Trim any leading/trailing whitespace
    #if [[ -z "$id" ]]; #then
        #continue
    #fi
    # Append all lines from ids_vfdb that contain the ID
    #grep -F "$id" ids_vfdb >> matched_vfdb
#done < accession_numbers_vf.txt

#echo "Matching lines have been written to matched_vfdb."

############For the ARG, take the ARG_output.csv file into local PC and get only the "ARO" ids and bring it baclk to put it in the accession_numbers.txt file before beginning!!! ###################################################################


# Check if the necessary files exist
if [[ ! -f accession_numbers_arg.txt || ! -f ARG_diamond.grep ]]; then
    echo "One or both input files do not exist."
    exit 1
fi

# Create or empty the matched_arg file
> matched_arg

# Read each ID from accession_numbers_arg.txt
while IFS= read -r id; do
    id=$(echo "$id" | xargs)  # Trim any leading/trailing whitespace
    if [[ -z "$id" ]]; then
        continue
    fi
    # Append all lines from ARG_diamond.grep that contain the ID
    grep -F "$id" ARG_diamond.grep >> matched_arg
done < accession_numbers_arg.txt

echo "Matching lines have been written to matched_arg."


##Take the matched_ files and the VFDB,ARG_output file and manually join them together based on the accession IDs. Do this on the local PC by sorting by ascending or descending (do same for both files so that they match in order) and adding the matched-vfdb content to the VFDB_output file and verify to see if they match