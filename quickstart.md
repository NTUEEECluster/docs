# Quick Start

> **⚠️ WARNING**: You are expected to go through at least the
> [Usage Guidelines](guideline.md) and [Cluster Overview](cluster.md).
> This quick start guide only lists basic commands. In addition, if you want
> advanced features, such as requesting more GPUs than default and connecting
> via IDEs, please read the relevant part of the repository.

- 1. Login

    `ssh your_name@login_IP` from any terminal client (Linux/macOS Terminal,
    Windows MobaXterm/Putty/WSL). The login IP is in the email we sent. First
    login forces a password change — see [login.md](login.md) for the exact
    sequence.

- 2. Set up your environment on the login node

    `sinfo` shows what GPUs are available. To install Python packages, load
    Conda via Lmod first — see [Setting up Conda](slurm.md#setting-up-conda)
    for the full flow.

- 3. Submit a batch job

    Save the following as a file. You can use `vim` or `nano`, or any other
    Linux text editor.

    ```
    #!/bin/bash
    #SBATCH --job-name=job_name
    #SBATCH --gpus=pro6000:1        # replace type: a40, a6000, l40, 6000ada, pro6000
    #SBATCH --time=1:00:00
    #SBATCH --output=job-%j.out
    #SBATCH --error=job-%j.err

    module load Miniforge3

    source activate env_name

    python your_code.py
    ```

    Subsequently, `sbatch sbatch_script` in terminal to run it. You need to
    replace `env_name` and `your_code.py` with your own environments and Python
    code script.

Another thing you MUST know:

We **intentionally** limit your home disk quota to 50GB. However, you can have
more by calling `storagemgr` in terminal. See
[Using storagemgr](cluster.md#using-storagemgr) for instructions.

This quick start only serve as a cheatsheet. When you email us, we assume that
you have checked the entire documentation for your question and have knowledge
of all the relevant parts in this repository, including our rules as stated in
[Usage Guidelines](guideline.md).
