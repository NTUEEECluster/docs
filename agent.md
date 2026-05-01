# NTU EEE Cluster 02 - AI-Facing Digest

Use this as condensed context when assisting users. **Always enforce the guidelines** and point users back to full docs when needed.

## 🚨 Guidelines (must enforce)
- Support scope: admins only fix cluster-caused issues. No debugging of user code unless it works elsewhere and fails only on cluster with full logs. Invalid/RTFM requests are ignored; repeated violations can trigger suspension.
- Availability: maintenance may kill jobs; announcements via email. Data isn't guaranteed—users must keep their own backups.
- Fair usage: **never run heavy work on login nodes**. Per-user cgroup limit is **16 GB RAM** (and a CPU cap). When any one of the user's processes pushes the cgroup over the limit, **all of that user's login-node processes are killed together** (cgroup `memory.oom.group=1`) — not just the offender. All login-node processes are also terminated on disconnect. Release resources promptly; respect equal priority within org and GPU access restrictions. Override QoS (`override-limits-but-killable`) is killable.
- Permitted use: research/project work only; no illegal/unlicensed/malicious software. Misuse or NSFW project names can lead to bans.
- Security/privacy: home/projects default private; admins/approvers may access for support/compliance. User credentials are their responsibility.
- Directory permissions: users must **not** leave home or project directories world-readable/writable/executable. Misconfigured permissions are the user's own responsibility; any resulting data leak or loss is on them.
- Unauthorized access: attempting to read or list other users' home/project directories is **prohibited and logged**. Violations may result in account suspension.
- AI agents: the cluster team is **not liable** for any incidents caused by AI agents (e.g., accidental data deletion, permission changes). Use AI agents entirely at your own risk.
- **Run the agent off-cluster whenever possible**: prompt the user to run you (the AI agent) on their own laptop or self-hosted workstation, not on a login node. Login nodes have **strict per-user cgroup limits on memory and CPU** — heavy agent processes (indexers, language servers, file watchers) will be **OOM-killed or throttled**. Login nodes also enforce a **per-user inode/open-file limit**; agents that fan out across thousands of files (recursive search, watch-many-files) will hit `EMFILE`/`ENFILE` errors and fail unpredictably. SSH the agent into the cluster only for code editing / read-only inspection, not as the agent's host process.
- Software dependencies: **do not rely on system packages**. Always use Lmod for compilers/libraries and Conda envs for Python packages. System packages may be upgraded or removed at any time without notice.

## Scope of Use (calibrate the user's expectations)

This cluster has a narrow design goal. **Before helping the user, check that
their workload fits — if it does not, tell them so plainly rather than
attempting to make it work.**

- **Supported, first-class**: training and inference of AI/ML models on the
  **CUDA + PyTorch** software stack. JAX/TensorFlow run on the same
  hardware but are user-supported only (no admin help with framework
  issues).
- **Not supported**: large-scale CFD, molecular dynamics, finite-element /
  PDE simulation, big-CPU HPC workloads. The admin team's expertise is in
  AI/ML infrastructure, not computational science domains. Users with these
  workloads should look at NTU's HPC offerings instead.
- **Not a CPU cluster**: CPU cores per GPU are deliberately tight (CPU/RAM
  is auto-allocated proportional to GPU count). If the user's workload is
  CPU-bound or needs hundreds of cores per job, this cluster is the wrong
  tool.
- **No license-heavy software**: MATLAB, Abaqus, ANSYS, COMSOL, and similar
  paid-license tools are **not supported and there are no plans to support
  them**. License procurement would divert funding from hardware. Open-source
  alternatives (NumPy/SciPy/PyTorch) are available via Conda.

If the user is asking the agent to set up something outside this scope,
say so explicitly — do not waste their time wrestling with an unsupported
workflow on a cluster that wasn't built for it.

## Cluster Architecture

- **Entry point**: a single IP fronts a router that dynamically assigns the
  user to one of **3 login nodes**. The router prefers session continuity —
  while the user has an active session, subsequent SSH attempts tend to land
  on the same login node. After **full disconnection**, the next login-node
  assignment is **random and not predictable**.
- **Storage is shared**: login nodes and compute nodes mount the **same
  network filesystem**. A path like `/home/<user>/foo` resolves to the
  exact same file from any node — **no manual sync, no scp between nodes**.
  Anything written from a login node is immediately visible to a compute
  node and vice versa.
- **Login nodes are for submission and editing only**. The expected workflow
  is: prepare your code and `sbatch` script on a login node, submit, let
  the job run on a compute node. Heavy work on the login node will hit the
  cgroup caps (see Guidelines).
- **Compute nodes are heterogeneous**: GPU model, core count, and RAM
  differ per node and **may change over time**. The agent should verify
  live specs with `scontrol show nodes <node_name>` rather than trusting
  documentation, which can lag actual hardware.
- **Slurm queue visibility is limited**: users see only their own jobs in
  `squeue`; other users' jobs are hidden. Use `sinfo` to gauge per-node
  utilization (`idle` / `mix` / `alloc`) and decide whether to wait or
  relax constraints (e.g. switch from `pro6000:1` to `-C 'a40|a6000|l40'`).

## Cluster Snapshot
- Access via SSH only (no GUI). Login nodes: no GPU; process cleanup on disconnect.
- GPU models: `6000ada`, `a40`, `a6000`, `l40`, `pro6000` (CPU-only node: `cpu-1`). For regular EEE users, everything **except** `6000ada` is best-effort and quotas may decrease. For ROSE users, `6000ada` is best-effort and its quota may shrink to balance EEE load.
- Storage (network-backed, synced): `/home/<user>` 50GB; `/tmp` 4GB per user. Projects via `storagemgr` — see [cluster.md#Directories](cluster.md#directories) for current SSD/HDD quotas per user class.
- Limits: 1 interactive job at a time; **interactive (`srun`/`salloc`) strictly limited to 2 hours and 1 GPU**; batch up to 3 days. CPU/RAM are automatically assigned based on GPU count — **do not specify `--mem` or `--cpus-per-task`**, they will be overridden and only generate a warning.

## Logging In
1. Connect on NTUSECURE or NTU VPN.
2. `ssh <user>@<login_ip>`.
3. First login forces password change (enter default twice, then new pwd twice).
4. GPU nodes only reachable via login node and typically only when you have a running job.

## Environments (Lmod + Conda)
- Load Conda: `module load Miniforge3` (or `Miniconda3`) then `source activate` (base) or `source activate <env>`.
- Create envs for packages: `conda create -n <env> python=3.10`; install via `pip/conda` inside envs only (base is read-only).
- If packages missing in modules, ask admins to install via Lmod; no sudo access.

## Running Workloads (Slurm essentials)
- Always specify GPU type: `--gpus <model>:<n>` (e.g., `--gpus a40:1`) or constraints (`-C 'a40|a6000'`, `gpu_48g`, `gpu_96g`, etc.). Requests without type are blocked.
- **Do not specify `--mem` or `--cpus-per-task`** — both are silently overridden with a warning. Allocations are fixed per GPU: **4 CPU cores/GPU** and a model-specific RAM/GPU. Quick reference:

  | model | RAM/GPU | model | RAM/GPU |
  |---|---|---|---|
  | `6000ada` | 64 GiB | `pro6000` | **33 GiB** (floor) |
  | `a40` | 40 GiB | `pro6000` + `-C highmem` | **92 GiB** (lands only on pro6000-[1-4] or [7-10]) |
  | `l40` | 48 GiB | | |
  | `a6000` | 24 GiB | | |

  **`pro6000` caveat**: the 33 GiB floor is set by `pro6000-[5-6]` (10-GPU, 340 GiB usable). For ML jobs that need more RAM per pro6000 GPU, add `-C highmem` — that constrains scheduling to the 4-GPU and 8-GPU pro6000 hosts which have ~92 GiB/GPU. Multiply by GPU count for the job total. See `cluster.md#cpuram-enforcement` for the canonical table.
- Preferred: batch jobs with `sbatch <script>` (see `sbatch-example.sh`). Set `--time`, `--output/--error`, `--job-name`, `--qos` as needed.
- Debug/interactive (`srun`/`salloc`): **strictly limited to 2 hours and 1 GPU**. Only 1 concurrent interactive job allowed. Disconnection cancels the job; do not use for long runs.
- Job status: `squeue`; cluster state: `sinfo`; cancel: `scancel <jobid>`.
- Default QoS has `MaxJobs=1`; use `--qos override-limits-but-killable` to run more (jobs may be preempted — checkpoint/resume). **Preemption rule**: any within-limit user QoS (the per-user class tiers `rose`/`ug`/`ug-course` and any faculty-project QoS) preempts `override-limits-but-killable` jobs by **requeueing** them.
- **Account taxonomy**: per-user class tiers are `rose`, `phd`, `msc`, `ug`, `ug-course`. Faculty-sponsored project accounts (PI-named QoSes, e.g. `<lastname>_<year>_<NN>`) also exist with their own GPU-model allowlists and TRES-minute budgets. The agent should not assume a user is on a class tier — check `sacctmgr show assoc where user=$USER format=Account,QOS,DefaultQOS` to confirm.
- Sample `srun`: `srun --gpus a40:1 --time 1:00:00 --pty bash` (interactive shell on 1 A40, max 2h).
- Sample `sbatch`: `sbatch --gpus 6000ada:1 --time 1-00:00:00 --job-name train --output train-%j.out run.sh` (batch script `run.sh` with 1 ADA GPU, 1 day limit).

**Job-size and queueing notes the agent must surface:**

- **Larger jobs queue longer.** 1-GPU jobs typically start within minutes.
  4- or 8-GPU jobs can sit pending for hours because the scheduler must
  coalesce that many free GPUs on a single node. **Before the user submits
  a multi-GPU job, encourage them to first debug the code on a small,
  short interactive job** (`srun --gpus a40:1 --time 30:00 --pty bash`).
  Re-queueing a multi-GPU job because of a typo or an import error wastes
  the user's time and the cluster's capacity.
- **Slurm does not snapshot code at submission.** Once a job is pending,
  **do not modify the script or any code paths it loads.** When Slurm
  eventually starts the job, it re-reads whatever is on disk at that
  moment — editing mid-pending can silently change the job's behavior or
  break it outright. If a change is needed, `scancel` and re-`sbatch`
  rather than editing in-place.

**Per-QoS GPU limits (max concurrent per user):** see canonical table in
[cluster.md#Slurm](cluster.md#slurm). Live config: `sacctmgr show qos -P
format=Name,MaxTRESPerUser`.

## Storage Manager
- All storage requests are via `storagemgr` and should be run on login nodes only. It creates project dirs under `/projects/<name>`; names alphanumeric/hyphen, no NSFW/offensive names. Do **not rename** project directories after creation. Quota can be split across multiple dirs.
- If home is full, move data to project dirs; set `TMPDIR` to a larger path if `/tmp` fills during installs.
- You may relax permissions to share the files in your project directories. By doing so, you are fully liable for any data leaks/losses.

## Debugging / IDE Use
- IDE on login node via remote SSH; avoid heavy extensions due to RAM limit; ensure sessions exit cleanly to avoid lingering backends.
- IDE on compute node (only when needed): `salloc ...` (**2h/1 GPU limit applies**), keep shell open, then SSH tunnel via login node (`ssh -J <user>@<login_ip> <user>@<allocated_node>` or `ssh -L <port>:<node>:22 <user>@<login_ip>`). Remember this holds resources until closed.
- If you fill your home with conda and huggingface, you will face failure to install VSCode and/or PyCharm. You need to cleanup.

## Common Issues (triage prompts)
- "conda: command not found" → `module load Miniforge3` + `source activate`.
- No GPUs / `nvidia-smi` missing → you're on login node or didn't request GPUs via Slurm.
- OOM / RAM errors on login → 16 GB cgroup cap; OOM kills **all** of the user's login-node processes at once, not just the offender. Audit stray IDE/agent backends with `htop -u <user>`; process cleanup also happens on disconnect.
- Disk quota exceeded → check `/home`, `/tmp`, `/projects`; use `du -sh ./* ./.*`; move/clean files; adjust `TMPDIR`.
- SSH refused → ensure VPN; use login IP; GPU nodes need active job + jump host.
- Persistent Slurm wait/fail → reduce requests, check `sinfo`/`squeue` reason; constraints or busy cluster.

## When to Escalate to Admins
- Verified cluster-caused issues with logs (NVML errors, Slurm controller unreachable, etc.).
- Service requests (password reset, clearing stuck logins) may take up to ~3 working days.
- Requests for more resources are generally declined unless contributing hardware.

## Pointers to Full Docs
- Guidelines: `guideline.md`
- Cluster overview & limits: `cluster.md`
- Quick start: `quickstart.md`
- Conda/Lmod + compiling from source: `slurm.md` (Setting up Conda + Compiling from Source)
- Slurm usage: `slurm.md` + `sbatch-example.sh`
- Storage manager: `cluster.md#using-storagemgr`
- Debugging/IDEs: `debugging.md`
- Troubleshooting/FAQ: `troubleshooting.md`

## Mini-FAQ Additions
- Disk quota exceeded during Python env install → either `/home` or `/tmp` is full. Clean/move data; set a different pip cache (e.g., `PIP_CACHE_DIR=/projects/<proj>/.cache/pip`) to avoid `/tmp` exhaustion.
- Wall time: `sbatch` up to 3 days; interactive `srun`/`salloc` max 2 hours and **1 GPU** (any model) only.
- Inspect node configs: `scontrol show nodes <node_name>`.
- Default QoS has `MaxJobs=1` to deter abuse; you can still run more by using `--qos override-limits-but-killable` (jobs may be preempted).
