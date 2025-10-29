# The Big List of Questions

This file consists of a lot of checklists to help resolve issues that you might
be seeing.

If you are seeing an error, try doing Ctrl-F on this file to see if it has been
asked before.

Or you can through GPT this readme and let it figure out for you. We strongly
encourage you to do your research about your issue before ask us. It is totally
normal that a HPC cluster have a steeper learning curve compared to using a
private barebone server.

If there are no specific errors that you are seeing, please choose the closest
category:
- [I cannot login, I do not see the "example@login-1$"](#Login)
- [My IDE is not working!](#IDE)
- [I cannot use commands/applications that I expect to be able to use](#Shell)
- [How do I get Slurm to do X](#Slurm)
- [Still need help?](#Still-need-help)

## Login

If you have not done so, please follow the [login guide](login.md) carefully.

1.  Q: What should I do with the default password sent to me?

    A: The default password sent to you is to help system recognize it is you
    logging into your own account. Typically, when you attempt to login the
    first time, you will be prompted to enter your password, and it is this
    default password. Then, the system will prompt you to enter the
    `current password`, which is still the default password!!! Next, the system
    will prompt you to enter the `new password` and let you confirm again. Once
    all 4 steps are done, you will be logged out. Then you can try to login
    with your new password.

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

6.  Q: I forgot my password. (Forgot Password)

    A: Send us an email from your school email and we will reset it for you
       within 3 business days.

## IDE

1.  Q: Why does my IDE remote connection to the cluster not work?

    A: We have seen the following reasons for IDEs not working in the cluster.
       Please check whether each one applies to you before contacting the
       administrator with the IDE's error log.

       - **Disk Quota Exceeded**: Your IDE is not able to install itself because
         your home directory is full. See [this entry](#home-quota-cleanup) for
         more details.
       - **Memory Limit Exceeded**: If you have multiple instances of your IDE
         running, you may run out of memory. This sometimes apply even if you
         have closed your IDE as some IDEs do not clean up properly. See the
         question below for more details.
       - **Corrupted IDE Files**: Your IDE files might be corrupted due to any
         of the above happening or just bad network connection. You can
         typically delete your `.cache` folder with `rm` to get your IDE to
         reinstall itself. Note that this may delete your IDE settings so use
         with caution.

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

## Shell

1.  Q: Why is X not installed? Why am I getting "conda: command not found"?

    A: We use Lmod to manage software versions and you need to run
       `module load` to load the correct version. See
       [here](slurm.md#Use-Lmod-to-load-softwarepackages) for more details.

       If the program you need requires `sudo` to install and is NOT listed
       under `module spider`, send us an email and we will install it for you.

       Notice that we do not cover python packages using Lmod. You should
       install your own python packages, like torch, by yourself. `pip install`
       and `conda install` do not require sudo priviledge and you can install
       whatever python package you want to your personal envs (not base env).

2.  Q: Why do I not see any GPUs? Why am I getting "Command 'nvidia-smi' not
       found, but can be installed with: ..."

    A: By default, the machine you SSH into is a login node (medium-sized VM
       without GPUs). You will need to use Slurm to start a job. See
       [Slurm Introduction](slurm.md) for more details.

3.  Q: Can I get `sudo`? Why am I getting "&lt;user&gt; is not allowed to run
       sudo on login-1"?

    A: To help ensure the security of the cluster, we unfortunately cannot give
       sudo access to our users. Try running your command without `sudo` and let
       us know if you need something done and we will try to accommodate to your
       request. It is also preventing you from catastrophically destroy important
       components of the cluster, e.g., others' important data.

       Typically, [modules](slurm.md#Lmod) will have the program that you need
       installed.

4.  Q: Why do I keep getting `Disk quota exceeded` despite my home directory
       having plenty of space?

    A: Disk quota exceeded may also occur when your project directory or `/tmp`
       fills up. This might happen if you are installing a big package using
       `pip`. If the issue persists after clearing your `/tmp`, try setting your
       `TMPDIR` to a directory with more space.

<a id="home-quota-cleanup" />

5.  Q: I actually ran out of disk quota in my home directory. How do I solve
       this?

    A: You can do `ls -a` to see all your files and run `du -sh ./* ./.*` to
       view the sizes of individual directory/file.

       You are then advised to either delete them or move them into a
       [project folder](storaged.md).

6.  Q: Why is my tmux session getting killed when I disconnect?

    A: We have deployed [automatic process cleanup](cluster.md#process-cleanup).

       It is triggered when all your connections to a login node is closed. We
       have done so as we found that users often leave lingering processes
       without realizing and causing issues for themselves.

       This can be worked around but doing so is unsupported and cluster admins
       will ignore support requests that arise from doing so. You are advised to
       start a Slurm job instead if you need a task to continue running even
       after you disconnect.

## Slurm

1.  Q: How do I actually run my program using Slurm?

    A: We have a guide [here](slurm.md).

2.  Q: How do I check the status of my job? How do I know if my job is done?

    A: You can run `squeue`. If you want to see it update somewhat in realtime,
       you can run `watch squeue`.

3.  Q: Why is `srun` not responding? Why is `sbatch` failing?

    A: The cluster may not be able to fulfill your request at this time. This
       may be because you requested too much resources (resources that the
       cluster has) or the cluster is busy fulfilling other people's request.

       You can run `sinfo` to see the status of the cluster and `squeue` in a
       new terminal will show the reason your job is currently being postponed.

4.  Q: How much resources do I actually have access to?

    A: See [Cluster Overview](cluster.md#Slurm).

5.  Q: I made an error submitting my job. How do I cancel it?

    A: You can see the job ID by doing `squeue`. You can then use
       `scancel <job_id>` (e.g. `scancel 123`) to cancel the job.

6.  Q: I cannot see any GPUs even when I run a job. How do I get access to GPU?

    A: You can access a GPU by using the `--gpus` flag when submitting a job.
       You need to specify the type of GPU you want in the following format:
       `--gpus example:1` where `example` is the type of the GPU and `1` is the
       number of GPU you want. You can view a list of available GPUs
       [here](cluster.md#Slurm).

7.  Q: The number of GPUs assigned is not enough. How do I get access to more?

    A: We allow users to access GPUs beyond their limits as long as you agree to
       allow your jobs to be killed. To acknowledge this, use
       `--qos override-limits-but-killable` when submitting your job.

       When idle resources are available, we will let your job be run on it but
       we will kill your job when those resources are needed by someone else
       that is not using resources outside their limit.

       You are recommended to save epochs and make your program check if there
       are previous epochs to resume from if you make use of this feature.

8.  Q: Why do I see "slurmstepd-gpu-6000ada-1: error: Detected 1 oom_kill event
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

9.  Q: Why my job is killed/aborted?

    A: Most of the time it is because you are using `srun` or `salloc` to hold
       your session on the compute node alive. If you close or get disconnected
       from the SSH sessions that directly invokes `srun` and/or `salloc`, the
       corresponding Slurm job will be closed. This is intentional and therefore
       we recommend you use `sbatch` to run your long training sessions because
       closing your SSH session won't kill jobs invoked by `sbatch`.

10. Q: Why I cannot specify more/less CPU/RAM?

    A: We enforce how many CPU/RAM you can get based on the actual hardware of
       each server. The rule of thumb is that if you request all the GPUs on one
       node, that you get all the CPU/RAM available to you. Otherwise, CPU/RAM
       is assigned to you proportionally. This prevents you consuming all the
       CPU/RAM on a GPU node while there are still unassigned GPUs that no one
       can use.

11. Q: Does the cluster have billing?

    A: No. You might notice `billing` if you look into the Slurm configuration
       but we are only using it for reporting purposes currently. Thanks to the
       generous sponsor of multiple organizations, we are running this service
       free of charge for eligible users.

       While there is a non-zero chance of this changing in the future, we will
       inform you should that be the case.

## Still need help?

If you are sure nothing in this repository can help you, send us an email (to
the addresses used to inform you the password):

- What you have done: What commands have you ran on what machine?
    Please include the name of the node that you are connected to. This should
    be shown on the prompt (`username@THIS_IS_THE_THING_WE_NEED $`).
- What you expect to happen: What should you be seeing? What are you attempting
    to achieve?
- What actually happens: What is the actual output? If possible, include
    screenshots. If you are using an IDE, please include relevant logs from your
    IDE.

Please provide as much relevant information as you can to help us debug your
issue. **We need to be able to replicate the issue in order to fix it
reliably.**

If you simply tell us "X doesn't work" and nothing more, you leave us with
nothing to work with and we cannot do anything to help you.

For emails request more resources. Simple answer is No unless you can buy us the actual hardware to
upgrade our servers. And, the more honest version is, your system admins are trying quite hard to buy
you these "free lunch" you can enjoy right now. We understand you have your personal project or whatever, then,
again, we have another few hundred people having the same needs as you. Why are you superior than others?

While we try to stay nice to whoever email us and be helpful and timely. The system admin, 
around 2-3 people, will have their temper on you if you keep asking simple and already-answered questions.
