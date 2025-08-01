##  Debugging

We are fully aware that users might want to run debugging sessions, either checking outputs in shell sessions or running a Python debugger and debug your code line-by-line.

To debug directly on the cluster using IDEs (e.g., PyCharm, VSCode), set up an **SSH tunnel**. This tunnel runs on the **login node** and relays traffic to a GPU node, allowing you to “directly” interact with it.

> 💡 **Tip:** If you're unfamiliar with configuring remote connections in PyCharm or VSCode, refer to their official documentation.

---

###  Step-by-Step Instructions

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

3. **SSH into the login node again to set up a tunnel:**
   ```bash
   ssh -L <local_port>:<allocated_node_name>:22 <username>@<login_node_ip>
   ```
   - **Example:**
     ```bash
     ssh -L 2222:lab999:22 user@0.0.0.0
     ```
   - This maps port `22` of `lab999` to local port `2222`. You may change the local port as needed.

4. **SSH into the allocated GPU node through the tunnel:**
   ```bash
   ssh -p <local_port> <username>@localhost
   ```
   - **Example:**
     ```bash
     ssh -p 2222 user@localhost
     ```

5. **Run your IDE** (e.g., PyCharm, VSCode) using this tunnel for remote debugging.

---

### Direct Access to Compute Nodes via Jump Host

If you just want to **SSH directly to a compute node** (e.g., for command-line interaction) without setting up a tunnel, you can use the `-J` (jump host) option:

```bash
ssh -J <username>@<login_node_ip> <username>@<allocated_node_name>
```

- **Example:**
  ```bash
  ssh -J user@0.0.0.0 user@lab999
  ```

This tells SSH to go through the login node (`-J`) and connect directly to the compute node.

---

### After You're Done

- **Close all terminals and SSH sessions properly.**
- **⚠️ Do not leave SSH sessions hanging or unattended.**
