# Debugging

> **WARNING:** This guide assumes that you have already [logged in to a login
> node successfully](login.md). Running an IDE directly without a first login
> will not work as the first login will force you to change your password.

## Running IDE as Text Editor

To run your IDE (e.g., PyCharm, VSCode) on the login node, simply enter your
credentials using the remote SSH functionality of your IDE.

When you need to run your script with GPU, you may run Slurm in your IDE's
terminal to start a job. More information on how to use `srun` and `sbatch` can
be found in the [Slurm guide](slurm.md).

> Note: You should avoid running too many extensions as there is a RAM limit
> enforced on login nodes that may cause your IDE to be killed due to Out of
> Memory. Ensure you exit your IDEs properly as we have been informed that some
> users run into issues when they do not do so and two instances of their IDE
> run simultaneously.

Please take note of the following:

1. Each and every user has a CPU and memory limit on the each login node (there
   is a total of 3 login nodes).
2. IDEs beyond VSCode and PyCharm can be more hungry on CPU and memory. This
   means either it initialize very slow, or it directly triggers OOM-killer.
3. Most IDEs deploy a backend process on the login node so you can edit your
   code in real time. This also means this backend eats up your memory quota.
   Backends not closed gracefully can stay in the memory and eat your memory
   quota as well.
4. If you have any enquiries regarding IDEs, please come to the office hour
   instead of sending emails. We regret to say that we are unable to debug such
   issues easily without being able to reproduce ourselves.

## Running IDE on Compute Node to Debug

> **IMPORTANT NOTE:** This guide should only be used if you specifically need
> to be on the compute node running your processes. Following these steps will
> hog up resources until you close your terminal.
> **You are recommended to [run only your script](slurm.md) most of the time.**

We are fully aware that users might want to run debugging sessions, either
checking outputs in shell sessions or running a Python debugger and debug your
code line-by-line.

To debug directly on the cluster using IDEs (e.g., PyCharm, VSCode), set up an
**SSH tunnel**. This tunnel runs on the **login node** and relays traffic to a
GPU node, allowing you to “directly” interact with it.

> 💡 **Tip:** If you're unfamiliar with configuring remote connections in
> PyCharm or VSCode, refer to their official documentation.

### Step-by-Step Instructions

1. **Allocate a GPU node** with the resources you need:

    ```bash
    salloc <resource_request>
    ```
    - **Example:**
      ```bash
      salloc --gpus=v100:1 --time=0:30:00
      ```
    - This starts a shell. **Do not exit this shell** — it will cancel the job.

2. **Open a new terminal window.**

3. **SSH into your allocated GPU node.**

    This is the command to provide your IDE if you want to use an IDE.

    ```bash
    ssh -J <username>@<login_node_ip> <username>@<allocated_node_name>
    ```

    - **Example:**
      ```bash
      ssh -J user@0.0.0.0 user@gpu-example-1
      ```

    This tells SSH to go through the login node (`-J`) and connect directly to
    the compute node.

5. **Tunneling into the assigned compute node.** (if you use PyCharm use this one)

    For IDEs where you are unable to customize the SSH command, please see
    below.

    Run the following command on **your** computer's terminal (NOT any terminals
    that already has SSH running).

    ```bash
    ssh -L <port>:<allocated_node_name>:22 <username>@<login_node_ip>
    ```

    This will start an SSH session. Do not close this shell either. This SSH
    session maps a local port on your computer to the SSH port on your allocated
    node. In this way, you can put `localhost:<port>` instead in your IDE as
    your remote host, i.e., your IDE is connecting to this local port, which is
    being forwarded to the allocated node. This forwarding process is
    transparent to your IDE.

## My IDE doesn't want to connect.

Connecting IDEs sometimes can be frustrating mostly because of these reasons:
-  Your network connection is unstable.  
-  When trying to install itself, your IDE consumes all your home directory disk quota.  
-  When trying to launch itself, your IDE triggers out-of-memory killer on the login node.  
-  Your IDE leaves lingering processes in the background and this reduce the amount of free memory you can use. If you launch it again, it will encounter the second case above.

Here are some methods to manually cleanup so your IDE can connect:
- Try to kill your IDE related processes, you can use command like `pkill -u your_name -f ide_name`. This kills processes under your name and has the keyword `ide_name`. For pycharm, it can be `pycharm`.  
- Try to remove your IDE backend files. VSCode and PyCharm usually install the backend under `~/.cache`. Just remove it with `rm` command. (This might also remove your IDE settings, be careful)
- Call `htop`, `bpytop`, or whatever commands that show what processes you have. Try to find anything that is consuming your memory quota badly, like a accidently executed python script.
- Try to remove large files under your home directory. Call `ls -a` to view all directories and files, call `ncdu` or `du -sh ./*` to view the directory/file sizes to determine what to remove/migrate.

Since recent update, we have deployed process auto-cleanup:
- It is triggered when all your SSH connection to a certain login node is closed.
- It kills all the processes belonging to you. This should kill any lingering VSCode and PyCharm backend processes.
- This also kills any tmux sessions.
- This auto-cleanup can be workaround, but we don't support it and don't recommend it. The auto-cleanup exists for good reasons.
- This does not clean up files on disks, just processes in the memory. If you are seeing disk quota related errors, you still need to manually remove/migrate your files.

## After You're Done

- **Close all terminals and SSH sessions properly.**
- **⚠️ Do not leave SSH sessions hanging or unattended.**
    **This will cause your priority to become lower** AND other users to be
    unable to use the resources you are using.
