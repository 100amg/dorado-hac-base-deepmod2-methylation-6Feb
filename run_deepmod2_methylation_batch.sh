
#!/bin/bash
set -e

BAM_DIR="/Volumes/Amishi_SSD/bio_data/6Feb/dorado_hac_only_base_movefiles"
POD5_DIR="/Volumes/Amishi_SSD/bio_data/6Feb/pod5_files"
REFERENCE="/Volumes/Amishi_SSD/bio_data/6Feb/dorado_outputs_corrupted_now/reference.fasta"
OUTPUT_DIR="deepmod2_5mC_5hmC_outputs"

mkdir -p "$OUTPUT_DIR"

for bam in "$BAM_DIR"/*_sorted.bam; do
    [ -e "$bam" ] || continue

    name=$(basename "$bam" _sorted.bam)
    pod5="$POD5_DIR/${name}.pod5"

    echo "Processing: $name"

    # Create per-file output directory
    mkdir -p "$OUTPUT_DIR/$name"

    # Run DeepMod2 methylation calling
    /Volumes/Amishi_SSD/bio_data/6Feb/DeepMod2/deepmod2 detect \
        --bam "$bam" \
        --input "$POD5_DIR" \
        --file_type pod5 \
        --seq_type dna \
        --ref "$REFERENCE" \
        --model bilstm_r10.4.1_5khz_v5.0 \
        --threads 8 \
        --output "$OUTPUT_DIR/$name"

    # Sort final mod BAM (optional but recommended)
    samtools sort \
        -o "$OUTPUT_DIR/$name/${name}_mod_sorted.bam" \
        "$OUTPUT_DIR/$name/output.bam"

    samtools index "$OUTPUT_DIR/$name/${name}_mod_sorted.bam"

    echo "✓ Finished: $name"
done

echo "All files processed."