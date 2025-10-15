
# Module: Bacterial Pan-Proteome Construction and Functional Screening

## Objective
This module builds and analyzes a bacterial **pan-proteome** from genome assemblies. It automates genome retrieval, annotation, clustering, essential gene prediction, and screening for antimicrobial resistance (ARGs), virulence factors (VFs), and host homology. The goal is to derive high-confidence candidate proteins with potential roles in human disease or therapeutic relevance.

## General Workflow
The pipeline comprises 12 scripts executed sequentially under SLURM, using Conda-managed environments.

Execution pattern:
```bash
bash 01_download_and_unzip_genomes.sh ProjectA
bash 02_DrugBank.sh ProjectA
...
bash 12_species_comparison.sh ProjectA
```

Each step documents inputs, outputs, and rationale below.

---

## 01_download_and_unzip_genomes.sh
**Purpose:** Download bacterial genomes from NCBI and unzip them into project-specific folders.  
**Rationale:** Establishes the raw genome dataset for downstream annotation and clustering.  
**Inputs:**
- `url/` — text file containing genome download links per species.  
**Outputs:**
- Decompressed FASTA genomes in `$project/`.

---

## 02_DrugBank.sh
**Purpose:** Perform BLASTP alignment against the **DrugBank** protein database to evaluate druggability of bacterial proteins.  
**Rationale:** Identifies bacterial proteins with structural similarity to known drug targets.  
**Inputs:**
- `sequences_all_overlaps.fasta` (from clustering step).  
**Outputs:**
- `Drugbank_all_overlaps_diamond_output1.csv` — significant BLAST hits.  
**Core tool:** `diamond blastp`.

---

## 03_find_essential_genes.sh
**Purpose:** Identify essential genes across bacterial genomes using the **DEG database** and extract matching protein sequences.  
**Rationale:** Essential genes represent potential targets conserved for viability and are key to identifying core proteome members.  
**Inputs:**
- `target.csv`, `deg_annotation_p.csv`.  
**Outputs:**
- `essential.csv` — essential gene matches.  
- `matched_extracted_sequences.fasta` — FASTA subset for ARG/VF screening.  
**Optional extensions:** Performs VFDB and CARD (ARG) screening using `diamond blastp`.

---

## 04_extract_CDHIT.sh
**Purpose:** Extract multi-species clusters from **CD-HIT** outputs and identify non-redundant protein clusters.  
**Rationale:** CD-HIT reduces sequence redundancy to define unique gene clusters across isolates.  
**Inputs:**
- `combined_cdhit.clstr`.  
**Outputs:**
- `non_redundant_clusters.txt`, `extracted_seq.txt`.  
**Outcome:** Defines the structural backbone of the bacterial pan-proteome.

---

## 05_Protein_Clustering_Diamond.sh
**Purpose:** Annotate genomes, combine protein FASTAs, cluster proteins, and align them against reference proteomes.  
**Rationale:** Central integration step linking structural annotation (Prokka) and similarity searches (Diamond).  
**Inputs:**
- Prokka-generated `.faa` protein files per genome.  
**Outputs:**
- `combined.faa`, `bacteria_diamond_output.csv`, `human_diamond_output.csv`.  
**Key functions:**
- Genome annotation → Protein clustering → Dual-species (bacterial/human) BLAST alignment.

---

## 06_remove_good.sh
**Purpose:** Filter clusters to remove sequences belonging to “good” bacteria, retaining only clusters from potentially pathogenic species.  
**Rationale:** Focuses analysis on bacteria with possible disease relevance or treatment resistance.  
**Inputs:**
- `non_redundant_clusters.txt`.  
**Outputs:**
- `Unique_clusters.txt`, `extracted_seq.txt`.  
**Outcome:** A refined, pathogenic-specific proteome subset.

---

## 07_match_seq.sh
**Purpose:** Match filtered bacterial names with corresponding sequences in FASTA files.  
**Rationale:** Ensures only relevant species’ sequences are retained for subsequent functional analysis.  
**Inputs:**
- `Extracted_seq.txt` and `combined_cdhit`.  
**Outputs:**
- `matched_sequences.fasta` — curated FASTA for downstream essential gene and ARG/VF screening.

---

## 08_vfdb_arg_merging.sh
**Purpose:** Merge **VFDB** and **CARD** results by accession IDs to map virulence and resistance determinants to species.  
**Rationale:** Integrates functional evidence across independent annotation databases.  
**Inputs:**
- `ARG_diamond.grep`, `ids_vfdb`, and accession lists.  
**Outputs:**
- `matched_vfdb`, `matched_arg`.  
**Outcome:** Unified ARG–VF profile per bacterial species.

---

## 09_Merging_files_Bacteria_human.sh
**Purpose:** Merge Diamond outputs of bacterial vs. human proteomes to identify cross-species homologs.  
**Rationale:** Detects possible molecular mimicry or horizontal gene transfer signals.  
**Inputs:**
- `human_diamond_output.csv`, `bacteria.diamond.final.csv`.  
**Outputs:**
- `final_merged_results.txt` — combined bacterial-human hit table.

---

## 10_PanGP.sh
**Purpose:** Convert CD-HIT cluster files into **PanGP**-compatible format and generate binary (0/1) gene presence–absence matrix.  
**Rationale:** Enables visualization and modeling of pangenome openness, core genome fraction, and accessory gene distribution.  
**Inputs:**
- `combined_cdhit.clstr`.  
**Outputs:**
- `PanGP_matrix.txt` — binary matrix for PanGP input.

---

## 11_protein_properties.sh
**Purpose:** Compute physicochemical properties of clustered proteins (length, MW, pI, hydrophobicity, instability).  
**Rationale:** Characterizes biochemical diversity across the pan-proteome and supports functional annotation.  
**Inputs:**
- `matched_extracted_sequences.fasta`.  
**Outputs:**
- `protein_properties.csv`.

---

## 12_species_comparison.sh
**Purpose:** Compare species lists between Diamond outputs and merged results to identify overlapping and unique taxa.  
**Rationale:** Evaluates coverage completeness and detects missed species in cross-database integration.  
**Inputs:**
- `bacteria.diamond.final.csv`, `final_merged_results.txt`.  
**Outputs:**
- `List_Non_match.csv`, `Matched2.csv`.

---

## Summary Table
| Step | Main Function | Input | Output | Purpose Summary |
|------|----------------|--------|---------|-----------------|
| 01 | Genome download | URL list | FASTA genomes | Data acquisition |
| 02 | Drug target mapping | FASTA | Diamond hits | DrugBank screening |
| 03 | Essential gene search | DEG files | Essential genes | Viability core detection |
| 04 | Cluster extraction | CD-HIT clusters | Non-redundant set | Proteome definition |
| 05 | Genome annotation & alignment | FASTA | Diamond outputs | Core annotation step |
| 06 | Pathogen filtering | Clusters | Unique clusters | Remove benign taxa |
| 07 | Sequence matching | Species list | Matched FASTA | Clean subset for screening |
| 08 | ARG/VF merging | VFDB & CARD hits | Matched tables | Integrate resistance & virulence |
| 09 | Cross-species merging | Diamond results | Combined table | Identify host mimicry |
| 10 | PanGP formatting | Cluster file | Binary matrix | Pangenome modeling |
| 11 | Protein properties | FASTA | CSV table | Physicochemical annotation |
| 12 | Species comparison | Species lists | Non-match + match CSV | Final consistency check |

---

## Dependencies
- **Core tools:** Prokka, CD-HIT, Diamond, Python 3.10+, Biopython, Pandas
- **Environment:** Conda with required packages per step
- **Scheduler:** SLURM with ≥56 cores recommended

---

## License
This repository is released under the **MIT License**:

---

## Citation
> Ascandar, A.& Aminu, S.  (2025). *Bacterial Pan-Proteome Analysis Pipeline: Genome-to-Function Integration.* Mohammed VI Polytechnic University.


