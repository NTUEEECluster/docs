# NTU EEE Cluster 02 Guide

# Condition of Access

By login to our cluster, you agree that you have fully read our guidelines and
agree to our usage terms, including but not limited to our fairshare and queuing
policy. Violating our [Usage Guidelines](guideline.md) with or without knowledge
will lead to account suspension and/or disciplinary actions.

We **encourage** the use of AI coding agents (Claude Code, Codex, Cursor, etc.)
to flatten the learning curve and help you work more effectively on the
cluster. However, **we require** that you provide your agent with our
[AI-Facing Digest](agent.md) at the start of each session. This ensures the
agent enforces our guidelines, respects login-node resource limits, and
aligns its behavior with how the cluster is designed to be used. Should your
agents misbehave and leads to automatic account ban, etc. you will be fully
responsible for whatever action your agents have taken, i.e., what your agents
have done equals to what you have done.

If you still do not have access, please take a quick look through our
[Application Process](application.md). We currently only accept applications
during the application window that opens every semester — most applications
submitted within this window will be accepted. Applications outside the
window are strictly not accepted, due to the high maintenance effort
required to keep the cluster operational.

## What is this?

This repository serves as a knowledge base to help users get started on the
cluster. A GPU cluster is a pool of GPU servers managed by a scheduler — your
jobs are queued and run on available nodes. Your data is synced across nodes,
so switching machines does not change your working directory.

The main use case is to run GPU training code, typically written in Python and
managed by [conda](slurm.md#setting-up-conda). We DO NOT provide graphical
access — only [shell access via SSH](login.md). Execution of anything
irrelevant to your study/research at NTU is considered an offense.

It is possible to [use VSCode and PyCharm to access the cluster](debugging.md).
Other possibilities exist, but we cannot cover all of them.

For the current limits (CPU/RAM on login nodes, storage quotas, job/GPU
caps, supported QoS), see [Cluster Overview](cluster.md). Read it before
your first job.

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
  ([create your Conda env and install packages](slurm.md#setting-up-conda))
- [Request GPU node(s)](slurm.md) to debug/run your code.

### All Guides
- I am super impatient. [Quick Start](quickstart.md)
- I have used a HPC before. What's the tl;dr? [Cluster Overview](cluster.md)
    - What are things that I should look out for?
      [Usage Guidelines](guideline.md)
    - How do I access more storage?
      [Using storagemgr](cluster.md#using-storagemgr)
- Having trouble logging in? [Login Guide](login.md)
    - How do I run IDEs and debug? [Debugging Guide](debugging.md)
    - How do I access GPU node(s)? [Slurm Introduction](slurm.md)
    - How do I setup my environments?
      [Setting up Conda](slurm.md#setting-up-conda)
    - How do I load/compile software with Lmod?
      [Slurm Introduction — Compiling from Source](slurm.md#compiling-from-source)
    - What GPUs do I have access to? [Cluster Overview](cluster.md)
- I am encountering an error. [Troubleshooting Guide](troubleshooting.md)
- I am running an AI coding agent (Claude Code, Codex, Cursor, etc.) and want
  it to behave correctly on the cluster. [AI-Facing Digest](agent.md) — a
  condensed context document you can hand the agent so it enforces our
  guidelines and points back at full docs.

---

Written with <3 by the EEE Cluster Admins.
