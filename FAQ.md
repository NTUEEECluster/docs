# FAQ

> Work through this page before emailing us. Ctrl-F for a few words of your error
> message, or browse by topic:
> [Login](#login) · [IDE](#ide) · [Storage](#storage) ·
> [Software](#software-modules) · [Starting a job](#starting-a-job) ·
> [Job status](#job-status) · [Still need help?](#still-need-help)
>
> Using an AI agent? Give it this page and [skill.md](skill.md).

## Login

See the [Quick Start](quickstart.md#1-log-in) first.

1.  Q: What do I do with the activation password? Why do I get "Password
       expired" or "Old password not accepted"?

    A: On first login, type the activation password twice (once to log in,
       once as the **current password**), then your new password twice. You
       are then logged out; reconnect with the new password.

2.  Q: Why have I been prompted to reset my password?

    A: Either your password was sent to you by email, which is not considered
       safe, or it has expired: passwords must be changed every few months.
       Change it the same way as above.

3.  Q: "ssh: connect to host &lt;IP&gt; port 22: Connection refused" or a
       timeout.

    A: Connect to NTUSECURE or the NTU VPN
       first. The cluster is not reachable from outside the NTU network. The
       VPN is run by NTU IT, not by us.

4.  Q: How do I SSH into a GPU node? I get "Connection refused" or
       "Connection to &lt;IP&gt; closed".

    A: You can only reach a compute node while you have a running job on it,
       and only through the login node:
       `ssh -J <username>@<login_IP> <username>@<node_name>`.
       "Connection closed" means you have no running job there, or the
       address is wrong.

5.  Q: I forgot my password.

    A: Email us from your school email; we reset it within 3 working days.

## IDE

See [Interactive job](slurm-guide.md#interactive-job) for debugging on a node.

1.  Q: Why does my IDE's remote connection fail?

    A: Check these before emailing us with the IDE's log:

       - **Disk quota exceeded** in your home, `/tmp`, or a custom install
         directory. The IDE may not show this; check its log and see
         [Storage](#storage).
       - **Memory limit exceeded**: several IDE instances, or backends left
         from earlier sessions (see Q2 and Q3).
       - **Corrupted install** after one of the above or a dropped connection:
         remove the IDE's remote install directory (for VS Code usually
         `~/.vscode-server`) and reconnect. Double-check the path before
         deleting it; it also holds your remote settings.
       - **First login not done**: log in once from a terminal first; IDEs
         cannot handle the forced password change.

2.  Q: My IDE is killed for running out of memory.

    A: Each user has 16 GB on a login node, and going over kills all your
       login-node processes. Look for leftover backends with `htop`, reduce
       extensions, and exclude folders with many or large files from
       indexing and file watching (VS Code: `files.watcherExclude`).

3.  Q: How do I clean up leftover IDE processes?

    A: SSH to the login node and run `pkill -u $USER -f <ide_name>` (e.g.
       `vscode-server`, `pycharm`).

4.  Q: Will IDE issues always be resolved?

    A: No. IDE problems are varied and hard to reproduce; support is
       best-effort.

## Storage

1.  Q: `Disk quota exceeded` although my home has plenty of space.

    A: Your `/tmp` (4 GB) or a project directory is full, often during a large
       `pip install`. Clear `/tmp` and redirect caches to a project directory,
       as the [Storage Guide](storage-guide.md#redirect-caches-required)
       requires.

2.  Q: My home directory is full. How do I fix it?

    A: Run `du -sh ~/* ~/.[!.]* | sort -h` to find what is large, then delete
       it or move it to a project directory
       ([Storage Guide](storage-guide.md#using-storagemgr)). Conda environments
       and IDE installs are common culprits.

## Software Modules

1.  Q: "conda: command not found" / Why is X not installed?

    A: Software is provided through Lmod: use `module avail`, `module spider`
       and `module load` (see [Software](slurm-guide.md#software)). Install
       Python packages yourself with `pip`/`conda` into your own environment
       (not `base`). If something needs `sudo` to install and is not in
       `module spider`, email us.

2.  Q: `nvidia-smi` is not found / I see no GPUs.

    A: The login node has no GPUs. Start a Slurm job; see the
       [Slurm Guide](slurm-guide.md).

3.  Q: Can I get `sudo`?

    A: No. Use modules, `pip`/`conda`, a container, or build from source;
       email us if none of these work.

4.  Q: Why is my tmux session killed when I disconnect?

    A: All your processes on a login node are killed once your last SSH
       session to it closes. Use a Slurm job for anything that must keep
       running.

5.  Q: "CUDA error: no kernel image is available for execution on the device"
       on `pro6000` or `rtx5090`.

    A: These are Blackwell GPUs (`sm_120`). Use a PyTorch/CUDA build for CUDA
       12.8 or newer (e.g. the `cu128` or later wheels). The driver supports
       CUDA 13.

6.  Q: Does the cluster support MATLAB? TensorFlow?

    A: MATLAB is not provided (licensing cost). TensorFlow can run but is not
       supported by us.

7.  Q: Can I compile my own packages?

    A: Yes, this is fully supported. Load the dependencies (e.g. `GCC`, `CUDA`)
       with `module load` and install into your own directory; see
       [Compiling from source](slurm-guide.md#compiling-from-source).

## Starting a Job

Read the [Slurm Guide](slurm-guide.md) first.

1.  Q: My submission was rejected. What does the error mean?

    | Error message (contains) | Fix |
    |---|---|
    | `salloc is disabled on this cluster` | Use `srun --pty <options> bash`. |
    | `Interactive jobs longer than 2 h are forbidden` | Use `--time` of 2:00:00 or less, or submit with `sbatch`. |
    | `Interactive jobs may only request 1 GPU` / `1 node` | Interactive (`srun` without a script) is 1 GPU, 1 node. Use `sbatch` for more. |
    | `Heterogeneous interactive jobs are not allowed` | Use an `sbatch` script. |
    | `--exclusive is not allowed` | Remove `--exclusive` (any form); request the GPUs/CPUs you need. |
    | `--cpus-per-tres is not allowed` / `--gpus-per-socket is not supported` / `tasks-per-<x> is not supported` | Remove the option; CPUs and memory are set per GPU automatically. |
    | `Untyped GPU requests are not accepted` | Name the model: `--gres=gpu:<model>:<N>`, e.g. `--gres=gpu:pro6000:4`. A model in `-C` alone is not enough. |
    | `Request one GPU model per job` | Use a single `--gres` with one model; submit separate jobs for different models. |
    | `The 'gpu_<N>g' VRAM-tier constraint has been removed` | Drop the `-C gpu_<N>g` and name the model in `--gres`. |
    | `Unknown GPU model` / `Unknown constraint` | Check the spelling against `sinfo -h -o "%G"` and the [Slurm Guide](slurm-guide.md#rules-checked-at-submission). |
    | `QOS '...' may not request GPU model` | Your project QoS only covers the models listed in the message. |
    | `GPU model '...' ... is not open to users yet` | That model is not available to users. |
    | `Changing ... of a submitted job is not allowed` / `Updating TimeLimit is not allowed` | Resources, QoS, account and time limit cannot be changed after submission. `scancel` the job and resubmit. |
    | `An unexpected error has occurred` | Email us the exact command and your sbatch script. |

2.  Q: How do I get a GPU?

    A: Name exactly one GPU model: `--gres=gpu:<model>:<N>`, e.g.
       `--gres=gpu:a40:1`. List the models with `sinfo -h -o "%G"`.

3.  Q: How much resources do I actually have access to?

    A: Your limits depend on your QoS; check them live with the commands in
       [Limits](slurm-guide.md#limits). Nodes and GPUs: see the
       [Cluster Guide](cluster-guide.md#look-up-nodes).

4.  Q: Why can I not choose my own CPU/RAM?

    A: Each GPU comes with a fixed **4 CPUs** and a model-specific amount of
       RAM, so every GPU on a node stays usable. `--mem` is overridden with a
       notice.

       - Do not set `-c`/`--cpus-per-task` on GPU jobs. A value other than 4
         per GPU makes every `srun` inside the job fail with
         `srun: fatal: cpus_per_task set by two different environment variables`.
         Remove the option, or add `unset SLURM_TRES_PER_TASK` before `srun`.

       - On `pro6000`, add `-C highmem` or `-C midmem` for more RAM per GPU on
         the nodes that have it.
       - CPU-only jobs (no GPU requested) run on the CPU nodes with 3 GiB of RAM
         per CPU; set the CPU count with `-c`.

5.  Q: `srun` is waiting / my job does not start.

    A: The resources are busy or you hit a limit. `squeue --me` shows the
       reason (see [Job Status](#job-status)); `sinfo` shows node states.

6.  Q: How do I check or cancel my job?

    A: `squeue --me` lists your jobs; `scancel <job_id>` cancels one.

7.  Q: My per-user GPU limit is too small.

    A: Submit with `--qos=override-limits-but-killable` to use idle GPUs
       beyond your limit at no cost. These jobs can be preempted (requeued)
       when others need the GPUs, so checkpoint and resume. See
       [Limits](slurm-guide.md#limits).

8.  Q: Can I hold a node with `sbatch` to get around the interactive limit?

    A: No. Batch jobs must actively use their GPUs. Jobs idling on GPUs are
       audited; repeated cases lose GPU access.

9.  Q: Does the cluster have billing?

    A: Not in money. GPU jobs use Service Units (SU) against a monthly
       per-user quota that resets on the 1st; CPU-only jobs cost nothing.
       Faculty projects have their own budget. See
       [Billing](slurm-guide.md#billing).

## Job Status

1.  Q: Why is my job pending?

    A: The `REASON` column of `squeue --me` explains it; the common reasons
       are listed in [Job status](slurm-guide.md#job-status).

2.  Q: Why are some nodes not `idle`, `alloc` or `mix`?

    A: They are temporarily offline, drained or under maintenance. Running
       jobs are allowed to finish; jobs that would overlap scheduled
       maintenance wait until it is over.

3.  Q: "Detected 1 oom_kill event ... Some of the step tasks have been OOM
       Killed." How do I get more memory?

    A: RAM comes with the GPUs (see [Q4](#starting-a-job)); `--mem` is
       ignored. Request more GPUs, or on `pro6000` add `-C highmem`. If it
       still runs out, look for leaks (e.g. tensors kept on the host across
       steps).

4.  Q: Why was my job killed?

    A: Usually an interactive `srun` whose terminal closed or lost connection;
       that ends the job. Use `sbatch` for long runs. Jobs are also stopped at
       their time limit.

## Still need help?

Before emailing, make sure that:

1. no entry here answers it (or say why the answer does not apply);
2. it is cluster-specific (it works elsewhere) and not a general Linux question;
3. it is not a known issue in the login message or announcements;
4. it is not a request for more resources.

Then email us as described in [Support](terms-n-conditions.md#8-support).
