# Cluster Overview

- What are the hardware? [Nodes](#Nodes)
- What are the available partitions and QoS? [Slurm](#Slurm)
- What are the important file paths? [Directories](#Directories)

## Nodes

Most nodes that you interact with are VMs. As such, the actual hardware is not
listed. Specifications listed below are per node.

When you connect through the IP provided in the email, you will automatically be
routed to a login node.

- Login Nodes (login-1 to login-3)
  - **CPU:** 8 cores
  - **RAM:** 32 GB
  - **GPU: NONE**
- gpu-6000ada (gpu-6000ada-1 to gpu-6000ada-3)
  - **CPU:** 20 cores
  - **RAM:** 256 GB
  - **GPU:** 4x NVIDIA RTX6000 ADA Generation (48GB), `6000ada`
- gpu-v100-1
  - **CPU:** 20 cores
  - **RAM:** 768 GB
  - **GPU:** 8x NVIDIA Tesla V100 SXM2 (32GB), `v100`
- gpu-v100-2
  - **CPU:** 20 cores
  - **RAM:** 384 GB
  - **GPU:** 8x NVIDIA Tesla V100 SXM2 (32GB), `v100`

FAQ:
- Awesome. So how do I actually get access to the GPUs?
  [Slurm Introduction](slurm.md)
- How do I specify which GPU I want to use?
  You can specify the type like so: `--gpus v100:1`. `v100` is the name stated
  above and `1` is the number of GPUs needed.

## Slurm

To ensure fair access to all users while minimizing idle resources, the cluster
supports two modes of execution (different QoS):

- Default Fair-share
- Preemption (Override Limits)

By default, you can use the GPUs as specified below. The numbers are per-user.

| Users     | `6000ada` | `v100` |
|-----------|-----------|--------|
| rose      | 4         | 16     |
| ug-proj   | 2         | 0      |
| msc       | 2         | 0      |
| ug-course | 1         | 0      |

To use within your limits, you do not have to specify anything.

To **use more than the limit**, specify `--qos override-limits-but-killable`.

> **WARNING:** As the name implies, this makes your job killable. The cluster
> will kill your job (and add it back to the queue for later) if someone else is
> requesting for the same resources within their limit.

You are recommended to save epochs and make your program check if there are
previous epochs to resume from if you make use of this feature.

FAQ:
- Where do I specify the `--qos` thing? [Slurm Introduction](slurm.md)
- It does not quite work for me :(.
  Not a question but [Troubleshooting](troubleshooting.md).
