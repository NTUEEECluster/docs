# NTU EEE Cluster 02 Guide

# Condition of Access

By login to our cluster, you agree that you have fully read our guidelines and
agree to our usage terms, including but not limited to our fairshare and queuing
policy. Violating our [Usage Guidelines](guideline.md) with or without knowledge
will lead to account suspension and/or disciplinary actions.

If you still do not have access, please take a quick look through our
[Application Process](application.md).

## What is this?

This repository serves as a knowledge base to help users get started on the
cluster. A GPU cluster is a pool of GPU servers managed by a scheduler — your
jobs are queued and run on available nodes. Your data is synced across nodes,
so switching machines does not change your working directory.

The main use case is to run GPU training code, typically written in Python and
managed by [conda](conda.md). We DO NOT provide graphical access — only
[shell access via SSH](login.md). Execution of anything irrelevant to your
study/research at NTU is considered an offense.

It is possible to [use VSCode and PyCharm to access the cluster](debugging.md).
Other possibilities exist, but we cannot cover all of them.

Key limits to be aware of upfront:
- Login nodes: ~1.5 CPU cores and 8 GB RAM per user
- Home directory: 50 GB; `/tmp`: 4 GB; project storage via `storagemgr`
- 1 running job by default; interactive sessions max 2 hours and 1 GPU
- No `sudo` access under any circumstances
- Academic use only

## What is the bare minimum that I need to know?

We expect all users to be highly familiarized with our
[Usage Guidelines](guideline.md) and will act accordingly, **including issuing
warnings and/or account bans**.

We also highly recommend going through the [Cluster Overview](cluster.md) as we
have many customized functions that may be different from other clusters you
might have used in the past.

Refer to other parts of our documentation as necessary.

## List of Guides

To keep things manageable, we have split this guide into multiple files.

### Supported Workflow
- [Login to login node](login.md).
- Do simple setup on login node
  ([create your Conda env and install packages](conda.md))
- [Request GPU node(s)](slurm.md) to debug/run your code.

### All Guides
- I am super impatient. [Quick Start](quickstart.md)
- I have used a HPC before. What's the tl;dr? [Cluster Overview](cluster.md)
    - What are things that I should look out for?
      [Usage Guidelines](guideline.md)
    - How do I access more storage? [Storage Manager Usage](storaged.md)
- Having trouble logging in? [Login Guide](login.md)
    - How do I run IDEs and debug? [Debugging Guide](debugging.md)
    - How do I access GPU node(s)? [Slurm Introduction](slurm.md)
    - How do I setup my environments? [Setup Conda](conda.md)
    - How do I load/compile software with Lmod?
      [Slurm Introduction — Compiling from Source](slurm.md#Compiling-from-Source)
    - What GPUs do I have access to? [Cluster Overview](cluster.md)
- I am encountering an error. [Troubleshooting Guide](troubleshooting.md)

---

Written with <3 by the EEE Cluster Admins.
