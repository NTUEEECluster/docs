# Slurm Guide

Slurm queues your jobs and hands out GPUs. Nobody else can use a GPU you hold,
even while it sits idle, so request only what you use.

## Software

Compilers, CUDA and Conda come as Lmod modules. Do not install toolchains
yourself.

```bash
module avail                  # list modules
module spider <name>          # search, e.g. module spider CUDA
module load <name>/<version>  # e.g. module load CUDA/12.8.0
module list                   # loaded modules
module purge                  # unload everything
```

Python packages go in your own Conda environment (the base environment is
read-only). Redirect caches first, as the [Storage Guide](storage-guide.md#redirect-caches-required)
requires.

```bash
module load Miniforge3
conda create -n my_env python=3.12
source activate my_env
pip install <package>
```

Missing software? Email us its name and version.

## Batch job (GPU)

Save as `job.sh` and run `sbatch job.sh`. It keeps running after you log out.

```bash
#!/bin/bash
#SBATCH --job-name=train
#SBATCH --gres=gpu:a40:1          # gpu:<model>:<count>, see the Cluster Guide
#SBATCH --time=12:00:00           # max 3-00:00:00
#SBATCH --output=%x-%j.out        # %x = job name, %j = job ID

P=/projects/<project>
export TMPDIR=$P/.tmp/$SLURM_JOB_ID
mkdir -p $TMPDIR
trap 'rm -rf $TMPDIR' EXIT

module load Miniforge3
source activate my_env
python train.py
```

For several GPUs on one node, raise the count and start one process per GPU,
e.g. `--gres=gpu:pro6000:4` with `torchrun --nproc_per_node=4 train.py`.

## Batch job (CPU only)

Omit `--gres`; the job runs on a CPU node and costs nothing.

```bash
#!/bin/bash
#SBATCH --job-name=prep
#SBATCH --cpus-per-task=16        # 3 GiB RAM per CPU
#SBATCH --time=4:00:00

module load Miniforge3
source activate my_env
python preprocess.py
```

## Interactive job

```bash
srun --gres=gpu:a40:1 --time=1:00:00 --pty bash
```

- At most **2 hours, 1 GPU, 1 node** (30 minutes if you omit `--time`).
- The job ends when your SSH session drops. Use `sbatch` for anything long.
- `salloc` is disabled.

To debug with an IDE on the node, keep that `srun` open, then connect the IDE
through the login node: `ssh -J <username>@<login_IP> <username>@<node_name>`.
If the IDE only takes a host and port, forward one on your own computer with
`ssh -L <port>:<node_name>:22 <username>@<login_IP>` and connect to
`localhost:<port>`. Exit the shell when done; an idle job still holds its GPU.

## Rules checked at submission

| Rule | Detail |
|---|---|
| Name one GPU model | `--gres=gpu:<model>:<N>`. Untyped (`--gres=gpu:2`) or mixed models are rejected. |
| CPUs and RAM come with the GPUs | 4 CPUs per GPU plus a fixed RAM per GPU for each model; `--mem` is overridden. Do not set `-c`/`--cpus-per-task` on GPU jobs: a value other than 4 per GPU makes every `srun` inside the job fail with `cpus_per_task set by two different environment variables`. `-C highmem` or `-C midmem` gives more RAM on some `pro6000` nodes. |
| Time | Batch: default 1 h, max 3 days. Interactive: max 2 h. |
| Not allowed | `--exclusive`, `--cpus-per-gpu`, `--gpus-per-socket`, `--ntasks-per-gpu/core/socket`, `salloc` |
| No changes after submission | Resources, QoS, account and time limit are fixed; cancel and resubmit. |

The rejection message says which rule failed. If a job runs out of memory, ask
for more GPUs or add `-C highmem` on `pro6000`.

## Limits

Per-user GPU and job limits depend on your QoS. See yours live:

```bash
sacctmgr show assoc user=$USER format=Account,QOS%40,DefaultQOS
sacctmgr show qos -P format=Name,MaxTRESPU,MaxJobsPU,MaxSubmitPU
```

`--qos=override-limits-but-killable` (personal accounts only) runs on idle GPUs
beyond your limits and costs nothing, but a regular job that needs those GPUs
**requeues** yours. Checkpoint often and resume from the last checkpoint.

Faculty project members submit with `-A faculty-proj --qos=<project_qos>`, or
export `SBATCH_ACCOUNT`/`SBATCH_QOS` (for `sbatch`) and
`SLURM_ACCOUNT`/`SLURM_QOS` (for `srun`).

## Billing

GPU time is billed in Service Units (1 SU = 1 billing-minute): GPUs × minutes ×
the model's weight. CPU-only jobs are free.

| Model | SU per GPU-hour |
|---|---:|
| pro6000 | 480 |
| rtx5090 | 360 |
| l40, 6000ada | 240 |
| a40, a6000 | 180 |

Personal accounts have a monthly quota (`rose`, `phd`: 806,400 SU; `msc`,
`ug-proj`: 180,000 SU), reset on the 1st. A faculty project has one budget
shared by all members for the whole project. When the quota runs out, new jobs
stay pending and running jobs carry on.

```bash
# personal quota used / cap this month
sshare -U -nP -o GrpTRESMins,GrpTRESRaw | awk -F'|' '{match($1,/billing=([0-9]+)/,c); match($2,/billing=([0-9]+)/,u); if (c[1]>0) printf "%d / %d SU (%.1f%%)\n", u[1], c[1], 100*u[1]/c[1]; else print "No personal cap."}'
```

## Job status

```bash
squeue --me                   # your jobs; REASON explains pending jobs
scontrol show job <jobid>     # full details
scancel <jobid>               # cancel
```

| Pending reason | Meaning |
|---|---|
| `Resources` / `Priority` | Waiting for GPUs to free up |
| `QOSMaxJobsPerUserLimit` | You have the maximum number of running jobs |
| `QOSMaxGRESPerUser` | You are at your GPU limit for that model |
| `AssocGrpBillingMinutes` | Monthly quota used up |
| `QOSGrpBillingMinutes` | Project budget used up; contact your PI |
| `ReqNodeNotAvail` | Nodes down, or your `--time` overlaps maintenance |

## Compiling from source

Load a toolchain and install into your own directory:

```bash
module load GCC/13.3.0
module load CUDA/12.8.0       # only for custom GPU code; PyTorch wheels bundle CUDA
```
