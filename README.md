# NTU EEE Cluster 02 Guide

## Supported Workflow
- Login to login node.
- Do simple setup on login node
  ([create your Conda env and install packages](conda.md))
- [Request GPU node(s)](slurm.md) to debug/run your code.

We expect all users to familiarize themselves with the
[Usage Guidelines](guideline.md) and will act accordingly.

## Table of Content

To keep things manageable, we have split this into multiple files.

Pick the most relevant guide:

- I have used a HPC before. What's the tl;dr? [Cluster Overview](cluster.md)
- Having trouble logging in? [Login Guide](login.md)
- How do I access GPU node(s)? [Slurm Introduction](slurm.md)
- How to setup the environments? [Setup Conda](conda.md)
- What GPUs do I have access to? [Cluster Overview](cluster.md)
- How to run IDEs and debug? [Debugging Guide](Debugging.md)
- I am encountering an error. [Troubleshooting Guide](troubleshooting.md)

## What is this?

This repository serves as a simple knowledge base to help users get started in
utilizing a GPU cluster.

The main use case of this cluster is to run your Python code based on conda and
you can do this either directly in shell, VSCode, or PyCharm. Other possibilities
exist, but we cannot cover all of them, so please adapt as necessary. If you want
to use the cluster for non-AI workloads, like CFD, simulation, etc. and require
extra software that we currently do not offer, let us know to see if your demand
can be met.

## Still need help?

Send us an email from your email to our email (it should be the email that you
received your credentials from) with the following details:

- What you have done: What commands have you ran on what machine?
    Please include the name of the node that you are connected to.
- What you expect to happen: What should you be seeing?
- What actually happens: What is the actual output?

Please provide as much relevant information as you can to help us debug your
issue.



---

Written with <3 by the EEE Cluster Admins.
