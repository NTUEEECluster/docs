#!/bin/bash
# TUTORIAL ONLY - not for production use. See README.md.
# Step 2: download the model (CPU job, about 10 min for 31 GB).
#SBATCH -J vllm-download
#SBATCH -c 8
#SBATCH -t 1:00:00
#SBATCH -o vllm-download-%j.log

P=/projects/YOUR_PROJECT       # your SSD project directory
[ -d "$P" ] || { echo "Edit P: $P does not exist"; exit 1; }
D=$P/vllm
MODEL=Qwen/Qwen3.8-27B-FP8

srun --container-image=$D/vllm-26.08-py3.sqsh \
     --container-mounts=$P:$P \
     --export=ALL,HF_HOME=$P/hf \
     hf download $MODEL < /dev/null
