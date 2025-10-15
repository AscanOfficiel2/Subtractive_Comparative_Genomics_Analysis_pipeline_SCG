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
diamond_path=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared
DrugBank_database=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/DrugBank
sh_path=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Pan_proteome_scripts

# Change directory to the location of the FASTA file
cd $bacteria_path/DrugBank


# Running Diamond for Druggability Assesesement
# ----------------------------------------------------------------------------------------------------------------------
# Bacterial proteins
#$diamond_path/diamond blastp --threads 56 --sensitive --header --max-target-seqs 1 --evalue 1e-05 --outfmt 6 -d $DrugBank_database/DrugBank_database -q matched_extracted_sequences.fasta -o Drugbank_diamond_output.csv
$diamond_path/diamond blastp --threads 56 --sensitive --header --max-target-seqs 1 --evalue 1e-05 --outfmt 6 -d $DrugBank_database/DrugBank_database -q sequences_all_overlaps.fasta -o Drugbank_all_overlaps_diamond_output1.csv

sed -i 's/|/\t/g' Drugbank_diamond_output1.csv
#awk -F "\t" '{print $3}' Drugbank_diamond_output1.csv > diamond_Drgbank.ID1.csv
#grep -f diamond_Drgbank.ID.csv $DrugBank_database/drugbank vocabulary.csv > DrugBank_diamond.grep
#perl $sh_path/get_Prokka_proteins_02_1.pl Drugbank_diamond_output.csv DrugBank_diamond.grep > DrugBank_diamond_semi_final.csv
#awk -v ids=$id '{print 'ids'"\t"$0}' DrugBank_diamond_semi_final.csv > Drugbank.diamond.final.csv

