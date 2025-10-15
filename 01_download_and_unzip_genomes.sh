#!/bin/sh
## Last check: 17-07-2024 by Suleiman_Aminu & AbdulAziz_Ascandari

#SBATCH --nodes=1                 # Number of whole nodes allocated
#SBATCH --ntasks=56               # Total number of (MPI) tasks (<= nodes*56)
#SBATCH --time=35:00:00           # Wallclock time required
#SBATCH --partition=compute       # Partition name
#SBATCH --output=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Bacteria_panproteome/out/slurm-%j.out  # Output directory
#SBATCH --error=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Bacteria_panproteome/err/slurm-%j.err   # Error directory

eval "$(conda shell.bash hook)"

##################################################################################################
# Specify all necessary paths for the project

# Create a name for the project as $1. This allows selection of a specific project for the script.
project=$1

# Path to the URL file: This file contains the URLs for downloading from NCBI
url_file=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Bacteria_panproteome/$project/url

# Path to save the downloaded files
output_dir=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Bacteria_panproteome/$project/

# Sh_pATH
sh_path=/srv/lustre01/project/mmrd-cp3fk69sfrq/shared/Pan_proteome_scripts

##################################################################################################
# Downloading Documents

# Read the URL file and download each file
while IFS=, read -r url; do
    echo "Downloading $url..."
    wget -P "$output_dir" "$url"
    if [ $? -eq 0 ]; then
        echo "Successfully downloaded $url"

        # Check if the downloaded file is a gzip file (.gz) and unzip it
        if [[ "$url" == *.gz ]]; then
            echo "Unzipping $url..."
            gzip -d "$output_dir/$(basename "$url")"
            if [ $? -eq 0 ]; then
                echo "Successfully unzipped $url"
            else
                echo "Failed to unzip $url"
            fi
        fi
        
    else
        echo "Failed to download $url"
    fi
done < "$url_file"

##################################################################################################
