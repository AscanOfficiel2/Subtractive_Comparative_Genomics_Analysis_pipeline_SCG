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
diamond_path=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared
swiss_prot_bacteria=/srv/lustre01/project/mmrd-cp3fk69sfrq/morad.mokhtar/Shotgun-metagenomics/Swiss-Prot_bacteria
swiss_Human_proteome=/srv/lustre01/project/mmrd-cp3fk69sfrq/morad.mokhtar/Shotgun-metagenomics/Swiss-Human_proteome
UniProtKB_all_bacteria_proteines=/srv/lustre01/project/mmrd-cp3fk69sfrq/morad.mokhtar/UniProtKB_all_bacteria_proteines
VFDB_diamond_database=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/VFDB
ARG_diamond_database=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/ARGS_CARD
DrugBank_database=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/DrugBank

# Add CD-HIT to PATH
export PATH=$PATH:/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/cd-hit-v4.8.1-2019-0228/

# Create necessary directories
mkdir -p "$bacteria_path/prokka_faa"
mkdir -p "$bacteria_path/diamond_result"
mkdir -p "$bacteria_path/CdHit_result"
mkdir -p "$bacteria_path/Prokka_table"

# ----------------------------------------------------------------------------------------------------------------------
# Diamond Database Setup (Run Once)
# ----------------------------------------------------------------------------------------------------------------------
# Uncomment and run these lines only once to create Diamond databases
# $diamond_path/diamond makedb --in $swiss_prot_bacteria/uniprotkb_taxonomy_id_2_AND_reviewed_tr_2024_02_07.fasta -d $swiss_prot_bacteria/swiss_prot_bacteria --threads 56
# $diamond_path/diamond makedb --in $swiss_Human_proteome/uniprotkb_proteome_UP000005640_2024_07_03.fasta -d $swiss_Human_proteome/Swiss-Human_proteome --threads 56
# $diamond_path/diamond makedb --in $VFDB_diamond_database/VFDB_setB_pro.fas -d $VFDB_diamond_database/VFDB_diamond_database --threads 56
# $diamond_path/diamond makedb --in $ARG_diamond_database/protein_fasta_protein_homolog_knockout_overexpression_variant_models_23_7_24.fasta -d $ARG_diamond_database/ARG_diamond_database --threads 56
# $diamond_path/diamond makedb --in $DrugBank_database/protein.fasta -d $DrugBank_database/DrugBank_database --threads 56
# ----------------------------------------------------------------------------------------------------------------------
# Bioinformatics Analysis: Loop through each genome ID for Prokka Annotation
# ----------------------------------------------------------------------------------------------------------------------
for ids in $(cat $bacteria_path/Ids); do
  # Create directory for each genome ID and move the genome file into it
  mkdir -p $bacteria_path/$ids
   #cp $bacteria_path/$ids.fna $bacteria_path/$ids
  cd $bacteria_path/$ids || exit

  # Create directory for Prokka output
  prokka_path=$bacteria_path/$ids/$ids.prokka
  mkdir -p $prokka_path

  # --------------------------------------------------------------------------------------------------------------------
  # Running Prokka for Genome Annotation
  # --------------------------------------------------------------------------------------------------------------------
  # conda activate prokka
   #prokka --kingdom Bacteria --cpus 56 --force --prefix $ids --locustag $ids $bacteria_path/$ids.fna --outdir $prokka_path/"$ids"_prokka_report

  # Copy Prokka .faa files
   #cp $prokka_path/"$ids"_prokka_report/"$ids"*.faa $bacteria_path/prokka_faa
   #cp $prokka_path/"$ids"_prokka_report/"$ids"*.txt $bacteria_path/prokka_faa
   #mv $bacteria_path/prokka_faa/"$ids"*.txt $bacteria_path/Prokka_table
#--------------------------------------------------------------------------------------------------------------------
# Post-Processing and Combining Results (Prokka Table)
#----------------------------------------------------------------------------------------------------------------------
#Processing For the Tables For Prokka Result

# Initialize output file with headers
 #echo -e "GenomeName\tbases\tCDS\tcontigs\trRNA\ttmRNA\ttRNA" > "$bacteria_path/Prokka_table/Prokka_table.csv"

# Iterate over existing report files

 #for file in "$bacteria_path"/Prokka_table/*.txt; do
   #  ids=$(basename "$file" .txt)
   #  processed_file="$bacteria_path/Prokka_table/$ids.txt"

     #Remove the first line of the report file
   #  sed '1d' "$processed_file" > "$processed_file.tmp"

    # Replace ': ' with a tab
   #  sed 's/: /\t/g' "$processed_file.tmp" > "$processed_file.tmp2"

    # Cleanup temporary files
   # rm "$processed_file.tmp"

     #Read and process the processed file
   #  while IFS=$'\t' read -r key value; do
   #      key=$(echo "$key" | xargs)  # Trim leading/trailing whitespace
   #      value=$(echo "$value" | xargs)  # Trim leading/trailing whitespace

        # Assign values to corresponding variables
   #      case $key in
   #          bases) bases=$value ;;
   #          CDS) CDS=$value ;;
   #          contigs) contigs=$value ;;
   #          rRNA) rRNA=$value ;;
   #          tmRNA) tmRNA=$value ;;
   #          tRNA) tRNA=$value ;;
   #      esac
   #  done < "$processed_file.tmp2"

     #Cleanup temporary files
   #  rm "$processed_file.tmp2"

    # Append transposed data to output file
   #  echo -e "$ids\t$bases\t$CDS\t$contigs\t$rRNA\t$tmRNA\t$tRNA" >> "$bacteria_path/Prokka_table/Prokka_table.csv"
  #done
 #done
# ----------------------------------------------------------------------------------------------------------------------
##Removing the .fna (Run this after you finish your work)
#rm $bacteria_path/*.fna

# ----------------------------------------------------------------------------------------------------------------------
# Combine Prokka .faa Files
# ----------------------------------------------------------------------------------------------------------------------
 #cat $bacteria_path/prokka_faa/*.faa > $bacteria_path/prokka_faa/combined.faa

# ---------------------------------------------------------------------------------------------------------------------
# Clustering Protein Sequences with CD-HIT
# ----------------------------------------------------------------------------------------------------------------------
 #cd-hit -i $bacteria_path/prokka_faa/combined.faa -o $bacteria_path/CdHit_result/combined_cdhit -c 0.9 -n 5 -M 16000 -d 0 -T 56

# ----------------------------------------------------------------------------------------------------------------------
# Running Diamond for Protein Identification
# ----------------------------------------------------------------------------------------------------------------------
# Bacterial proteins
#$diamond_path/diamond blastp --threads 56 --sensitive --header --max-target-seqs 1 --evalue 1e-05 --outfmt 6 -d $swiss_prot_bacteria/swiss_prot_bacteria -q $bacteria_path/CdHit_result/*.fasta -o $bacteria_path/diamond_result/bacteria_diamond_output.csv

# Human proteins
#$diamond_path/diamond blastp --threads 56 --sensitive --header --max-target-seqs 1 --evalue 1e-05 --outfmt 6 -d $swiss_Human_proteome/Swiss-Human_proteome -q $bacteria_path/CdHit_result/*.fasta -o $bacteria_path/diamond_result/human_diamond_output.csv

# ----------------------------------------------------------------------------------------------------------------------
# Processing Diamond Outputs
# ----------------------------------------------------------------------------------------------------------------------
# Human proteins: This step is necessary to match our final document generated from bacteria (diamond.final_Human.csv)
#sed -i 's/|/\t/g' $bacteria_path/diamond_result/human_diamond_output.csv



# Bacterial proteins
#sed -i 's/|/\t/g' $bacteria_path/diamond_result/bacteria_diamond_output.csv
#awk -F "\t" '{print $3}' $bacteria_path/diamond_result/bacteria_diamond_output.csv > $bacteria_path/diamond_result/diamond_swiss_prot_bacteria.protein.csv
#grep -f $bacteria_path/diamond_result/diamond_swiss_prot_bacteria.protein.csv $UniProtKB_all_bacteria_proteines/UniProtKB_all_bacteria_proteines.tsv > $bacteria_path/diamond_result/bacteria_diamond.grep
#perl $sh_path/get_Prokka_proteins_02_1.pl $bacteria_path/diamond_result/bacteria_diamond_output.csv $bacteria_path/diamond_result/bacteria_diamond.grep > $bacteria_path/diamond_result/bacteria_diamond_semi_final.csv
#awk -v ids=$id '{print 'ids'"\t"$0}' $bacteria_path/diamond_result/bacteria_diamond_semi_final.csv > $bacteria_path/diamond_result/bacteria.diamond.final.csv


done
echo "Bioinformatics analysis completed."

