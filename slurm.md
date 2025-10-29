# Slurm Introduction

- Why is Conda not installed? [Running a Program](#Running-a-Program)
- How do I just run my training script? [Running a Program](#Running-a-Program)
- I just want the example sh file to copy. [Here](sbatch-example.sh)

## Why Slurm

To put it simply, we are using Slurm to implement a queueing system that gets
you the node you need as soon as possible.

Generally speaking, for quicker access to a node, you can:
- **Lower your requirements**: Help us find a node that works for you faster.
- **Release your resources as soon as possible**: To keep it fair, we assign to
  users that have used less resources recently. Even if the GPU is idle, we
  cannot assign it to others if you reserved it.

## Running a Program

There are a few things to consider:
- How do I use program X? We use [Lmod](#Use-Lmod-to-load-softwarepackages).
- Why is `nvidia-smi` not working? You are on the login node, or you did not
  request GPU(s), see [Submit a Job](#Submit-a-Job).

### Use Lmod to load software/packages

> **TIP:** To use Conda, do `module load Miniconda3` or
> `module load Miniforge3` followed by `source activate`. Skipping
> `source activate` will cause errors while activating your environment.

We use Lmod to let you load the version of software that you request.
This helps us satisfy everyone's needs as some software conflict with each
other.

We offer necessary packages/libraries such as CUDA, GCC, and Miniconda. Please
do not attempt to install them yourself as it might mess up your environment
variables. *If you request for our help after making your home directory a weird
state, we will not assist in debugging but completely remove and recreate your
home directory on request.*

Please do not hesitate to let us know what package you need but not present in
`Lmod`. Your quickest way is to:
- Raise an issue that specifies the software and the version requirements.
- Send an email to us, specifying all the details for us to find the software
  you need.
- Do not email or chatting the admin's personal email, etc. Requests like this
  is difficult to track and therefore will not be entertained.

Here are some quick commands to get you started:

```sh
# Show all installed packages
$ module avail

# Check if a version of something is installed.
$ module spider <thing> # e.g. module spider Miniconda3

# Load the latest version.
$ module load <thing> # e.g. module load Miniconda3

# Load a specific version.
$ module load <thing>/<version> # e.g. module load Miniconda3/25.5.1-0

# Unload all the modules.
$ module purge
```

## Submit a Job

By default, you are on a login node (medium-sized VM with no GPUs) when you
first SSH into the IP we provide.

You need to specify the resources that you need before Slurm will attempt to
allocate it for you.

The recommended way is to use `sbatch` (an example file is available
[here](sbatch-example.sh)).

- To submit a job, do `sbatch <your file>`.
- When a node with GPU is ready, it will run your job.
- The output will be saved into a file in the current directory.

> **TIP:** Our cluster sees less utilization at night and over weekends. You may
> queue multiple jobs using `sbatch` and they will be run sequentially, even
> when you are not connected to the cluster.

Sometimes, it may be helpful to run a command and wait for the output. You can
do so using `srun`.

- Specify the flags like so: `srun <flags> <command>`.
- An example might be `srun --gpus v100:1 --time 1:00:00 nvidia-smi`.
- NTU VPN and NTUSECURE can be unstable. For your own sake, please avoid using
  `srun` for jobs that will take a lot of time. Disconnection will automatically
  lead to `srun` jobs' cancellation.

Please note that we have some [cluster-specific quirks](cluster.md#Slurm). You
are advised to check our documentation on it.

Here is a list of helpful flags, **only specify them if you need to change the
default value**:

| Flag         | Example                  | Description                                                                                                                                |
|--------------|--------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| `--time`     | `--time 00:01:00`        | Set the time limit of your job. Your job will be killed if it takes longer than the specified time. The format is `hours:minutes:seconds`. |
| `--pty`      | `--pty`                  | Typically used with `srun`. Create a terminal (helpful if you are running a shell). Remember to put `bash` at the end.                     |
| `--gpus`     | `--gpus example:2`       | Request `2` GPU of type `example`.                                                                                                         |
| `--output`   | `--output output-%j.log` | Set the filename that Slurm should put your program's output in. `%j` is replaced with your job ID.                                        |
| `--error`    | `--error output-%j.log`  | Set the filename that Slurm should put your program's error in.                                                                            |
| `--qos`      | `--qos rose`             | Specify what policy to run your job under. See [Cluster Overview](cluster.md#Slurm).                                                       |
| `--job-name` | `--job-name example`     | Set the name of the job in outputs such as `squeue` to make it easier to find.                                                             |

You can see the [FAQ](troubleshooting.md#Slurm) for more details. If you still
have other Slurm-specific questions, kindly ask the LLM of your choice for help.
There are plenty of resources out there and LLMs are very familiar with Slurm.

## Job Limits  

Your job will be mainly limit in following ways:
- You can only submit a interactive job that is within 2 hours and 1 GPU.
- You shall be able to run your `sbatch` or non-interactive `srun` job up to 48 hours. The max number of GPU you can use depends on the GPU model and your account category.
- `tmux` will be killed if you logout from the login nodes. We discourage usage of `tmux` to hold occupation of GPUs.

## Job Status Check

Use `squeue` in shell to check your job status.

Usually you will see status like: `mixed`, `idle`, `maint`, `down`, `drain`.
- `mixed` means some GPUs are used on the node.
- `idle` means no GPU on this node is being used.
- `maint` means there are active maintenance tasks and the node cannot be used.
- `down` means we are experiencing issues with this node and it goes offline
  unexpectedly.
- `drain` means there are active issues with the node and the node cannot be
  used.
