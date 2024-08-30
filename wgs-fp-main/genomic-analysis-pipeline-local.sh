#!/bin/bash

# End-to-End Genomic Analysis Pipeline Script
# This script runs a complete genomic analysis pipeline on a local server.

# Exit immediately if a command exits with a non-zero status
set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required tools
for tool in fastp bwa samtools gatk deepvariant; do
    if ! command_exists $tool; then
        echo "Error: $tool is not installed or not in the PATH" >&2
        exit 1
    fi
done

# Set variables
INPUT_R1="path/to/input_R1.fastq.gz"
INPUT_R2="path/to/input_R2.fastq.gz"
REFERENCE_GENOME="path/to/reference_genome.fa"
KNOWN_SITES="path/to/known_sites.vcf"
OUTPUT_DIR="path/to/output_directory"
THREADS=16  # Adjust based on your server's capabilities

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Starting Genomic Analysis Pipeline"

# Step 1: Quality Control and Trimming with fastp
echo "Step 1: Quality Control and Trimming"
fastp -i "$INPUT_R1" -I "$INPUT_R2" \
      -o "$OUTPUT_DIR/trimmed_R1.fastq.gz" -O "$OUTPUT_DIR/trimmed_R2.fastq.gz" \
      --qualified_quality_phred 20 \
      --unqualified_percent_limit 30 \
      --n_base_limit 5 \
      --length_required 30 \
      -h "$OUTPUT_DIR/fastp_report.html" -j "$OUTPUT_DIR/fastp_report.json"

# Step 2: Alignment to Reference Genome with BWA-MEM
echo "Step 2: Alignment to Reference Genome"
bwa mem -t "$THREADS" "$REFERENCE_GENOME" \
    "$OUTPUT_DIR/trimmed_R1.fastq.gz" "$OUTPUT_DIR/trimmed_R2.fastq.gz" | \
    samtools view -Sb -o "$OUTPUT_DIR/aligned_reads.bam"

# Step 3: Sorting and Indexing BAM Files
echo "Step 3: Sorting and Indexing BAM Files"
samtools sort -@ "$THREADS" -o "$OUTPUT_DIR/sorted_reads.bam" "$OUTPUT_DIR/aligned_reads.bam"
samtools index "$OUTPUT_DIR/sorted_reads.bam"

# Step 4: Marking Duplicates
echo "Step 4: Marking Duplicates"
samtools markdup -@ "$THREADS" "$OUTPUT_DIR/sorted_reads.bam" "$OUTPUT_DIR/marked_duplicates.bam"
samtools index "$OUTPUT_DIR/marked_duplicates.bam"

# Step 5: Base Quality Score Recalibration (BQSR)
echo "Step 5: Base Quality Score Recalibration"
gatk BaseRecalibrator \
    -I "$OUTPUT_DIR/marked_duplicates.bam" \
    -R "$REFERENCE_GENOME" \
    --known-sites "$KNOWN_SITES" \
    -O "$OUTPUT_DIR/recal_data.table"

gatk ApplyBQSR \
    -R "$REFERENCE_GENOME" \
    -I "$OUTPUT_DIR/marked_duplicates.bam" \
    --bqsr-recal-file "$OUTPUT_DIR/recal_data.table" \
    -O "$OUTPUT_DIR/recalibrated.bam"

# Step 6: Variant Calling with DeepVariant
echo "Step 6: Variant Calling"
deepvariant \
    --model_type=WGS \
    --ref="$REFERENCE_GENOME" \
    --reads="$OUTPUT_DIR/recalibrated.bam" \
    --output_vcf="$OUTPUT_DIR/output.vcf.gz" \
    --output_gvcf="$OUTPUT_DIR/output.g.vcf.gz" \
    --num_shards="$THREADS"

echo "Genomic Analysis Pipeline Completed"
echo "Output files are located in $OUTPUT_DIR"
