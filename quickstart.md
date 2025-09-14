# Quick Start

> **⚠️ WARNING**: you are supposed to go through all contents of this
> documentation. This quick start guide only lists basic commands. If you want
> advanced features, like changing QoS, debug via IDEs, please read this
> repository entirely.

- 1. Login

    `ssh your_name@login_IP` open your local commandline, terminal, MobaXterm,
    or Putty to remote into our login node. The IP is included in email we sent
    you, please check.

- 2. Request an interactive session on a compute node

    `sinfo` to check what GPU we offer.

    `srun --pty --gpus 6000ada:1 --time 08:00:00 bash` to request 1 GPU.

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
more by calling `storagemgr` in terminal. `storagemgr` has a very simple and
self-explained UI, please follow the instructions in it to request more disk
space.

This quick start only serve as a cheatsheet. When you email us, we still assume
you have checked the entire documentation and have full knowledge of how the
cluster works and what the rules are.
