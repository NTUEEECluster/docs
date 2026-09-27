#!/bin/bash
# TUTORIAL ONLY - not for production use. See README.md.
# Step 4: generate an image from a text prompt on one pro6000 GPU.
#SBATCH -J flux2
#SBATCH --gres=gpu:pro6000:1
#SBATCH -t 30
#SBATCH -o flux2-%j.log

P=/projects/YOUR_PROJECT       # your SSD project directory
[ -d "$P" ] || { echo "Edit P: $P does not exist"; exit 1; }
D=$P/flux2
OUT=$D/out/$SLURM_JOB_ID
PROMPT='A photo of a red fox sitting in a snowy pine forest at sunrise, next to a wooden sign that says "HELLO FROM THE CLUSTER"'

mkdir -p $D/home $OUT

srun --container-image=$D/pytorch-26.08-py3.sqsh \
     --container-mounts=$D/home:$HOME,$P:$P \
     --container-workdir=$OUT \
     --export=ALL,HF_HOME=$P/hf,HF_HUB_OFFLINE=1,PYTHONUSERBASE=$D/pyuser \
     python $D/generate.py $OUT/flux2.png "$PROMPT" < /dev/null
