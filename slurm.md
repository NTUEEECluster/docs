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
> `module load Miniforge3` followed by `source activate`. Do not skip `source activate`
> or you cannot activate your env correctly.

We use Lmod to let you load the version of software that you request.
This helps us satisfy everyone's needs as some software conflict with each
other.

We offer necessary packages/libraries such as CUDA, GCC, and Miniconda. Please
do not attempt to install them yourself as it might mess up your environment
variables. *If you cannot resolve it on your own, our solution to resolve this
would be completely remove and recreate your home directory.*

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

Sometimes, it may be helpful to run a command and wait for the output. You can
do so using `srun`.

- Specify the flags like so: `srun <flags> <command>`.
- An example might be `srun --gpus v100:1 --time 1:00:00 nvidia-smi`.
- NTU VPN and NTUSECURE can be unstable. For your own sake, please avoid using `srun` to
  keep your job running.

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

You can see the [FAQ](troubleshooting.md#Slurm) for more details. If you still questions, kindly ask GPT for help, it is very familiar with Slurm.

## Job Status Check

Use `squeue` in shell to check your job status.

Usually you will see status like: `mixed`, `idle`, `maint`, `down`, `drain`.
- `mixed` means some GPUs are used on the node.
- `idle` means no GPU on this node is used.
- `maint` means we are going to put down this node soon.
- `down` means we are experiencing issues with this node and it goes offline unexpectedly.
- `drain` means we have put it down manually due to some issues.

## Enforced CPU/RAM  
Slurm treats CPU cores and RAM as consumable resources. This means if you over-request these two, you can potentially block other's requests even if there are idle GPUs. Therefore, we enforce how many CPUs and
RAM you can get based on the number of GPUs you requested. This means `--mem` and `--cpus-per-task` no longer will take effects. So you don't have to specify these two parameters.

## Do not request a generic GPU  
We block requests that do not specify the GPU model because our cluster have various type of GPUs. By default Slurm will randomly assign you a GPU and this can result in consistency. Therefore, you must specify the 
GPU model when you are calling `srun` and `sbatch`. If you don't specify, you might see an error message from Slurm and/or your job requesting is forever stuck.

## `srun` and `salloc` cannot exceed 12 hours.  
We limit the hour limit on `srun` and `salloc` to stay below 12 hours. This is because both command does not auto exit even if your job is done. We want to release the nodes as fast as we can, so we enforce shorter time limit for these two commands. By default if you don't specify the time limit, it is the default time limit of the cluster, i.e., 48 hours. Meaning if you don't type `--time 12:00:00` or a lower number, your `srun` or `salloc` command will fail.

## Monitoring a long training session
If you want to check your training progresses, we highly recommend 3rd-party
packages like `Weight and Bias` or `tensorboard`. Slurm's output tend to lag behind the real
progress.
