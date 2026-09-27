#!/bin/bash
# TUTORIAL ONLY - not for production use. See README.md.
# Step 3: run an Isaac Sim example headless and save its output.
#SBATCH -J isaac-sim
#SBATCH --gres=gpu:pro6000:1
#SBATCH -t 30
#SBATCH -o isaac-sim-%j.log

P=/projects/YOUR_PROJECT       # your SSD project directory
[ -d "$P" ] || { echo "Edit P: $P does not exist"; exit 1; }
D=$P/isaac-sim
TAG=6.1.0
EXAMPLE=/isaac-sim/standalone_examples/api/isaacsim.replicator.examples/sdg_getting_started_01.py
OUT=$D/out/$SLURM_JOB_ID

# Persistent home and shader cache inside the container.
mkdir -p $D/home $D/cache/kit $OUT

# The host driver's NGX (DLSS) libraries; enroot does not inject them.
L=/usr/lib/x86_64-linux-gnu
V=$(cat /sys/module/nvidia/version)
NGX=$L/libnvidia-ngx.so.$V:$L/libnvidia-ngx.so.$V:ro,$L/libnvidia-ngx.so.$V:$L/libnvidia-ngx.so.1:ro,$L/nvidia/wine:$L/nvidia/wine:ro

srun --container-image=$D/isaac-sim-$TAG.sqsh \
     --container-mounts=$D/home:$HOME,$D:$D,$D/cache/kit:/isaac-sim/kit/cache,$NGX \
     --container-workdir=$OUT \
     --export=ALL,ACCEPT_EULA=Y,PRIVACY_CONSENT=N,OMNI_KIT_ACCEPT_EULA=YES,OMNICLIENT_HUB_MODE=disabled \
     env TMPDIR=/tmp /isaac-sim/python.sh $D/headless.py $EXAMPLE < /dev/null

ls $OUT/_out_basic_writer
