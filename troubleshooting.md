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
- [I cannot use commands that I expect to be able to use](#Shell)
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

10. Q: Why my job is killed/aborted?

    A: Most of the time it is because you are using `srun` or `salloc` to hold
       your session on the compute node alive. If you close or get disconnected
       from the SSH sessions that directly invokes `srun` and/or `sallow`, the
       corresponding Slurm job will be closed. This is intentional and therefore
       we recommend you use `sbatch` to run your long training sessions because
       closing your SSH session won't kill jobs invoked by `sbatch`.

11. Q: Why I cannot specify more/less CPU/RAM?

    A: We enforce how many CPU/RAM you can get based on the actual hardware of
       each server. The rule of thumb is that if you request all the GPUs on one
       node, that you get all the CPU/RAM available to you. Otherwise, CPU/RAM
       is assigned to you proportionally. This prevents you consuming all the
       CPU/RAM on a GPU node while there are still unassigned GPUs that no one
       can use.
12. Q: Does the cluster have billing?

    A: 

## Still need help?

If you are sure nothing in this repository can help you, send us an email (to
the addresses used to inform you the password):

- What you have done: What commands have you ran on what machine?
    Please include the name of the node that you are connected to. This should
    be shown on the prompt (`username@THIS_IS_THE_THING_WE_NEED $`).
- What you expect to happen: What should you be seeing? What are you attempting
    to achieve?
- What actually happens: What is the actual output? If possible, include
    screenshots.

Please provide as much relevant information as you can to help us debug your
issue. **We need to be able to replicate the issue in order to fix it
reliably.**

If you simply tell us "X doesn't work" and nothing more, you leave us with
nothing to work with and we cannot do anything to help you.
