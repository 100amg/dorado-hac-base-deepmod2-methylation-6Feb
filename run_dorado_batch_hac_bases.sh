#!/bin/bash
set -e

POD5_DIR="/Volumes/Amishi_SSD/bio_data/6Feb/pod5_files"
OUTPUT_DIR="dorado_hac_only_base_movefiles"
REFERENCE="/Volumes/Amishi_SSD/bio_data/6Feb/dorado_outputs_corrupted_now/reference.fasta"

mkdir -p "$OUTPUT_DIR"

for pod5 in "$POD5_DIR"/*.pod5; do
    [ -e "$pod5" ] || continue
    name=$(basename "$pod5" .pod5)

    echo "Processing: $name"

    # Basecall + align → convert to BAM
    /Volumes/Amishi_SSD/bio_data/6Feb/dorado-1.3.1-osx-arm64/bin/dorado basecaller \
        dna_r10.4.1_e8.2_400bps_hac@v5.2.0 \
        "$pod5" \
        --reference "$REFERENCE" \
        --min-qscore 9 \
        --device metal \
        --emit-moves \
            | samtools sort -o "$OUTPUT_DIR/${name}_sorted.bam" 

    # Index sorted BAM
    samtools index "$OUTPUT_DIR/${name}_sorted.bam"

    echo "✓ Finished: $name"
done

echo "All files processed."