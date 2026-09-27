#!/bin/bash
# TUTORIAL ONLY - not for production use. See README.md.
# Step 3: serve the model inside the job, send requests, then stop.
# The server listens on 127.0.0.1 only and ends with the job; long-running
# public endpoints are not allowed on the cluster.
#SBATCH -J vllm-serve
#SBATCH --gres=gpu:pro6000:1
#SBATCH -t 1:00:00
#SBATCH -o vllm-serve-%j.log

P=/projects/YOUR_PROJECT       # your SSD project directory
[ -d "$P" ] || { echo "Edit P: $P does not exist"; exit 1; }
D=$P/vllm
MODEL=Qwen/Qwen3.8-27B-FP8
mkdir -p $D/home

srun --container-image=$D/vllm-26.08-py3.sqsh \
     --container-mounts=$P:$P,$D/home:$HOME \
     --export=ALL,HF_HOME=$P/hf,HF_HUB_OFFLINE=1,MODEL=$MODEL,D=$D \
     bash -c '
       PORT=$((20000 + SLURM_JOB_ID % 20000))
       vllm serve $MODEL --host 127.0.0.1 --port $PORT \
            --max-model-len 32768 --max-num-seqs 64 --gpu-memory-utilization 0.90 \
            > $D/server-$SLURM_JOB_ID.log 2>&1 &
       SERVER=$!
       trap "kill $SERVER 2> /dev/null" EXIT

       for i in $(seq 1 180); do
         curl -sf http://127.0.0.1:$PORT/health > /dev/null && break
         kill -0 $SERVER 2> /dev/null || { echo "server died, see $D/server-$SLURM_JOB_ID.log"; exit 1; }
         [ $i = 180 ] && { echo "server not ready after 15 min"; exit 1; }
         sleep 5
       done
       echo "server ready after about $((i * 5)) s"

       python3 $D/client.py --port $PORT --model $MODEL
     ' < /dev/null
