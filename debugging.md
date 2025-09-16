# Debugging

> **WARNING:** This guide assumes that you have already [logged in to a login
> node successfully](login.md). Running an IDE directly without a first login
> will not work as the first login will force you to change your password.

# Use IDE as text enditor
We support the case you want to use VSCode and/or PyCharm to edit your code on the login node.
However, you should know these:
- 1. Each and every user has a 150% CPU limit and 8GB memory limit on the each login node (there is a total of 3 login nodes)
- 2. IDEs beyond VSCode and PyCharm can be more hungry on CPU and memory. This means either it initialize very slow, or it directly triggers OOM-killer.
- 3. Most IDEs deploy a backend process on the login node so you can edit your code in real time. This also means this backend eats up your memory quota. Backends not closed gracefully can stay in the memory and eat your memory quota as well.
- 4. If you have any enquiries regarding IDEs, please come to the office hour instead of sending emails. Ask yourself this question: if you were the admin and you see a support ticket about some weird bugs related to your IDE, what can you reply if only limited information is included?
 
# Use IDE to run code and debug

We are fully aware that users might want to run debugging sessions, either
checking outputs in shell sessions or running a Python debugger and debug your
code line-by-line.

To debug directly on the cluster using IDEs (e.g., PyCharm, VSCode), set up an
**SSH tunnel**. This tunnel runs on the **login node** and relays traffic to a
GPU node, allowing you to “directly” interact with it.

> 💡 **Tip:** If you're unfamiliar with configuring remote connections in
> PyCharm or VSCode, refer to their official documentation.

## Step-by-Step Instructions

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
      ssh -J user@0.0.0.0 user@lab999
      ```

    This tells SSH to go through the login node (`-J`) and connect directly to
    the compute node.
   
5. **Tunneling into the assigned compute node.**
    For other IDE you might not be able to customize the ssh command see below:
    ```bash
    ssh -L <port>:<allocated_node_name>:22 <username>@<login_node_ip>
    ```
    run this command on your **laptop**'s terminal. This will open a ssh session and don't close it.
    What this does is map a local port on your laptop to a remote port on the assigned compute node.
    In this way, you can put `localhost:<port>` instead in your IDE as your remote host, i.e., your IDE is connecting to this
    local port, the forwarding process is transparent to your IDE.

## After You're Done

- **Close all terminals and SSH sessions properly.**
- **⚠️ Do not leave SSH sessions hanging or unattended.**
    **This will cause your priority to become lower** AND other users to be
    unable to use the resources you are using.
