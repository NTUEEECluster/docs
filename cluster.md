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

EEE Cards:

| Users     | `6000ada` |
|-----------|-----------|
| rose      | 4         |
| phd       | 4         |
| msc       | 2         |
| ug-proj   | 2         |
| ug-course | 1         |

Group-specific Cards:

| GPU Type | Group  | Per-User Limit |
|----------|--------|----------------|
| `v100`   | `rose` | 8              |
| `a100`   | `rose` | Coming Soon    |

To use within your limits, you do not have to specify anything.

To **use more than the limit**, specify `--qos override-limits-but-killable`.
You can learn more about submitting a job in [Slurm Introduction](slurm.md).

> **WARNING:** As the name implies, this makes your job killable. The cluster
> will kill your job (and add it back to the queue for later) if someone else is
> requesting for the same resources within their limit.

You are recommended to save epochs and make your program check if there are
previous epochs to resume from if you make use of this feature.
