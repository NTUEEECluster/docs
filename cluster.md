# Cluster Overview

- What are the hardware? [Nodes](#Nodes)
- What are the available partitions and QoS? [Slurm](#Slurm)
- What are the important file paths? [Directories](#Directories)
- What are the limitations that are in place?
  - [Login Node Resource Limits](#Login-Node-Resource-Limitation)
  - [Auto-Termination of Login Node Processes](#process-cleanup)
  - [Slurm Submission Limits](#Job-Limits)
  - [Storage Limits](#Directories)

## High-Level Policy

Thanks to various generous entities, all GPUs are free to use, there is no hard
GPU hour limit on you. By default, you will be limited by the number of GPUs you
can use at any given time to ensure fair-share.

See [Slurm](#Slurm) for more details.

## Nodes

Specifications listed below are per node. When you connect through the IP
provided in the email, you will automatically be routed to a login node.
Please let us know if you are unable to connect or run into trouble requesting
a compute node so we can investigate.

- Login Nodes (login-1 to login-3)
  - **CPU:** 12 cores
  - **RAM:** 64 GB
  - **GPU: NONE**
- gpu-6000ada-\[1-3\]
  - **CPU:** 16 cores
  - **RAM:** 264 GiB (256 GiB requestable)
  - **GPU:** 4x NVIDIA RTX6000 ADA Generation (48GB), `6000ada`
- gpu-a6000-1
  - **CPU:** 40 cores
  - **RAM:** 228 GiB (224 GiB requestable)
  - **GPU:** 10x NVIDIA RTX A6000 (48GB), `a6000`
- gpu-a40-1
  - **CPU:** 40 cores
  - **RAM:** 477 GiB (≈468 GiB requestable)
  - **GPU:** 10x NVIDIA A40 (48GB), `a40`
- gpu-l40-\[1-2\]
  - **CPU:** 16 cores
  - **RAM:** 201 GiB (≈196 GiB requestable)
  - **GPU:** 4x NVIDIA L40 (48GB), `l40`
- gpu-pro6000-\[1-4\]
  - **CPU:** 16 cores
  - **RAM:** 387 GiB (384 GiB requestable)
  - **GPU:** 4x NVIDIA RTX Pro 6000 (96GB), `pro6000`
- gpu-pro6000-\[5-6\]
  - **CPU:** 40 cores
  - **RAM:** 341 GiB (336 GiB requestable)
  - **GPU:** 10x NVIDIA RTX Pro 6000 (96GB), `pro6000`
- gpu-pro6000-\[7-10\]
  - **CPU:** 64 cores
  - **RAM:** 743 GiB (736 GiB requestable)
  - **GPU:** 8x NVIDIA RTX Pro 6000 (96GB), `pro6000`
- cpu-1
  - **CPU:** 24 cores
  - **RAM:** 387 GiB (384 GiB requestable)
  - **GPU: NONE**

To learn more about how to use the GPU nodes, check out
[Introduction to Slurm CLI and Modules](slurm.md).

### Login Node Resource Limitation

You are reminded that each user is only allowed a small share of resources on
login nodes as mentioned in the [Usage Guidelines](guideline.md).

Currently, we enforce a per-user cgroup limit of **16 GB RAM** on login nodes,
alongside a CPU cap. When any single process exceeds the cgroup memory limit,
the kernel will kill **every process that user has on the login node**, not
just the offending one (cgroup `memory.oom.group=1`). Plan accordingly — keep
heavy IDE backends, indexers, and agent processes off login nodes; use
[Slurm](slurm.md) for any non-trivial work.

<a id="process-cleanup" />

### Auto-Termination of Processes on Login Nodes

All your processes on login nodes will be terminated upon disconnection,
including commands run with `tmux` or `nohup`. We will not provide support for
bypassing this behaviour.

This does not clean up files left behind by your processes.

## Slurm

To ensure fair access to all users while minimizing idle resources, the cluster
supports two modes of execution (different QoS):

- Default Fair-share
- Preemption (Override Limits)

### CPU/RAM Enforcement

Slurm treats CPU cores and RAM as consumable resources. Over-requesting these
would block other users' GPU requests, so we enforce both at submit time
based on the number of GPUs you request. **Setting `--mem` or
`--cpus-per-task` alongside `--gpus` is silently overridden with a warning
— do not specify them.**

CPU is fixed at **4 cores per GPU**. RAM per GPU depends on the GPU model:

| GPU model         | RAM per GPU | Notes                                      |
|-------------------|-------------|--------------------------------------------|
| `6000ada`         | 64 GiB      |                                            |
| `a40`             | 40 GiB      |                                            |
| `l40`             | 48 GiB      |                                            |
| `a6000`           | 24 GiB      |                                            |
| `pro6000`         | 33 GiB      | floor across all `pro6000` nodes           |
| `pro6000` + `-C highmem` | 92 GiB | lands only on `pro6000-[1-4]` or `pro6000-[7-10]` |

**Why pro6000 has a low default**: `pro6000-[5-6]` are 10-GPU nodes with
only ~340 GiB usable RAM (≈33 GiB/GPU), which sets the floor for any
`pro6000` request. If you need more RAM per pro6000, add `-C highmem` —
this both upgrades the per-GPU allocation to 92 GiB and constrains
scheduling to the high-RAM pro6000 subset (`[1-4]` or `[7-10]`). Jobs that
need 92 GiB/GPU on pro6000-[5-6] are not possible by design.

For CPU-only (no `--gpus`) jobs, RAM defaults to 16 GiB per CPU.

### GPU Type is Required

All requests that do not specify the GPU model are blocked because our cluster
has various type of GPUs and some GPUs significantly outperform other GPUs.

You must specify the GPU model when you are calling `srun` and `sbatch`. If you
don't specify, you might see an error message from Slurm and/or fail to run your
job successfully.

This can be done by specifying `--gpus example:1` or through constraints
(`-C 'example|(another&more)'`).

### Constraints

The valid constraints are:

- `gpu`: Any GPU available
- `gpu_48g`: Any GPU with at least 48GB of VRAM
- `gpu_96g`: Any GPU with at least 96GB of VRAM
- `<gpu_name>`: Only matches the GPU, useful for combining (e.g. `a40|a6000`)

### Job Limits

Interactive jobs are intended for debugging issues that only reproduce on GPU
nodes. Additional constraints apply:

These constraints are:

|            | Interactive Jobs (`srun`)      | Batch Jobs (`sbatch`) |
|------------|--------------------------------|-----------------------|
| Time Limit | 2 hours/job                    | 3 days/job            |
| Job Limit  | 1 job total (incl. batch jobs) |                       |
| GPU Limit  | 1 GPU                          | See table below       |

Here are the details of GPU usage limits:

| Users      | `6000ada` \[EEE\] | `a6000` \[ROSE\] | `a40` \[ROSE\] | `l40` \[ROSE\] | `pro6000` \[ROSE\] |
|------------|-------------------|------------------|----------------|----------------|--------------------|
| rose       | 4                 | 4                | 8              | 4              | 4                  |
| phd        | 4                 | 4                | 4              | 4              | 4                  |
| msc        | 2                 | 2                | 2              | 2              | 2                  |
| ug         | 2                 | 2                | 2              | 2              | 2                  |
| ug-course  | 1                 | 1                | 1              | 1              | 1                  |

Limits may be adjusted based on demand. Check
`sacctmgr show qos -P format=Name,MaxTRESPerUser` for the live configuration.

The job limit and GPU limit can be overridden by using the
`override-limits-but-killable` QoS. When you enable the QoS, your job may be
killed (and later restarted) to make space for other user's jobs if required. As
such, this effectively means that jobs with the QoS may only use idle GPUs. You
can learn more about submitting a job in [Slurm Introduction](slurm.md).

**Preemption rule**: any within-limit user job (default user QoS — `rose`,
`ug`, `ug-course`, faculty-project QoSes, etc.) preempts
`override-limits-but-killable` jobs. When a within-limit user submits and
the GPUs they're entitled to are held by override-killable jobs, those
override-killable jobs are **requeued** (not killed outright — Slurm puts
them back in the queue with their existing state) so the within-limit job
can run.

You are recommended to save epochs and make your program check if there are
previous epochs to resume from if you make use of this feature.

### Account types

The QoS table above lists the **per-user class tiers** (`rose` / `phd` /
`msc` / `ug` / `ug-course`). The cluster also has **faculty-sponsored
project accounts** — researchers or labs that have contributed hardware
get a dedicated QoS (typically named after the PI, e.g.
`<lastname>_<year>_<NN>`) with its own GPU-type allowlist and
TRES-minute compute budget. Members of these projects are added to the
matching account by their PI.

If you don't know whether you have a project QoS, check
`sacctmgr show assoc where user=$USER format=Account,QOS,DefaultQOS` —
your `DefaultQOS` is what runs when you don't pass `--qos=`.

## Directories

This cluster's storage are mostly network-backed and some directories are
synchronized across all nodes. Notable examples are:

- `/home/<username>` - All your configuration and home directory files are
  synchronized. There is a **50 GB limit**.
- `/projects/<project_name>` - These directories can be created with the
  `storagemgr` command (see [below](#using-storagemgr)). The aggregated limit
  is listed below.
- `/tmp` - Your temp directory is synchronized and each user has their own
  isolated `/tmp`. There is a **4GB limit**.

| Users     | SSD Quota (`ssd`) | HDD Quota (`hdd`) |
|-----------|-------------------|-------------------|
| rose      | 750 GB            | 5 TB              |
| phd       | 750 GB            | 1 TB              |
| msc       | 150 GB            | 400 GB            |
| ug        | 150 GB            | 400 GB            |
| ug-course | 20 GB             | Unavailable       |

This table may lag behind actual configuration, please check the actual quota
you are assigned using the `storagemgr` command in the cluster.

> **TIP:** While HDDs are traditionally slower, our enterprise HDDs have been
> configured in a RAID-like system and are able to serve multiple GB/s. We
> recommend using the `hdd` tier for most use cases. **In our testing, `ssd`
> tier is only helpful if you have 1000s or 10000s small files.** As course
> users do not have access to the `hdd` tier, please use the `ssd` tier.

### Using `storagemgr`

Run `storagemgr` from a login node to launch the interactive UI for managing
project directories under `/projects`. Through the UI you can request
additional project directories with quotas drawn from your account's total
allowance. Notes:

- **Naming**: alphanumeric and hyphens only. No NSFW or offensive names —
  violations result in immediate ban. Pick something unique and recognizable
  (only the top 5 largest folders are shown in the UI).
- **Quotas**: split your total quota across one or more directories — e.g.
  one 5 TB folder *or* five 1 TB folders. Duplicate names fail.
- **Permanent name**: do not rename a project directory after creation.
- **Permissions**: you may relax permissions to share a project directory.
  By doing so you are fully liable for any data leak or loss.

Need more storage? Discuss with your supervisor about contributing storage —
that is the route to a higher overall quota.
