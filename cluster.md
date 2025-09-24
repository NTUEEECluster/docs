# Cluster Overview

- What are the hardware? [Nodes](#Nodes)
- What are the available partitions and QoS? [Slurm](#Slurm)
- What are the important file paths? [Directories](#Directories)

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
- gpu-6000ada (gpu-6000ada-1 to gpu-6000ada-3)
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
- cpu-1
  - **CPU:** 24 cores
  - **RAM:** 396 GiB (384 GiB requestable)
  - **GPU: NONE**

To learn more about how to use the GPU nodes, check out
[Introduction to Slurm CLI and Modules](slurm.md).

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

By default, you can use the GPUs as specified below. The numbers are per-user.

| Users     | `6000ada` | `v100` (Provided by `rose`) |
|-----------|-----------|-----------------------------|
| rose      | 4         | 16                          |
| phd       | 4         | Best-Effort                 |
| msc       | 2         | Best-Effort                 |
| ug-proj   | 2         | Best-Effort                 |
| ug-course | 1         | Best-Effort                 |

To use within your limits, you do not have to specify anything.

To **use more than the limit** such as group-specific cards, specify
`--qos override-limits-but-killable`. You can learn more about submitting a job
in [Slurm Introduction](slurm.md).

Best-Effort means that we will tweak values depending on demand and the value
may be as low as zero. `override-limits-but-killable` may still request
resources under Best-Effort.

> **WARNING:** As the name implies, this makes your job killable. The cluster
> will kill your job (and add it back to the queue for later) if someone else is
> requesting for the same resources within their limit.

You are recommended to save epochs and make your program check if there are
previous epochs to resume from if you make use of this feature.

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

### Job Limits

We have added additional constraints on interactive jobs due to frequent
under-utilization during an interactive job. Interactive jobs is only intended
to be used if you need to debug a specific issue that only happens on GPU nodes.

These constraints are:

- Maximum of 2 hour per interactive job
- Maximum of 1 node / 1 GPU in interactive job
- Maximum of 1 jobs running at any point in time (including batch jobs)

## Directories

This cluster's storage are mostly network-backed and some directories are
synchronized across all nodes. Notable examples are:

- `/home/<username>` - All your configuration and home directory files are
  synchronized. There is a **50 GB limit**.
- `/projects/<project_name>` - These directories can be created with
  [storaged](storaged.md). The aggregated limit is listed below.
- `/tmp` - Your temp directory is synchronized and each user has their own
  isolated `/tmp`. There is a **2GB limit**.

> **TIP:** Some legacy users may have larger quota on /home directories as part
> of our migration strategy. If this applies to you, you are advised to get
> below 50GB as soon as possible. We reserve the right to lower the quota at any
> time which will cause all writes to your /home directory to fail until you
> delete files. **This may cause your shell to not function correctly.**

| Users     | SSD Quota (`ssd`) | HDD Quota (`hdd`) |
|-----------|-------------------|-------------------|
| rose      | 400 GB            | 5 TB              |
| phd       | 400 GB            | 1 TB              |
| msc       | 50 GB             | 300 GB            |
| ug-proj   | 50 GB             | 300 GB            |
| ug-course | 20 GB             | \-                |

This table may lag behind actual configuration, please check the actual quota
you are assigned using the `storagemgr` command in the cluster.

> **TIP:** While HDDs are traditionally slower, our enterprise HDDs have been
> configured in a RAID-like system and are able to serve multiple GB/s. We
> recommend using the `hdd` tier for most use cases. **In our testing, `ssd`
> tier is only helpful if you have 1000s or 10000s small files.**
