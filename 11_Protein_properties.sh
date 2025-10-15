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

# ----------------------------------------------------------------------------------------------------------------------
# Project Setup
# ----------------------------------------------------------------------------------------------------------------------

# Specify all necessary paths for the project
project=$1
bacteria_path=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Bacteria_panproteome/$project
sh_path=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Pan_proteome_scripts

# Change directory to the location of the FASTA file
cd $bacteria_path/Essential_proteins

# Run the Python code
python3 - <<EOF
from Bio import SeqIO
from Bio.SeqUtils.ProtParam import ProteinAnalysis
import csv

# Define file paths
input_fasta = "matched_extracted_sequences.fasta"  # Adjust this path to your FASTA file
output_csv = "protein_properties.csv"  # Path to save the output CSV file

# Read sequences from FASTA file
sequences = []
for record in SeqIO.parse(input_fasta, "fasta"):
    seq_id = record.id
    seq = str(record.seq)
    sequences.append((seq_id, seq))

# Calculate properties and write to CSV
with open(output_csv, mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["ID", "Length", "Molecular Weight", "Isoelectric Point", "Aromaticity", "Instability Index", "Hydrophobicity (GRAVY)"])
    
    for seq_id, seq in sequences:
        analysed_seq = ProteinAnalysis(seq)
        length = len(seq)
        mw = analysed_seq.molecular_weight()
        pi = analysed_seq.isoelectric_point()
        aromaticity = analysed_seq.aromaticity()
        instability_index = analysed_seq.instability_index()
        hydrophobicity = analysed_seq.gravy()
        
        writer.writerow([seq_id, length, mw, pi, aromaticity, instability_index, hydrophobicity])

print("Protein properties calculated and saved to", output_csv)
EOF
