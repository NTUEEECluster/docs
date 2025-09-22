# Quick Start

> **⚠️ WARNING**: You are expected to go through at least the
> [Usage Guidelines](guideline.md) and [Cluster Overview](cluster.md).
> This quick start guide only lists basic commands. In addition, if you want
> advanced features, such as requesting more GPUs than default and connecting
> via IDEs, please read the relevant part of the repository.

- 1. Login

    `ssh your_name@login_IP` open your local commandline, terminal, MobaXterm,
    or Putty to remote into our login node. The IP is included in email we sent
    you, please check.

- 2. Request an interactive session on a compute node

    `sinfo` to check what GPU we offer.

    `module load Miniforge3` to load conda. Then `source activate` to activate
    the base environment of conda.

- 3. Request an instance for batch job

    Save the following as a file. You can use `vim` or `nano`, or any other
    Linux text editor.

    ```
    #!/bin/bash
    #SBATCH --job-name=job_name
    #SBATCH --gpus=6000ada:1
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
more by calling `storagemgr` in terminal. Please follow our instructions
[here](storaged.md) if you need them.

This quick start only serve as a cheatsheet. When you email us, we assume that
you have checked the entire documentation for your question and have knowledge
of all the relevant parts in this repository, including our rules as stated in
[Usage Guidelines](guideline.md).
