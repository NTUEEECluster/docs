# Debugging

> **WARNING:** This guide assumes that you have already [logged in to a login
> node successfully](login.md). Running an IDE directly without a first login
> will not work as the first login will force you to change your password.

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
      salloc --gres=gpu:1 --time=0:30:00
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

## After You're Done

- **Close all terminals and SSH sessions properly.**
- **⚠️ Do not leave SSH sessions hanging or unattended.**
    **This will cause your priority to become lower** AND other users to be
    unable to use the resources you are using.
