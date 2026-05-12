# Dorado HAC Basecalling and DeepMod2 Methylation Calling Pipeline

Pipeline for Oxford Nanopore HAC basecalling, move table generation, and methylation calling using DeepMod2.

---

# Overview

This workflow performs Oxford Nanopore sequencing analysis using two sequential pipelines:

* HAC basecalling and move table generation using Dorado
* Methylation calling using DeepMod2

The workflow converts raw `.pod5` nanopore signal files into methylation-tagged BAM files containing 5mC and 5hmC predictions.

Unlike native Dorado modified-base calling, this workflow uses Dorado only for:

* basecalling
* alignment
* move table generation

The actual methylation inference is performed by DeepMod2.

Workflow sequence:

```text id="jlwmxk"
Dorado HAC basecalling
            ↓
Move-table BAM generation
            ↓
DeepMod2 methylation calling
            ↓
Methylation-tagged BAM outputs
```

The workflow consists of two sequential scripts:

| Step | Script                              | Purpose                                 |
| ---- | ----------------------------------- | --------------------------------------- |
| 1    | `run_dorado_batch_hac_bases.sh`     | HAC basecalling + move table generation |
| 2    | `run_deepmod2_methylation_batch.sh` | DeepMod2 methylation calling            |

`run_dorado_batch_hac_bases.sh` generates move-table enabled BAM files required for DeepMod2 methylation calling, while `run_deepmod2_methylation_batch.sh` performs 5mC and 5hmC prediction using DeepMod2.

---

# Repository Structure

```text id="jlwm4z"
dorado-hac-deepmod2-pipeline/
│
├── README.md
│
├── run_dorado_batch_hac_bases.sh
│
├── run_deepmod2_methylation_batch.sh
│
├── reference.fasta
│
├── reference.fasta.fai
│
└── .gitignore
```

---

# Required Input Files

The workflow requires:

* `.pod5` files
* Reference FASTA
* FASTA index (`.fai`)
* Dorado HAC BAMs generated in Step 1

Example:

```text id="jlwm2s"
project/
├── pod5_files/
│   ├── sample1.pod5
│   └── sample2.pod5
├── reference.fasta
├── reference.fasta.fai
├── DeepMod2/
├── run_dorado_batch_hac_bases.sh
└── run_deepmod2_methylation_batch.sh
```

---

# Software Requirements

| Software                      | Purpose                  |
| ----------------------------- | ------------------------ |
| Dorado (v1.3.1 or compatible) | HAC basecalling          |
| DeepMod2                      | Methylation calling      |
| Samtools                      | BAM sorting and indexing |
| Python pod5 package           | POD5 metadata inspection |

---

# HAC Model Used

## Dorado HAC Model

```text id="jlwmkg"
dna_r10.4.1_e8.2_400bps_hac@v5.2.0
```

---

# DeepMod2 Model Used

## DeepMod2 Methylation Model

```text id="jlwmq1"
bilstm_r10.4.1_5khz_v5.0
```

This model detects:

* 5mC
* 5hmC

---

# Workflow

# Step 1 — HAC Basecalling and Move Table Generation

Edit the following variables inside:

```text id="jlwm7h"
run_dorado_batch_hac_bases.sh
```

Set:

```bash id="jlwm8i"
POD5_DIR=
OUTPUT_DIR=
REFERENCE=
```

Run:

```bash id="jlwm5f"
chmod +x run_dorado_batch_hac_bases.sh

bash run_dorado_batch_hac_bases.sh
```

Expected outputs:

```text id="jlwm5r"
dorado_hac_only_base_movefiles/
├── sample_sorted.bam
└── sample_sorted.bam.bai
```

---

# Step 2 — DeepMod2 Methylation Calling

Edit the following variables inside:

```text id="jlwmdb"
run_deepmod2_methylation_batch.sh
```

Set:

```bash id="jlwmn5"
POD5_DIR=
OUTPUT_DIR=
REFERENCE=
BAM_DIR=
```

Run:

```bash id="jlwmq2"
chmod +x run_deepmod2_methylation_batch.sh

bash run_deepmod2_methylation_batch.sh
```

Expected outputs:

```text id="jlwm7f"
deepmod2_5mC_5hmC_outputs/

sample/
├── output.bam
├── sample_mod_sorted.bam
└── sample_mod_sorted.bam.bai
```

Generated BAM files contain:

* methylation predictions
* MM tags
* ML tags
* aligned reads
* sorted/indexed methylation BAMs

---

# Verifying Outputs

List generated files:

```bash id="jlwm0z"
ls -lh dorado_hac_only_base_movefiles/

ls -lh deepmod2_5mC_5hmC_outputs/
```

Check BAM statistics:

```bash id="jlwm7l"
samtools flagstat sample_mod_sorted.bam
```

Inspect BAM tags:

```bash id="jlwm7s"
samtools view sample_mod_sorted.bam | head
```

Successful methylation calling should produce:

```text id="jlwm2d"
MM:Z:
ML:B:C
```
---

# Full Documentation

Detailed workflow documentation is available here:

[Google Docs Documentation](https://docs.google.com/document/d/1Wj-gkxO755uF2FdEJx0VJSViN6hjUYA6_AcrjSxTIXk/edit?tab=t.sir5tnriuba7)
