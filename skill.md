---
name: ntu-eee-cluster02
description: Context and rules for working on the NTU EEE GPU Cluster 02 (Slurm) on a user's behalf. Load before running any command on the cluster.
---

# NTU EEE Cluster 02

## What this cluster is

- A shared GPU cluster for NTU EEE research and coursework, run by the
  EEE/ROSE cluster admin team on a best-effort basis. It is free to use; there
  is no monetary billing.
- The hardware is funded by the school and by research groups. Groups that
  fund hardware get access matched to what they funded; everyone else shares
  the rest under fixed per-group limits. Limits are not raised on request.
- Users are students (personal accounts), faculty project members (accounts
  from a faculty call) and hardware contributors. Many users share every node,
  so one user's misuse costs everyone.
- Access is SSH only: login nodes for editing and submission, compute nodes
  through Slurm only, and shared network storage mounted identically on all of
  them.

You act for one user. Breaking the rules below gets **that user** warned or
banned. When a rule blocks the task, stop and tell the user; do not work
around it.

## Never

- Run heavy work on a login node (installs, data processing, training,
  repository-wide searches). Per user: 3 CPU cores, 16 GB RAM; going over kills
  all the user's login processes.
- Leave interactive jobs or idle allocations holding GPUs.
- Serve a chatbot or inference endpoint from compute nodes.
- Read or list other users' files, or make the user's files world-readable.
- Use `sudo`, `salloc`, `--exclusive`, `--mem`, `--cpus-per-task` on GPU jobs,
  `--cpus-per-gpu`, `--gpus-per-socket` or `--ntasks-per-gpu/core/socket`.
- Install toolchains (CUDA, GCC) yourself; use `module load`.
- Write caches or environments to `$HOME` (50 GB) or `/tmp` (4 GB per user,
  follows the user to every node, never cleaned).
- Retry a rejected submission with variations to get past a rule.

## Always

- Redirect `TMPDIR`, `PIP_CACHE_DIR`, `CONDA_PKGS_DIRS`, `HF_HOME`,
  `TRITON_CACHE_DIR` and `XDG_CACHE_HOME` to an SSD project directory before
  installing anything.
- Name exactly one GPU model: `--gres=gpu:<model>:<N>`. CPUs and RAM come with
  the GPUs.
- Use `sbatch` for anything longer than a few minutes. Interactive
  `srun --pty` is at most 2 h, 1 GPU, 1 node, and dies with the SSH session.
- Keep batch jobs within 3 days and checkpoint long runs.
- Query the live cluster instead of assuming: `sinfo` for nodes and GPU models,
  `sacctmgr show assoc user=$USER format=Account,QOS%40,DefaultQOS` for the
  user's accounts and limits.
- Run containers from a `.sqsh` image in an SSD project directory, never from a
  registry name.

## Details

| Need | Read |
|---|---|
| Rules, eligibility, data, support | `terms-n-conditions.md` |
| Login and first job | `quickstart.md` |
| Cluster layout, querying nodes | `cluster-guide.md` |
| Job templates, limits, billing, pending reasons | `slurm-guide.md` |
| Storage tiers, `storagemgr`, cache redirection | `storage-guide.md` |
| Containers (enroot + pyxis) | `container-guide.md` |

All at https://github.com/NTUEEECluster/docs
