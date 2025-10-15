#!/bin/bash
## Last check: 22-07-2024 by Suleiman_Aminu & AbdulAziz_Ascandari
## Purpose: Compares gene names from target.csv with detailed info from deg_annotation_p.csv and updates target.csv.

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
diamond_path=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared
swiss_prot_bacteria=/srv/lustre01/project/mmrd-cp3fk69sfrq/morad.mokhtar/Shotgun-metagenomics/Swiss-Prot_bacteria
swiss_Human_proteome=/srv/lustre01/project/mmrd-cp3fk69sfrq/morad.mokhtar/Shotgun-metagenomics/Swiss-Human_proteome
UniProtKB_all_bacteria_proteines=/srv/lustre01/project/mmrd-cp3fk69sfrq/morad.mokhtar/UniProtKB_all_bacteria_proteines
VFDB_diamond_database=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/VFDB
ARG_diamond_database=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/ARGS_CARD

cd "$bacteria_path/Essential_proteins" || { echo "Failed to change directory to $bacteria_path/Essential_proteins"; exit 1; }

# Input files
gene_list="target.csv"
detailed_info="deg_annotation_p.csv" #downloaded from the DEG website on 22nd July,2024 FROM http://origin.tubic.org/deg/public/index.php/download#
output_file="essential.csv"

# Ensure the output file is empty or create it if it doesn't exist
#> $output_file

# Process the gene list, read each line, and extract the fourth column
#while IFS=',' read -r col1 col2 col3 col4 col5; do
    # Search for the gene in the detailed info file (case-insensitive)
   # if grep -qi -F "\"${col4}\"" $detailed_info; then
   #     echo "${col1},${col2},${col3},${col4},${col5},Match_found" >> $output_file
    #else
      #  echo "${col1},${col2},${col3},${col4},${col5},Not_found" >> $output_file
    #fi
#done < $gene_list



# After running the script, export the essential.csv to local computer and filter out the rows corresponding to Not_found. After that rename the file as essential_filtered and import into the HPC.

#Extracting the species name from the essential_filtered file

#cut -d',' -f1 "$bacteria_path/Essential_proteins/essential_filtered.csv" > "$bacteria_path/Essential_proteins/extracted_essential_bacteria.csv"

# Define input and output files
species_list="$bacteria_path/Essential_proteins/extracted_essential_bacteria.csv"
fasta_file="$bacteria_path/CdHit_result/matched_sequences.fasta"
output_file="$bacteria_path/Essential_proteins/matched_extracted_sequences.fasta"

# Create output directory if it doesn't exist
#mkdir -p "$(dirname "$output_file")"

# Read species names into an array
#mapfile -t species_names < "$species_list"

# Initialize variables
#current_header=""
#current_sequence=""

# Function to process each line of the FASTA file
#process_fasta_line() {
   # local line="$1"

   # if [[ $line =~ ^\> ]]; then
        # Process previous sequence if header matched any species name
      #  if [[ -n $current_header ]]; then
           # for name in "${species_names[@]}"; do
             #   if [[ $current_header == *"$name"* ]]; then
                  #  echo ">$current_header" >> "$output_file"
                  #  echo "$current_sequence" >> "$output_file"
                   # break
               # fi
            # done
        #fi
        # Reset variables for new header
        #current_header="${line:1}"  # Remove '>'
        #current_sequence=""
   # else
        # Append sequence lines
       # current_sequence+="$line"
    #fi
#}

# Read and process each line of the FASTA file
#while IFS= read -r line; do
   # process_fasta_line "$line"
#done < "$fasta_file"

# Process the last sequence entry
#if [[ -n $current_header ]]; then
   # for name in "${species_names[@]}"; do
    #    if [[ $current_header == *"$name"* ]]; then
        #    echo ">$current_header" >> "$output_file"
          #  echo "$current_sequence" >> "$output_file"
          #  break
        #fi
    #done
#fi


 #VFDB Annotation from VFDB DATABASE (We build the database on 22nd july 2024)from http://www.mgc.ac.cn/VFs/main.html 
#$diamond_path/diamond blastp --threads 56 --sensitive --header --max-target-seqs 1 --evalue 1e-05 --outfmt 6 -d $VFDB_diamond_database/VFDB_diamond_database -q $bacteria_path/Essential_proteins/matched_extracted_sequences.fasta -o $bacteria_path/Essential_proteins/VFDB_output.csv

# Finding their matches in Bacteria vfdb
#sed -i 's/|/\t/g' $bacteria_path/Essential_proteins/VFDB_output.csv #  Optional

# Extract the Fasta header information for the VFDB_output generated above from the VFDB_setB_pro.fas file and store as output_file2
 #grep ">" "$VFDB_diamond_database/VFDB_setB_pro.fas" > "$bacteria_path/Essential_proteins/output_file2"
 #sed 's/>//g' $bacteria_path/Essential_proteins/output_file2 > $bacteria_path/Essential_proteins/ids_vfdb



#ARG Annotation from CARD DATABASE (We build the database on 23nd july 2024)from https://card.mcmaster.ca/download 
#$diamond_path/diamond blastp --threads 56 --sensitive --header --max-target-seqs 1 --evalue 1e-05 --outfmt 6 -d $ARG_diamond_database/ARG_diamond_database -q $bacteria_path/Essential_proteins/matched_extracted_sequences.fasta -o $bacteria_path/Essential_proteins/ARG_output.csv


# Finding their matches in Bacteria ARG
#sed -i 's/|/\t/g' $bacteria_path/Essential_proteins/ARG_output.csv
#awk -F "\t" '{print $3}' $bacteria_path/Essential_proteins/ARG_output.csv > $bacteria_path/Essential_proteins/ARG_diamond_swiss_prot_bacteria.protein.csv
#grep -f $bacteria_path/Essential_proteins/ARG_diamond_swiss_prot_bacteria.protein.csv $ARG_diamond_database/aro_index.tsv > $bacteria_path/Essential_proteins/ARG_diamond.grep

#################################Continue work in vfdb_arg_merging script!!########################################

echo "Matching genes have been written to $output_file"