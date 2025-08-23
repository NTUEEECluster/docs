# NTU EEE Cluster 02 Guide

## What is this?

This repository serves as a knowledge base to help users get started in
utilizing a GPU cluster. Our GPUs are free for you to use, there is no GPU hour 
limit on you. But you will be limited by how many GPUs you can use at any given time.

The main use case of this cluster is to run your Python code based on conda and
you can do this either directly in shell, VSCode, or PyCharm. Other possibilities
exist, but we cannot cover all of them, so please adapt.

## Can I skip this guideline?

We highly recommend you DO NOT skip this guideline. Although we are based on Slurm, which is a common
job scheduler, we have many customized functions and limitations that you must be aware of. Once you login
to our cluster, we will assume you are aware of everything in this guideline.

## Supported Workflow
- Login to login node.
- Do simple setup on login node
  ([create your Conda env and install packages](conda.md))
- [Request GPU node(s)](slurm.md) to debug/run your code.

We expect all users to familiarize themselves with the
[Usage Guidelines](guideline.md) and will act accordingly.

## Maintenance and Stability
- We are still in beta testing. We do NOT guarantee 100% stability. 
- We heavily rely on emails to inform you our maintenance events. We are not responsible for any loss due to missing our email.
- Scheduled maintenance will be announced at least 3 days prior to the maintenance event. All running jobs will be killed once the maintenance event starts.

## Action that leads to warnings/account ban
- Heavily use login node to run your code.
-   It is Okay to run IDEs on the login node as long as you are only using it for text editing.
-   Running your code that consumes all the CPU and RAM resource on login node is considered abusing the login node.
- Running project-irrelevant code and virus.

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

## Still need help?

Send us an email (to the addresses used to inform you the password):

- What you have done: What commands have you ran on what machine?
    Please include the name of the node that you are connected to.
- What you expect to happen: What should you be seeing?
- What actually happens: What is the actual output?

Please provide as much relevant information as you can to help us debug your
issue. If you simply tell us something don't work and nothing more, you leave us nothing
to start with.


---

Written with <3 by the EEE Cluster Admins.
