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

Currently, we enforce a hard 8 GB RAM per user limit on login nodes. Users
exceeding this limit may see their processes killed by the kernel. This number
may have changed and is only included here as a rough gauge.

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
will block other users' GPU requests. We enforce CPU and RAM allocations based
on the number of GPUs requested — setting `--mem` or `--cpus-per-task`
alongside `--gpus` will be ignored with a warning.

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

You are recommended to save epochs and make your program check if there are
previous epochs to resume from if you make use of this feature.

## Directories

This cluster's storage are mostly network-backed and some directories are
synchronized across all nodes. Notable examples are:

- `/home/<username>` - All your configuration and home directory files are
  synchronized. There is a **50 GB limit**.
- `/projects/<project_name>` - These directories can be created with
  [storaged](storaged.md). The aggregated limit is listed below.
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
