# WGS-FP
Whole Genome Sequencing File Processing
# Genomic Analysis Pipeline

## Overview

This bash script implements an end-to-end genomic analysis pipeline designed to run on a local server. It performs a series of steps from quality control of raw sequencing data to variant calling, utilizing various bioinformatics tools.

## Requirements

The following tools must be installed and available in your system PATH:

- fastp
- bwa
- samtools
- gatk
- deepvariant

## Usage

1. Edit the script to set the following variables:
   - `INPUT_R1`: Path to input FASTQ file for read 1
   - `INPUT_R2`: Path to input FASTQ file for read 2
   - `REFERENCE_GENOME`: Path to reference genome FASTA file
   - `KNOWN_SITES`: Path to known sites VCF file
   - `OUTPUT_DIR`: Path to output directory
   - `THREADS`: Number of threads to use (adjust based on your server's capabilities)

2. Make the script executable:
   ```
   chmod +x genomic_analysis_pipeline.sh
   ```

3. Run the script:
   ```
   ./genomic_analysis_pipeline.sh
   ```

## Pipeline Steps

1. **Quality Control and Trimming**: Uses fastp to perform quality control and trimming on input FASTQ files.
2. **Alignment to Reference Genome**: Aligns trimmed reads to the reference genome using BWA-MEM.
3. **Sorting and Indexing BAM Files**: Sorts and indexes the aligned reads using samtools.
4. **Marking Duplicates**: Marks duplicate reads in the BAM file.
5. **Base Quality Score Recalibration (BQSR)**: Performs base quality score recalibration using GATK.
6. **Variant Calling**: Calls variants using DeepVariant.

## Output

The script generates several output files in the specified output directory, including:

- Trimmed FASTQ files
- Aligned, sorted, and indexed BAM files
- Recalibrated BAM file
- VCF and gVCF files containing called variants

## Error Handling

The script will exit immediately if any command fails, helping to catch errors early in the pipeline.

## Customization

You can customize the pipeline by modifying the parameters passed to each tool. Refer to the documentation of individual tools for more information on available options.

## Notes

- This pipeline is designed for whole genome sequencing (WGS) data.
- Ensure you have sufficient disk space in the output directory.
- The pipeline may take several hours to complete, depending on the size of your input data and the computational resources available.

## Troubleshooting

If you encounter any issues:

1. Check that all required tools are properly installed and in your PATH.
2. Verify that input files exist and are readable.
3. Ensure you have write permissions in the output directory.
4. Check the server logs for any error messages.

For further assistance, please contact your system administrator or bioinformatics support team.
