#!/bin/bash
# TUTORIAL ONLY - not for production use. See README.md.
# Step 3: install diffusers and download FLUX.2-dev (CPU job, about 20-60 min).
#SBATCH -J flux2-setup
#SBATCH -c 16
#SBATCH -t 3:00:00
#SBATCH -o flux2-setup-%j.log

P=/projects/YOUR_PROJECT       # your SSD project directory
[ -d "$P" ] || { echo "Edit P: $P does not exist"; exit 1; }
D=$P/flux2

srun --container-image=$D/pytorch-26.08-py3.sqsh \
     --container-mounts=$P:$P \
     --export=ALL,HF_HOME=$P/hf,PYTHONUSERBASE=$D/pyuser,PIP_CACHE_DIR=$P/.tmp/pip \
     bash -c '
       set -e
       pip install --user --quiet diffusers transformers accelerate huggingface_hub
       export PATH=$PYTHONUSERBASE/bin:$PATH
       python -c "import diffusers, transformers; print(\"diffusers\", diffusers.__version__, \"transformers\", transformers.__version__)"
       # Diffusers-format weights only (about 113 GB); skip the duplicate single-file checkpoint.
       hf download black-forest-labs/FLUX.2-dev --exclude "flux2-dev.safetensors" --exclude "ae.safetensors" --exclude "*.png"
     ' < /dev/null
