#!/bin/bash
# TUTORIAL ONLY - not for production use. See README.md.
# Step 2: import the Isaac Sim image once (CPU job, about 5-15 min).
#SBATCH -J isaac-import
#SBATCH -c 16
#SBATCH -t 90
#SBATCH -o isaac-import-%j.log

P=/projects/YOUR_PROJECT       # your SSD project directory
[ -d "$P" ] || { echo "Edit P: $P does not exist"; exit 1; }
D=$P/isaac-sim
TAG=6.1.0

export ENROOT_TEMP_PATH=$P/.tmp/$SLURM_JOB_ID ENROOT_CACHE_PATH=$P/.enroot-cache
mkdir -p $ENROOT_TEMP_PATH $ENROOT_CACHE_PATH $D
trap 'rm -rf $ENROOT_TEMP_PATH' EXIT

cd $D
enroot import -o isaac-sim-$TAG.sqsh.part "docker://nvcr.io#nvidia/isaac-sim:$TAG"
mv isaac-sim-$TAG.sqsh.part isaac-sim-$TAG.sqsh
ls -lh $D/isaac-sim-$TAG.sqsh
