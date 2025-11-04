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

Most nodes that you interact with are VMs. As such, the actual hardware is not
listed. Specifications listed below are per node.

When you connect through the IP provided in the email, you will automatically be
routed to a login node. Nodes are expected to go down for maintenance but at
least one login node should be up at all times. Please let us know if you are
unable to connect or run into trouble requesting a compute node so we can
investigate.

- Login Nodes (login-1 to login-3)
  - **CPU:** 12 cores
  - **RAM:** 64 GB
  - **GPU: NONE**
- gpu-6000ada-\[1-3\]
  - **CPU:** 16 cores
  - **RAM:** 264 GiB (256 GiB requestable)
  - **GPU:** 4x NVIDIA RTX6000 ADA Generation (48GB), `6000ada`
- gpu-v100-1
  - **CPU:** 32 cores
  - **RAM:** 264 GiB (256 GiB requestable)
  - **GPU:** 8x NVIDIA Tesla V100 SXM2 (32GB), `v100`
- gpu-v100-2
  - **CPU:** 32 cores
  - **RAM:** 396 GiB (384 GiB requestable)
  - **GPU:** 8x NVIDIA Tesla V100 SXM2 (32GB), `v100`
- gpu-a5000-\[1-5\]
  - **CPU:** 16 cores
  - **RAM:** 112 GiB (96 GiB requestable)
  - **GPU:** 4x NVIDIA RTX A5000 (24GB), `a5000`
- cpu-1
  - **CPU:** 24 cores
  - **RAM:** 396 GiB (384 GiB requestable)
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

All your processes on login nodes will be terminated upon disconnection. This
includes commands that are run with `tmux` or `nohup`.

This feature has been implemented as there are no supported methods to reliably
reconnect to a login node after disconnection and lingering processes have led
to numerous issues for users.

We are aware of possible bypasses of this feature but we will not provide
support for users doing so.

This does not clean up any of the files left behind by your processes. We kill
your processes with SIGINT so they have a few seconds of opportunity to cleanup
their own files but not every process does so.

## Slurm

To ensure fair access to all users while minimizing idle resources, the cluster
supports two modes of execution (different QoS):

- Default Fair-share
- Preemption (Override Limits)

### CPU/RAM Enforcement

Slurm treats CPU cores and RAM as consumable resources. As such, over-requesting
these two will potentially block other's requests for GPUs. This has happened
in the past and we now enforce the number of CPUs and RAM based on number of
GPUs requested.

Setting `--mem` will only give you a warning that your values are being
overridden. Setting `--cpu-per-task` when you have GPUs specified will also
be ignored with a warning only.

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
- `gpu_16g`: Any GPU with at least 16GB of VRAM
- `gpu_32g`: Any GPU with at least 32GB of VRAM
- `gpu_48g`: Any GPU with at least 48GB of VRAM
- `<gpu_name>`: Only matches the GPU, useful for combining (e.g. `v100|a5000`)

### Job Limits

We have added additional constraints on interactive jobs due to frequent
under-utilization during an interactive job. Interactive jobs is only intended
to be used if you need to debug a specific issue that only happens on GPU nodes.

These constraints are:

|            | Interactive Jobs (`srun`)      | Batch Jobs (`sbatch`) |
|------------|--------------------------------|-----------------------|
| Time Limit | 2 hours/job                    | 48 hours/job          |
| Job Limit  | 1 job total (incl. batch jobs) |                       |
| GPU Limit  | 1 GPU                          | See table below       |

Here are the details of GPU usage limit:

| Users        | `6000ada` \[EEE\] | `a5000` \[ROSE\]    | `v100` \[ROSE\]     |
|--------------|-------------------|---------------------|---------------------|
| rose         | 4                 | 8                   | 16                  |
| phd          | 4                 | Best-Effort[^1] (4) | Best-Effort[^1] (8) |
| msc          | 2                 | Best-Effort[^1] (2) | Best-Effort[^1] (4) |
| ug-proj      | 2                 | Best-Effort[^1] (2) | Best-Effort[^1] (4) |
| Course Users | 1                 | Best-Effort[^1] (1) | Best-Effort[^1] (1) |

[^1]: Best-Effort means that we will tweak values depending on demand and the
      value may be as low as zero. As such, the value bracketed is not
      guaranteed and might not be up-to-date. `override-limits-but-killable` may
      still request resources under Best-Effort with the same caveats.

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

| Users        | SSD Quota (`ssd`) | HDD Quota (`hdd`) |
|--------------|-------------------|-------------------|
| rose         | 400 GB            | 5 TB              |
| phd          | 400 GB            | 1 TB              |
| msc          | 50 GB             | 300 GB            |
| ug-proj      | 50 GB             | 300 GB            |
| Course Users | 20 GB             | Unavailable       |

This table may lag behind actual configuration, please check the actual quota
you are assigned using the `storagemgr` command in the cluster.

> **TIP:** While HDDs are traditionally slower, our enterprise HDDs have been
> configured in a RAID-like system and are able to serve multiple GB/s. We
> recommend using the `hdd` tier for most use cases. **In our testing, `ssd`
> tier is only helpful if you have 1000s or 10000s small files.** As course
> users do not have access to the `hdd` tier, please use the `ssd` tier.
