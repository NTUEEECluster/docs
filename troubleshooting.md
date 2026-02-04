# The Big List of Questions

> NOTE: If you have been directed to this document, it is likely you did not
> fulfill the prerequisites as stated in
> [Support Checklist](#Support-Checklist). Please run through the document
> again.

## How to use this document?

- Try Ctrl-F on this file using a few keywords in your error message.
- Browse by category:
  - [I cannot login, I do not see the "example@login-1$"](#Login)
  - [My IDE/VSCode/PyCharm is not working!](#IDE)
  - [I ran out of storage!](#Storage)
  - [My commands/applications are not functioning as
     expected](#Software-Modules)
  - [I cannot use commands/applications that I expect to be able to use](#Shell)
  - [I ran into issues starting a job](#Starting-a-Job)
  - [I ran into trouble after starting my job](#Job-Status)
- Use AI: Copy this document and our [AI-facing digest](copy-me-to-AI.md) to
  debug your specific issue.
- [Still need help?](#Still-need-help)

We are constantly restructuring and adding to this document to best answer our
latest questions so please check back often.

## Login

If you have not done so, please follow the [login guide](login.md) carefully.

1.  Q: What should I do with the activation password sent to me?

    A: The activation password sent to you is to help system recognize it is you
       logging into your own account. Typically, when you attempt to login the
       first time, you will be prompted to enter your password, and it is this
       activation password. Then, the system will prompt you to enter the
       `current password`, which is **still the activation password**! Next, the
       system will prompt you to enter the `new password` and let you confirm
       again. Once all 4 steps are done, you will be logged out. Then, you can
       try to login with your new password.

       For a more detailed guide, read the [login guide](login.md) where we
       include examples.

2.  Q: I am getting "ssh: connect to host &lt;IP&gt; port 22: Connection
       refused".

    A: Please check that you are connected to the
       [NTU VPN](https://vpngate-student.ntu.edu.sg). The cluster is not
       accessible outside the VPN.

3.  Q: How do I SSH into a GPU node? I am getting "ssh: connect to host
       11.11.11.X port 22: Connection refused"

    A: GPU nodes are not accessible from outside except via the login node. To
       access a GPU node, ensure you have a running job at the GPU node and
       route SSH through the login node using the following command:
       `ssh -J <username>@<login_node_IP> <node_you_want_to_access>`

       An example of the command is `ssh -J example@127.0.0.1 gpu-v100-1`.
       Your connection will be refused if no jobs are running on the specified
       node.

4.  Q: I am just getting "Connection to &lt;IP&gt; closed."

    A: Check that you are entering the right IP. This typically means you do not
       have access to the node that you are trying to connect to.

       If you are connecting to a GPU node, make sure you have a running job on
       the node.

5.  Q: I keep getting "Password expired. Change your password now." or "Password
    change failed. Server message: Old password not accepted."

    A: You need to type your original password (the one sent to you) twice when
       logging in. The first time is to SSH and the second time is to start
       changing your password.

6.  Q: Why have I been prompted to reset my password?

    A: There are two main reasons you may be requested to reset your password:

       - **Your password has been provided by the admin**. As we send your
         password through email, it is not considered safe and we require you to
         reset your password.
       - **Your password has expired.** We have a password expiry policy that
         requires you to reset your password every few months.

7.  Q: I forgot my password. (Forgot Password)

    A: Send us an email from your school email and we will reset it for you
       within 3 business days.

## IDE

Please read our [debugging/IDE guide](debugging.md) if you have not done so. It
contains step-by-step guide in making sure it works.

1.  Q: Why does my IDE remote connection to the cluster not work?

    A: We have seen the following reasons for IDEs not working in the cluster.
       Please check whether each one applies to you before contacting the
       administrator with the IDE's error log.

       - **Disk Quota Exceed**: Your IDE is not able to install itself because
         either your home or your `/tmp` directory is full, or it is because
         the installation directory (if you customize it to somewhere else) is
         full. The Disk Quota Exceeded error might not appear directly in your
         VSCode UI; you will have to check relevant logs. See
         [this entry](#home-quota-cleanup) for more details.
       - **Memory Limit Exceeded**: If you have multiple instances of your IDE
         running, you may run out of memory. This sometimes apply even if you
         have closed your IDE as some IDEs do not clean up properly. See the
         question below for more details.
       - **Corrupted IDE Files**: Your IDE files might be corrupted due to any
         of the above happening or just bad network connection. You can
         typically delete your `.cache` folder with `rm` to get your IDE to
         reinstall itself. Note that this may delete your IDE settings so use
         with caution.
       - **Reinstall IDE Files**: We suggest you to remove your IDE's
         installation directory entirely if you are really lost on this.
         However, please be aware that the `rm` command in linux are dangerous
         so please make sure you only remove the relevant directories. For
         example, for VSCode, the remote installation path is USUALLY
         `~/.vscode-server`. Note that this can change so please do your own
         search to determine where is the true installation path.

2.  Q: I am triggering out-of-memory even though I am not using too many
       extensions!

    A: Out of memory issues can be triggered by a few reasons:

       - You have lingering IDE backends that did not terminate when you
         disconnected. You may use commands like `htop` and `bpytop` to see the
         processes that are running. If this applies to you, a question below
         covers how to clean it up.
       - You might be running too many extensions. Each extension takes up some
         RAM.
       - PyCharm and VSCode indexes and/or watches folders. This causes them to
         use significant RAM if you have a lot of small files or a few big
         files. Please configure your IDE to ignore these folders. In VSCode,
         this can be done using the File Watcher: Exclude setting.

3.  Q: How do I clean up all my running IDEs?

    A: You can try to kill your IDE related processes by manually SSH-ing into
       the login node and using commands like `pkill -u your_name -f ide_name`.
       This kills processes under your name and has the keyword `ide_name`. For
       pycharm, it can be `pycharm`.

4.  Q: Is it guaranteed that IDE related issues will be resolved?

    A: Sadly, no. It is at our best effort, but due to the diversity nature of
       IDE-related bugs and issues. It is not quite possible for us to guarantee
       that such issues can be resolved.

## Storage

1.  Q: Why do I keep getting `Disk quota exceeded` despite my home directory
       having plenty of space?

    A: Disk quota exceeded may also occur when your project directory or `/tmp`
       fills up. This might happen if you are installing a big package using
       `pip`. If the issue persists after clearing your `/tmp`, try setting your
       `TMPDIR` to a directory with more space.

<a id="home-quota-cleanup" />

2.  Q: I actually ran out of disk quota in my home directory. How do I solve
       this?

    A: You can do `ls -a` to see all your files and run `du -sh ./* ./.*` to
       view the sizes of individual directory/file.

       You are then advised to either delete them or move them into a
       [project folder](storaged.md).

## Software Modules

1.  Q: Why is X not installed? Why am I getting "conda: command not found"?

    A: We use Lmod to manage software versions and you need to run
       `module load` to load the correct version. See
       [here](slurm.md#Use-Lmod-to-load-softwarepackages) for more details.

       If the program you need requires `sudo` to install and is NOT listed
       under `module spider`, send us an email and we will install it for you.

       Notice that we do not cover python packages using Lmod. You should
       install your own python packages, like torch, by yourself. `pip install`
       and `conda install` do not require sudo privilege and you can install
       whatever python package you want to your personal envs (not base env).

2.  Q: Why do I not see any GPUs? Why am I getting "Command 'nvidia-smi' not
       found, but can be installed with: ..."

    A: By default, the machine you SSH into is a login node (medium-sized VM
       without GPUs). You will need to use Slurm to start a job. See
       [Slurm Introduction](slurm.md) for more details.

3.  Q: Can I get `sudo`? Why am I getting "&lt;user&gt; is not allowed to run
       sudo on login-1"?

    A: No. For security and stability, users are not granted sudo. If a required
       package isn't available via [`module load`](slurm.md#Lmod) or standard
       user-space installation (conda/pip), email us.

4.  Q: Why is my tmux session getting killed when I disconnect?

    A: We have deployed [automatic process cleanup](cluster.md#process-cleanup).

       It is triggered when all your connections to a login node is closed. We
       have done so as we found that users often leave lingering processes
       without realizing and causing issues for themselves.

       This can be worked around but doing so is unsupported and cluster admins
       will ignore support requests that arise from doing so. You are advised to
       start a Slurm job instead if you need a task to continue running even
       after you disconnect.

5.  Q: Does the cluster support MATLAB?

    A: No, there are no plans to support MATLAB currently as we prioritize
       PyTorch frameworks. MATLAB requires a license which will cost too much
       for the benefit of a few users. Procuring such licenses will divert
       funding that can otherwise be used to procure more hardware. We will
       revisit this on only if it can be demonstrated that there is a lot of
       demand.

6.  Q: Does the cluster support TensorFlow?

    A: While we do provide all the resources required to run TensorFlow (e.g.
       CUDA), we do not provide end-user support for running the relevant
       programs. We assume that you know what you are doing if you do so.

7.  Q: Can I compile my own packages?

    A: Yes. This is fully allowed and supported. Please check the available
       software list with `module avail`; some software may only be visible via
       `module spider`. All software is locally compiled and has dependencies,
       so you may need to load items such as `GCCcore` via Lmod.

## Starting a Job

If you have not done so, please read the [Slurm guide](slurm.md).

1.  Q: How do I check the status of my job? How do I know if my job is done?

    A: You can run `squeue`. If you want to see it update somewhat in realtime,
       you can run `watch squeue`.

2.  Q: Why is `srun` not responding? Why is `sbatch` failing?

    A: The cluster may not be able to fulfill your request at this time. This
       may be because you requested too much resources (resources that the
       cluster has) or the cluster is busy fulfilling other people's request.

       You can run `sinfo` to see the status of the cluster and `squeue` in a
       new terminal will show the reason your job is currently being postponed.

3.  Q: How much resources do I actually have access to?

    A: See [Cluster Overview](cluster.md#Slurm).

4.  Q: I made an error submitting my job. How do I cancel it?

    A: You can see the job ID by doing `squeue`. You can then use
       `scancel <job_id>` (e.g. `scancel 123`) to cancel the job.

5.  Q: I cannot see any GPUs even when I run a job. How do I get access to GPU?

    A: Use the `--gpus` flag when submitting a job.

       You will need to specify the type by doing `-C gpu --gpus 1` (any GPU) or
       `--gpus example:1`. You can view a list of available GPUs and other
       combinations of request [here](cluster.md#Slurm). Keep in mind your
       request can be fulfilled faster if you relax your constraint (e.g.
       specifying `-C gpu` instead of `-C gpu_48g` or `-C gpu_48g` instead of
       `6000ada:1`).

6.  Q: The number of GPUs assigned is not enough. How do I get access to more?

    A: We allow users to access GPUs beyond their limits as long as you agree to
       allow your jobs to be killed. To acknowledge this, use
       `--qos override-limits-but-killable` when submitting your job.

       When idle resources are available, we will let your job be run on it but
       we will kill your job when those resources are needed by someone else
       that is not using resources outside their limit.

       You are recommended to save epochs and make your program check if there
       are previous epochs to resume from if you make use of this feature.

7.  Q: Can I occupy a node via `sbatch` to workaround the interactive job time
        limit?

    A: No. This is strictly prohibited. If you request a node via `sbatch`, you
       are expected to run GPU-intensive compute (this includes LLM servers).
       It is okay if your server is actively using GPUs; it is not okay to keep
       a job running with near-zero utilization for extended periods. We
       monitor for this behavior. Repeated violations after warnings may result
       in temporary GPU quota revocation.

8.  Q: Why I cannot specify more/less CPU/RAM?

    A: We enforce how many CPU/RAM you can get based on the actual hardware of
       each server. The rule of thumb is that if you request all the GPUs on one
       node, that you get all the CPU/RAM available to you. Otherwise, CPU/RAM
       is assigned to you proportionally. This prevents you consuming all the
       CPU/RAM on a GPU node while there are still unassigned GPUs that no one
       can use.

<a id="cluster-billing" />

9.  Q: Does the cluster have billing?

    A: No. You might notice `billing` if you look into the Slurm configuration
       but we are only using it for reporting purposes currently. Thanks to the
       generous sponsor of multiple organizations, we are running this service
       free of charge for eligible users.

       While there is a non-zero chance of this changing in the future, we will
       inform you should that be the case.

## Job Status

1.  Q: Why is my job not running but pending?

    A: There are several reasons Slurm may not allocate resources immediately,
       and the `REASON` field in `squeue` usually explains it. For example, if
       you hit the MaxJobs=1 limit, only one job will run and the rest will be
       pending with `QOSMaxJobsPerUserLimit`. Another common case is low
       priority due to FairShare after heavy usage; your job can be held
       temporarily even when there are idle nodes.

2.  Q: Why are certain nodes in "weird" states different from idle, alloc, or
        mix?

    A: Minor maintenance, such as powering down a single compute node or
       rebooting machines due to NVIDIA driver updates, will not be announced
       to keep troubleshooting fast. These minor fixes should not affect your
       jobs, and if you have running jobs on those nodes, we will wait until
       they complete. For major maintenance events, we reserve nodes in
       advance. If your job overlaps with a major maintenance window, Slurm
       will automatically place it on hold until maintenance is completed.

3.  Q: Why do I see "slurmstepd-gpu-6000ada-1: error: Detected 1 oom_kill event
       in StepId=123.0. Some of the step tasks have been OOM Killed."? How do I
       request more memory?

    A: We currently tie how many GPUs you requested directly to CPU and RAM
       given to you. Therefore, you cannot specify the number of CPU and RAM by
       yourself. While there are limitations in this design, it comes with
       benefits that all GPUs in a node can be assigned to users without idling.
       The current strategy will give you the same amount of RAM as the total
       VRAM of the GPUs that you have requested.

       If that still OOMs, it is likely your code have a memory leak. For
       example, opening a file in Python and never closing it will result in
       a resource leak.

4.  Q: Why my job is killed/aborted?

    A: Most of the time it is because you are using `srun` or `salloc` to hold
       your session on the compute node alive. If you close or get disconnected
       from the SSH sessions that directly invokes `srun` and/or `salloc`, the
       corresponding Slurm job will be closed. This is intentional and therefore
       we recommend you use `sbatch` to run your long training sessions because
       closing your SSH session won't kill jobs invoked by `sbatch`.


## Still need help?

### Support Checklist

Here is an important checklist of things to check before sending us an email:

- You have checked this page to ensure that nothing here can help you.
- You have ensured that this issue is due to the cluster (i.e. it works on my
  computer!)
- You have confirmed this is a cluster-specific issue and not a general Linux
  one. Please attempt to resolve it yourself with the help of the internet or
  LLM of your choice.
- You have confirmed that this is not related to recent issues that are already
  known. (This will only add on to our workload when it is already known.)
  - Check MOTD (the message when you login using SSH)
  - Check your email for service announcements
- You are not just requesting for more resources. This repository contains
  all the ways to do so that we support, due to funding sources' constraints.
  - Storage: See [Directories in cluster.md](cluster.md#Directories)
  - GPUs: See [Slurm in cluster.md](cluster.md#Slurm)
  - If you are the point of contact for an entity contributing hardware, we can
    help in negotiating more resources on your behalf. Please send us an email.

### Email Checklist

If you have gone through the above checklist, send us an email (to the addresses
used to inform you the password):

- What you have done: What commands have you ran on what machine?
    Please include the name of the node that you are connected to. This should
    be shown on the prompt (`username@THIS_IS_THE_THING_WE_NEED $`).
    Please also include debugging steps that you have taken so we do not suggest
    what you have already tried.
- What you expect to happen: What should you be seeing? What are you attempting
    to achieve?
- What actually happens: What is the actual output? If possible, include
    screenshots. If you are using an IDE, please include relevant logs from your
    IDE.

Please provide as much relevant information as you can to help us debug your
issue. **We need to be able to replicate the issue in order to fix it
reliably.**

Here are a few themes of emails that we cannot help with:
- If you simply tell us "X doesn't work" and nothing more, you leave us with
  nothing to work with and we cannot do anything to help you.
- We are also unable to entertain emails requesting for more resources, as our
  constraints are due to hardware limitation. Please only contact us if you are
  able to contribute hardware. We are almost constantly in the process of
  procuring more hardware so please be patient.

We try to stay nice, professional, helpful, and timely to emails. However,
we may not respond kindly to emails asking questions that are easily answered
online or already answered in this document.
