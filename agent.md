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

## 🛑 Hard Boundaries (limits the agent must respect)

These are the operational ceilings and topology rules the agent **must not**
cross — neither by submitting jobs that exceed them, nor by SSHing along
paths that aren't permitted, nor by writing data to the wrong tier. Verify
live values with `sacctmgr` / `scontrol` / `storagemgr` before quoting
numbers — tables here can lag.

### SSH topology (where you can connect from where)

- **Login node ↔ login node SSH is blocked.** A user landing on `login-1`
  cannot `ssh login-2`. The entry IP routes to one of `login-[1-3]` per
  session; if you need a specific login node, fully disconnect and retry
  until the router places you there. The agent must **never** propose
  hopping between login nodes — that path is closed by design.
- **SSH to a compute node is permitted only while you have an active Slurm
  job on that node.** The standard reach pattern is via the login node as
  a jump host: `ssh -J <user>@<login_ip> <user>@<allocated_node>`. Outside
  of an active job, the agent must **never** propose direct SSH to a GPU
  node — use `srun --pty` (which consumes the 2h/1-GPU interactive slot)
  or wait for the batch job to start.
- **Implication**: never recommend `ssh login-N` to "switch login nodes",
  never recommend `ssh gpu-pro6000-3` to "check the log on the GPU box".
  If the user is stuck on the wrong login or needs to see compute-node
  state without an active job, the answer is `scontrol show node …` or
  `sacct -j <jobid> ...` — not SSH.

### Per-user concurrent GPU limit (default QoS — live: `sacctmgr show qos -P format=Name,MaxTRESPerUser`)

Max simultaneous GPUs per user, by class tier × model:

| Class      | `6000ada` | `a6000` | `a40` | `l40` | `pro6000` |
|------------|----------:|--------:|------:|------:|----------:|
| rose       | 4         | 4       | 8     | 4     | 4         |
| phd        | 4         | 4       | 4     | 4     | 4         |
| msc        | 2         | 2       | 2     | 2     | 2         |
| ug         | 2         | 2       | 2     | 2     | 2         |
| ug-course  | 1         | 1       | 1     | 1     | 1         |

Faculty-project QoSes carry their own per-PI GPU-model allowlist + cap —
inspect with `sacctmgr show qos <pi_qos>`. The escape hatch is
`--qos=override-limits-but-killable` (idle GPUs only, preemptable). These
are **concurrent** caps, not totals: a `rose` user can sequentially run
many 4-GPU `pro6000` jobs, but never two at the same time.

### Personal monthly GPU-hour cap (deployed 2026-05-10)

Every regular `rose`/`phd`/`msc`/`ug-proj` user now carries a per-user
**monthly billing-minute (SU) cap** on their user×account row. Hard reset
on the 1st of each month at **00:00 SGT**; no carry-over, no decay.

| Account      | Cap (SU = billing-min) | Equivalent on 8× pro6000  |
|--------------|-----------------------:|---------------------------|
| rose         |              1,382,400 | ~15 days full-bore        |
| phd          |              1,382,400 | ~15 days full-bore        |
| msc          |                480,000 | ~5.2 days full-bore       |
| ug-proj      |                480,000 | ~5.2 days full-bore       |
| faculty-proj | (per-PI lifetime TRES-minute budgets — different ledger; see [slurm-accounting.md](slurm-accounting.md)) | |

**SU conversion** (partition `TRESBillingWeights`):

| GPU model       | SU per GPU-hour |
|-----------------|----------------:|
| `pro6000`       |             480 |
| `l40`, `6000ada`|             240 |
| `a40`, `a6000`  |             180 |
| CPU only        |               0 |

**What burns the personal cap vs what doesn't:**

- `rose` / `phd` / `msc` / `ug` / `ug-course` / `scale-*` QoSes — full rate.
- Funded-project QoSes (dso/dtc/hmgics/ots/soujanya-poria-startfund), `experimental`, and `override-limits-but-killable` — `UsageFactor=0`, **free** against the personal cap.
- Faculty-project cohort QoSes (`<pi>_2026_05[_NN]`) — drain the per-PI project budget, **not** personal.
- CPU-only jobs (`--gpus` omitted) — free (CPU weight is 0).

**Agent enforcement habit**: before recommending a long or multi-GPU run,
check the user's current burn via the one-liner from
[slurm-accounting.md](slurm-accounting.md#checking-your-personal-monthly-quota).
If they're past ~80% of cap and the work isn't time-critical, suggest
`--qos=override-limits-but-killable` (free, preemptable) or CPU-only prep
work to avoid lockout before the 1st-of-month reset.

### Storage quotas + tier choice (SSD vs HDD)

**Per-user paths (network-backed, identical from every node):**

| Path                          | Quota                              | Who / how to get it                            |
|-------------------------------|------------------------------------|------------------------------------------------|
| `/home/<user>`                | **50 GB**                          | every user. Configs, code, IDE state. Do not stage datasets here. |
| `/tmp`                        | **4 GB** (per-user, isolated)      | every user. Small; redirect installs via `TMPDIR` if pip/conda fills it. |
| `/projects/<name>`            | regular-user pool — provision via `storagemgr` | rose/phd/msc/ug/ug-course. Quotas below, by class. |
| `/projects/faculty/<project>`            | **admin-provisioned**, SSD          | faculty-project users only (see below). Not via `storagemgr`. |
| `/projects/_hdd/faculty/<project>` | **admin-provisioned**, HDD spillover | faculty-project users only, **and only if** their SSD allocation exceeded cluster SSD capacity. |

**Regular-user project quotas (live: run `storagemgr` to see your own allocation):**

| Class      | SSD (`ssd`) | HDD (`hdd`)    |
|------------|-------------|----------------|
| rose       | 1 TB        | 5 TB           |
| phd        | 1 TB        | 1 TB           |
| msc        | 400 GB      | 400 GB         |
| ug         | 400 GB      | 400 GB         |
| ug-course  | 20 GB       | **unavailable**|

Faculty-project allocations are per-project, negotiated at provisioning;
they don't fit a class table. See the dedicated subsection below.

**Tier choice — SSD is the default for active workloads.** Anything the
cluster reads or writes frequently during a job belongs on SSD:

- **Training datasets** the dataloader hits every step
- **Checkpoints** written mid-training
- **Python / Conda environments** — thousands of small `.py` / `.so`
  files stat'd on every `import`; a Conda env on HDD will hang
  interpreter startup
- **Working directories** for in-flight experiments — code, logs,
  intermediate outputs
- **Anything with small-file random IO** — build trees, exploded image
  datasets, model shards, embedding indexes

**HDD is for cold storage only**, where "cold" means read-once or
sequentially-scanned, not repeatedly random-accessed. Good HDD candidates:

- Archived datasets you've finished processing
- Completed training-run artifacts you're keeping for posterity
- Raw downloads (tars, zips) before extraction
- Single chunky files read sequentially — a packed `.tar`, a video, a
  `.parquet` shard scanned once

**HDD is genuinely slow at reading millions of small files.** The pool
has multi-GB/s sequential bandwidth, but IOPS is limited. A Python env,
an exploded ImageNet directory, or a `find` over a deep tree will fall
over on HDD even though throughput on big sequential reads looks fast.
**Bandwidth ≠ IOPS.** If the workload pattern is small-and-many → SSD;
large-and-few → HDD is fine.

**`ug-course` users have no HDD access** — they use SSD by default,
which already matches the recommendation.

### Faculty-project users — different storage path, NO `storagemgr`

Faculty-funded project users (those whose `sacctmgr show assoc user=$USER`
shows `Account=faculty-proj`) do **not** use `storagemgr`. Their project
directories are **admin-provisioned** at fixed paths:

- `/projects/faculty/<project_name>/` — **SSD allocation**, the primary
  working tier. Every faculty project has this path.
- `/projects/_hdd/faculty/<project_name>/` — **HDD allocation**, present
  **only** for projects whose requested SSD quota exceeded what the
  cluster could afford on SSD alone. If this path doesn't exist for a
  given project, that means the project's full allocation fits on SSD
  and no HDD spillover was needed.

These paths cannot be renamed, resized via `storagemgr`, or split into
sub-allocations by users. Quota changes go through the admin team via
email, not through any user-facing tool.

**When assisting a faculty-project user**: point them at
`/projects/faculty/<their_project>/` for active workloads. Never
recommend `storagemgr` — it doesn't apply to them. Same SSD-vs-HDD tier
rules as above: active IO and Conda envs on the SSD path; cold-archival
(if their project has the HDD path at all) on `/projects/_hdd/faculty/...`.

### Hard rule for the agent

Do not propose writing model weights, datasets, or experiment outputs to
`/home` or `/tmp`. The answer is **always** a project directory on the SSD
tier:

- **Regular users** (rose/phd/msc/ug/ug-course): provision via
  `storagemgr` → `/projects/<name>/`.
- **Faculty-project users**: the pre-existing `/projects/faculty/<project>/`
  — no `storagemgr` step.

If the user is on `/home` and full, help them migrate to the appropriate
SSD project directory above, not patch.

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
- Storage (network-backed, synced): `/home/<user>` 50GB; `/tmp` 4GB per user. Project storage path depends on user class: regular users (rose/phd/msc/ug/ug-course) provision via `storagemgr` → `/projects/<name>`; faculty-project users get admin-provisioned `/projects/faculty/<project>` (SSD) and optionally `/projects/_hdd/faculty/<project>` (HDD spillover). See the Hard Boundaries section above and [cluster.md#Directories](cluster.md#directories) for quotas.
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
- Default QoS has `MaxJobs=1`; use `--qos override-limits-but-killable` to run more (jobs may be preempted — checkpoint/resume). **Preemption rules**:
  - Any within-limit user QoS (per-user class tiers `rose`/`ug`/`ug-course` and any faculty-project QoS) preempts `override-limits-but-killable` jobs by **requeueing** them (not killed — Slurm restores them with state intact).
  - Override-killable jobs do **not** preempt each other; they share idle capacity by normal priority (fairshare + age + job-size).
- **Account taxonomy**: per-user class tiers are `rose`, `phd`, `msc`, `ug`, `ug-course`. Faculty-sponsored project accounts (PI-named QoSes, e.g. `<lastname>_<year>_<NN>`) also exist with their own GPU-model allowlists and TRES-minute budgets. The agent should not assume a user is on a class tier — check `sacctmgr show assoc where user=$USER format=Account,QOS,DefaultQOS` to confirm. To inspect a project QoS's compute budget: `sacctmgr show qos <name> -P format=Name,GrpTRESMins` (TRES-minutes; ÷60 for hours). For usage so far: `sshare -A <account>`.
- **Per-job GPU cap is bounded by single-node hardware** (Slurm doesn't span GPUs across nodes for one job). Max GPUs per job by model:

  | model | max | model | max |
  |---|---|---|---|
  | `6000ada` | 4 | `pro6000` | **10** (lands on pro6000-[5-6]) |
  | `a40` | 10 | `pro6000` + `-C highmem` | **8** (lands on pro6000-[7-10]) |
  | `l40` | 4 | | |
  | `a6000` | 10 | | |

  If a user asks for more than this, the job pends forever — flag immediately.
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
- **Regular users** (rose/phd/msc/ug/ug-course): all storage requests are via `storagemgr`, run on login nodes only. It creates project dirs under `/projects/<name>`; names alphanumeric/hyphen, no NSFW/offensive names. Do **not rename** project directories after creation. Quota can be split across multiple dirs.
- **Faculty-project users do NOT use `storagemgr`.** Their directories are admin-provisioned at `/projects/faculty/<project>/` (SSD) and optionally `/projects/_hdd/faculty/<project>/` (HDD spillover, exists only when the project's SSD allocation exceeded cluster SSD capacity). Quota changes go through admin email, not a user tool. See the Hard Boundaries section above for the full SSD-vs-HDD rule.
- If home is full, move data to project dirs (above paths depending on user class); set `TMPDIR` to a larger path if `/tmp` fills during installs.
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

## Recommended models for the agent

For best results, use a frontier coding agent with **at least 200k context
window — ideally 1M**. Operational details on this cluster (QoS rules,
RAM tables, preemption logic, account taxonomy) do not compress well, and
shorter contexts force the agent to drop key facts mid-session.

Tested and recommended:
- **Claude Code with Sonnet 4.6 or newer** (Anthropic).
- **GPT-5.4 / GPT-5.5 Codex** (OpenAI). Same prompting strategy applies —
  paste this digest at session start.

Not recommended without independent testing:
- **Open-source models**. Have not been audited against this digest;
  expect heavier hallucination, especially around Slurm flag semantics,
  QoS naming, RAM/GPU rules, and cluster topology. If you must use one,
  verify every command it generates before running.

**Project-level prompting tip**: keep your project's `CLAUDE.md` (or
equivalent system prompt file) short and have it **refer to this
`agent.md`** rather than duplicating operational details. As your project
conversation grows, system-prompt content gets compressed and
operational details drift first; pointing at this canonical file is the
durable way to prevent drift.

**Reaffirmation of responsibility**: per the [Condition of Access](README.md),
what your agent does equals what you do. The cluster team is not liable
for agent behavior. If your agent hallucinates a destructive command and
you run it, that is on you — pick a capable model and audit its actions.
