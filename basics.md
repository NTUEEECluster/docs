# Introduction to GPU Cluster

## What is a GPU cluster?

A GPU cluster is a pool of GPU servers managed by a scheduler. Your
training/inference jobs are queued and run on available nodes.

## What's in it for me?

You get access to dozens, sometimes hundreds, of shared GPUs without waiting
for a specific machine. Jobs run when resources free up. Your data is synced
across nodes, so switching machines does not change your working directory.

## How do I interact with the cluster?

You use a terminal and SSH into the cluster, then run commands remotely.
If you are new to terminals, read
[What are shell, bash, and terminal?](https://linuxcommand.org/lc3_lts0010.php).
If you are new to SSH, see
[What's SSH?](https://www.youtube.com/watch?v=v45p_kJV9i4).

## What limitations should I pay attention to?

Common limits that first-time users may miss:

- Login nodes: ~1.5 CPU cores and 8 GB RAM per user.
- [Storage is limited](cluster.md#Storage) and we can only afford a certain
  space per user:
  - Home Directory: 50GB
  - Project Directory: Created via `storagemgr` up to a certain quota (differs
    per user group)
  - `/tmp` Directory: 4GB (`/tmp` is local to you)
- Only 1 running job by default; others queue. Override QoS can bypass this,
  but jobs may be killed to free resources.
- You will not have `sudo` privileges in any circumstances.
- Interactive sessions: max 2 hours and 1 GPU. Batch jobs follow your GPU
  limits.
- [No GPU billing at the moment.](troubleshooting.md#cluster-billing)
- You must follow the [Usage Guidelines](guideline.md).
- Academic use only. You will face penalties for misuse of compute resources.
- Do not occupy GPU nodes with idle jobs (e.g., `sleep`) to "reserve" them.
  First violation is a warning; repeated violations may reduce GPU quota and
  eventually revoke access. See [Slurm FAQ](troubleshooting.md#Slurm).
