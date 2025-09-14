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
  - **CPU:** 8 cores
  - **RAM:** 32 GB
  - **GPU: NONE**
- gpu-6000ada (gpu-6000ada-1 to gpu-6000ada-3)
  - **CPU:** 20 cores
  - **RAM:** 256 GiB (240000 MiB or 234 GiB requestable)
  - **GPU:** 4x NVIDIA RTX6000 ADA Generation (48GB), `6000ada`
- gpu-v100-1
  - **CPU:** 20 cores
  - **RAM:** 768 GiB (752000 MiB or 734 GiB requestable)
  - **GPU:** 8x NVIDIA Tesla V100 SXM2 (32GB), `v100`
- gpu-v100-2
  - **CPU:** 20 cores
  - **RAM:** 384 GiB (368000 MiB or 359 GiB requestable)
  - **GPU:** 8x NVIDIA Tesla V100 SXM2 (32GB), `v100`

To learn more about how to use the GPU nodes, check out
[Introduction to Slurm CLI and Modules](slurm.md).

## Slurm

To ensure fair access to all users while minimizing idle resources, the cluster
supports two modes of execution (different QoS):

- Default Fair-share
- Preemption (Override Limits)

By default, you can use the GPUs as specified below. The numbers are per-user.

| Users     | `6000ada` | `v100` (Provided by `rose`) |
|-----------|-----------|-----------------------------|
| rose      | 4         | 16                          |
| phd       | 4         | QoS                         |
| msc       | 2         | QoS                         |
| ug-proj   | 2         | QoS                         |
| ug-course | 1         | QoS                         |

To use within your limits, you do not have to specify anything.

To **use more than the limit** such as group-specific cards, specify
`--qos override-limits-but-killable`. You can learn more about submitting a job
in [Slurm Introduction](slurm.md).

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

As such, `--mem` and `--cpus-per-task` are overridden by our setup script.
Setting them will not do anything.

### GPU Type is Required

All requests that do not specify the GPU model are blocked because our cluster
has various type of GPUs and some GPUs significantly outperform other GPUs.

You must specify the GPU model when you are calling `srun` and `sbatch`. If you
don't specify, you might see an error message from Slurm and/or fail to run your
job successfully.

### `srun` and `salloc` 12-hour Time Limit

We limit the hour limit on `srun` and `salloc` to stay below 12 hours. This is
because both command does not auto exit even if your job is done.

We want to release the nodes as fast as we can, so we enforce shorter time limit
for these two commands. By default, if you don't specify the time limit, it is
the default time limit of the cluster, i.e., 48 hours.

As such, if you do not specify `--time 12:00:00` or a lower number, your `srun`
or `salloc` command will fail.

## Directories

This cluster's storage are mostly network-backed and some directories are
synchronized across all nodes. Notable examples are:

- `/home/<username>` - All your configuration and home directory files are
  synchronized. There is a **50 GB limit**.
- `/projects/<project_name>` - These directories can be created with
  [storaged](storaged.md). The aggregated limit is listed below.

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
