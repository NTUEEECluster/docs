#!/bin/bash
# TUTORIAL ONLY - not for production use. See README.md.
# Step 1: import the container image once (CPU job, about 10-20 min).
#SBATCH -J vllm-import
#SBATCH -c 16
#SBATCH -t 90
#SBATCH -o vllm-import-%j.log

P=/projects/YOUR_PROJECT       # your SSD project directory
[ -d "$P" ] || { echo "Edit P: $P does not exist"; exit 1; }
D=$P/vllm
IMAGE=vllm
TAG=26.08-py3

export ENROOT_TEMP_PATH=$P/.tmp/$SLURM_JOB_ID ENROOT_CACHE_PATH=$P/.enroot-cache
mkdir -p $ENROOT_TEMP_PATH $ENROOT_CACHE_PATH $D
trap 'rm -rf $ENROOT_TEMP_PATH' EXIT

cd $D
enroot import -o $IMAGE-$TAG.sqsh.part "docker://nvcr.io#nvidia/$IMAGE:$TAG"
mv $IMAGE-$TAG.sqsh.part $IMAGE-$TAG.sqsh
ls -lh $D/$IMAGE-$TAG.sqsh
