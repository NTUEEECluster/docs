# Introduction to GPU Cluster

## What is a GPU cluster?

A GPU cluster consists of many GPU servers. Your training/inference job gets
distributed automatically by a job scheduler. This allows us to serve more
users.

## What's in it for me?

Instead of waiting someone that is occupying your assigned GPU server to finish
their business, you can tell the cluster that you want to do something and wait
in a queue. As soon as one machine in the cluster starts idling, your
instruction starts running on this machine.

Your data is always synced on all GPU servers in the cluster. When you switch
between servers, your data stays the same.

## How do I interact with the cluster?

You need to be familiar with interacting Linux-based systems via terminals. See
this:
[What are shell, bash, and terminal?](https://linuxcommand.org/lc3_lts0010.php)

In other words, you type what you need via Terminals.This is different from
Windows where you click buttons to achieve what you want.

For our cluster, you need to SSH (i.e., remote connect) into our cluster and
instruct the servers to achieve what you want. Your laptop will essentially be a
remote control telling our servers what to do. Being a remote control takes much
less computer power, so your laptop doesn't need to be a cooking pan when
running your code. [What's SSH?](https://www.youtube.com/watch?v=v45p_kJV9i4)

## What limitations I should pay attention to?
 
- You are limited on the login node to use 1.5 cores of CPU and 8GB system memory.
- You are limited under your home directory at 50GB, project directory (created by yourself via `storagemgr` with adjustable quota up to a point), `/tmp` directory that is specifically limited to 4GB.
- You are limited to run 1 job. This means `MaxJobs=1` in Slurm contexts. Using overriding qos can go over this limit but your job can be killed by others.
- You will not have `sudo` priviledge in any circumstances.
- Interactive sessions can only run up to 2 hours and use 1 GPU. non-interactive `srun` and `sbatch` jobs only need to follow your actual GPU limit. See for yourself via `sacctmgr show assoc`.
- No billing so far, but we might employ such measurements if we see too much abuse.
- You shall only use your cluster account for your academic use. You will face penalties if being caught misusing the provided compute resources.
