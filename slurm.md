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
- How do I use program X? We use [Lmod](#Lmod).
- Why is `nvidia-smi` not working? You are on the login node, see
  [Submit a Job](#Submit-a-Job).

### Lmod

> **TIP:** To use Conda, do `module load Miniconda3` or
> `module load Miniforge3`.

We use Lmod to let you load the version of software that you request.
This helps us satisfy everyone's needs as some software conflict with each
other.

Here are some quick commands to get you started:

```sh
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

Sometimes, it may be helpful to run a command and wait for the output. You can
do so using `srun`.

- Specify the flags like so: `srun <flags> <command>`.
- An example might be `srun --gpus v100:1 nvidia-smi`.
- This is not recommended if you are leaving your computer unattended. Your
  connection dying may lead to your job getting killed.

Here is a list of helpful flags, **only specify them if you need to change the
default value**:

| Flag         | Example                  | Description                                                                                                                                |
|--------------|--------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| `--time`     | `--time 00:01:00`        | Set the time limit of your job. Your job will be killed if it takes longer than the specified time. The format is `hours:minutes:seconds`. |
| `--pty`      | `--pty`                  | Typically used with `srun`. Create a terminal (helpful if you are running a shell).                                                        |
| `--gpus`     | `--gpus example:2`       | Request `2` GPU of type `example`.                                                                                                         |
| `--output`   | `--output output-%j.log` | Set the filename that Slurm should put your program's output in. `%j` is replaced with your job ID.                                        |
| `--error`    | `--error output-%j.log`  | Set the filename that Slurm should put your program's error in.                                                                            |
| `--qos`      | `--qos rose`             | Specify what policy to run your job under. See [Cluster Overview](cluster.md#Slurm).                                                       |
| `--mem`      | `--mem 123M`             | Request 123MB of RAM.                                                                                                                      |
| `--job-name` | `--job-name example`     | Set the name of the job in outputs such as `squeue` to make it easier to find.                                                             |

You can see the [FAQ](troubleshooting.md#Slurm) for more details.
