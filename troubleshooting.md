# The Big List of Questions

This file consists of a lot of checklists to help resolve issues that you might
be seeing.

If you are seeing an error, try doing Ctrl-F on this file to see if it has been
asked before.

If there are no specific errors that you are seeing, please choose the closest
category:
- [I cannot login, I do not see the "example@login-1$"](#Login)
- [I cannot use commands that I expect to be able to use](#Shell)
- [How do I get Slurm to do X](#Slurm)

If none of the above helps, send us an email with the following details:
- What you have done: What commands have you ran?
- What you expect to happen: What should you be seeing?
- What actually happens: What is the actual output?

## Login

If you have not done so, please follow the [login guide](login.md) carefully.

1.  Q: I am getting "ssh: connect to host &lt;IP&gt; port 22: Connection refused"

    A: Please check that you are connected to the
    [NTU VPN](https://vpngate-student.ntu.edu.sg). The cluster is not accessible
    outside the VPN.

2.  Q: I am just getting "Connection to &lt;IP&gt; closed."

    A: Check that you are entering the right IP. This typically means you do not
       have access to the node that you are trying to connect to.

       If you are connecting to a GPU node, make sure you have a running job on the
       node.

3.  Q: I keep getting "Password expired. Change your password now." or "Password
    change failed. Server message: Old password not accepted."

    A: You need to type your original password (the one sent to you) twice when
       logging in. The first time is to SSH and the second time is to start
       changing your password.

4.  Q: I forgot my password. (Forgot Password)

    A: Send us an email from your school email and we will reset it for you
       within 3 business days.

## Shell

1.  Q: Why is X not installed? Why am I getting "conda: command not found"?

    A: We use Lmod to manage software versions and you need to run
       `module load` to load the correct version. See [here](slurm.md#Lmod) for
       more details.

       If the program you need requires `sudo` to install and is NOT listed
       under `module spider`, send us an email and we will install it for you.

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
       request.

## Slurm

1.  Q: How do I actually run my program using Slurm?

    A: We have a guide [here](slurm.md).

2.  Q: How do I check the status of my job? How do I know if my job is done?

    A: You can run `squeue`. If you want to see it update somewhat in realtime,
       you can run `watch squeue`.

3.  Q: How much resources do I actually have access to?

    A: See [Cluster Overview](cluster.md#Slurm).

4.  Q: The number of GPUs assigned is not enough. How do I get access to more?

    A: We allow users to access GPUs beyond their limits as long as you agree to
       allow your jobs to be killed. To acknowledge this, use
       `--qos override-limits-but-killable` when submitting your job.

       When idle resources are available, we will let your job be run on it but
       we will kill your job when those resources are needed by someone else
       that is not using resources outside their limit.

       You are recommended to save epochs and make your program check if there are
       previous epochs to resume from if you make use of this feature.
