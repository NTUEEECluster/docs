# NTU EEE Cluster 02 Guide

> **NOTE:** We are still in beta testing. We DO NOT provide any stability
> guarantee. Check your emails frequently for updates.

## What is this?

This repository serves as a knowledge base to help users get started in
[utilizing a GPU cluster](basics.md).

The main use case of this cluster is to run your GPU training code, presumably
written in Python and managed by [conda](conda.md). We DO NOT provide graphical
access and provide only [shell access via SSH](login.md).

It is possible to [use VSCode and PyCharm to access the cluster](debugging.md).
Other possibilities exist, but we cannot cover all of them, so please adapt
instructions as necessary.

## What is the bare minimum that I need to know?

We expect all users to be highly familiarized with our
[Usage Guidelines](guideline.md) and will act accordingly, **including issuing
warnings and/or account bans**.

We also highly recommend going through the [Cluster Overview](cluster.md) as we
have many customized functions that may be different from other HPCs you have
used in the past.

Refer to other parts of our documentation as necessary.

## List of Guides

To keep things manageable, we have split this guide into multiple files.

### Supported Workflow
- [Login to login node](login.md).
- Do simple setup on login node
  ([create your Conda env and install packages](conda.md))
- [Request GPU node(s)](slurm.md) to debug/run your code.

### All Guides
- What is a GPU cluster? How is it different from running codes locally on my
  laptop/desktop? [Linux & Cluster Basics](basics.md)
- I have used a HPC before. What's the tl;dr? [Cluster Overview](cluster.md)
- What are things that I should look out for? [Usage Guidelines](guideline.md)
- Having trouble logging in? [Login Guide](login.md)
- How do I access GPU node(s)? [Slurm Introduction](slurm.md)
    - What GPUs do I have access to? [Cluster Overview](cluster.md)
- How to manage my storage space? [Storage Manager Usage](storaged.md)
- How to setup the environments? [Setup Conda](conda.md)
- How to run IDEs and debug? [Debugging Guide](debugging.md)
- I am encountering an error. [Troubleshooting Guide](troubleshooting.md)

---

Written with <3 by the EEE Cluster Admins.
