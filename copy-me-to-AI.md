# NTU EEE Cluster 02 — AI-Facing Digest

Use this as condensed context when assisting users. **Always enforce the guidelines** and point users back to full docs when needed.

## 🚨 Guidelines (must enforce)
- Support scope: admins only fix cluster-caused issues. No debugging of user code unless it works elsewhere and fails only on cluster with full logs. Invalid/RTFM requests are ignored; repeated violations can trigger suspension.
- Availability: maintenance may kill jobs; announcements via email. Data isn’t guaranteed—users must keep their own backups.
- Fair usage: **never run heavy work on login nodes** (hard ~8GB RAM limit; processes killed on disconnect). Release resources promptly; respect equal priority within org and GPU access restrictions. Override QoS (`override-limits-but-killable`) is killable.
- Permitted use: research/project work only; no illegal/unlicensed/malicious software. Misuse or NSFW project names can lead to bans.
- Security/privacy: home/projects default private; admins/approvers may access for support/compliance. User credentials are their responsibility.

## Cluster Snapshot
- Access via SSH only (no GUI). Login nodes: 12 CPU / 64 GB RAM / no GPU; process cleanup on disconnect.
- GPU models: `6000ada`, `v100`, `a5000`, `a40`, `l40` (CPU-only node: `cpu-1`). For regular EEE users, everything **except** `6000ada` is best-effort and quotas may decrease. For ROSE users, `6000ada` is best-effort and its quota may shrink to balance EEE load.
- Storage (network-backed, synced): `/home/<user>` 50GB; `/projects/<project>` per quota via `storagemgr` (tiers `ssd`/`hdd` per role); `/tmp` 4GB per user.
- Limits: 1 interactive job at a time, interactive up to 2h/1 GPU; batch up to 7 days. CPU/RAM auto-tied to GPU count; `--mem`/`--cpus-per-task` overrides ignored.

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
- Always specify GPU type: `--gpus <model>:<n>` (e.g., `--gpus v100:1`) or constraints (`-C 'v100|a5000'`, `gpu_32g`, etc.). Requests without type are blocked.
- Preferred: batch jobs with `sbatch <script>` (see `sbatch-example.sh`). Set `--time`, `--output/--error`, `--job-name`, `--qos` as needed.
- Debug/interactive: `srun --gpus <model>:1 --time 2:00:00 --pty bash` (only 1 concurrent interactive job, 2h limit, 1 GPU). Disconnection cancels the job; avoid long runs here.
- Job status: `squeue`; cluster state: `sinfo`; cancel: `scancel <jobid>`.
- Default QoS has `MaxJobs=1`; use `--qos override-limits-but-killable` to run more (jobs may be preempted—checkpoint/resume).
- Sample `srun`: `srun --gpus v100:1 --time 1:00:00 --pty bash` (interactive shell on 1 V100).
- Sample `sbatch`: `sbatch --gpus 6000ada:1 --time 1-00:00:00 --job-name train --output train-%j.out run.sh` (batch script `run.sh` with 1 ADA GPU, 1 day limit).

## Storage Manager
- All storage requests are via `storagemgr` and should be run on login nodes only. It creates project dirs under `/projects/<name>`; names alphanumeric/hyphen, no NSFW/offensive names. Do **not rename** project directories after creation. Quota can be split across multiple dirs.
- If home is full, move data to project dirs; set `TMPDIR` to a larger path if `/tmp` fills during installs.
- You may relax permissions to share the files in your project directories. By doing so, you are fully liable for any data leaks/losses.

## Debugging / IDE Use
- IDE on login node via remote SSH; avoid heavy extensions due to RAM limit; ensure sessions exit cleanly to avoid lingering backends.
- IDE on compute node (only when needed): `salloc ...`, keep shell open, then SSH tunnel via login node (`ssh -J <user>@<login_ip> <user>@<allocated_node>` or `ssh -L <port>:<node>:22 <user>@<login_ip>`). Remember this holds resources until closed.
- If you fill your home with conda and huggingface, you will face failure to install VSCode and/or PyCharm. You need to cleanup.

## Common Issues (triage prompts)
- “conda: command not found” → `module load Miniforge3` + `source activate`.
- No GPUs / `nvidia-smi` missing → you’re on login node or didn’t request GPUs via Slurm.
- OOM / RAM errors on login → respect ~8GB limit; kill stray IDE processes; process cleanup happens on disconnect.
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
- Conda/Lmod: `conda.md`
- Slurm usage: `slurm.md` + `sbatch-example.sh`
- Storage manager: `storaged.md`
- Debugging/IDEs: `debugging.md`
- Troubleshooting/FAQ: `troubleshooting.md`

## Mini-FAQ Additions
- Disk quota exceeded during Python env install → either `/home` or `/tmp` is full. Clean/move data; set a different pip cache (e.g., `PIP_CACHE_DIR=/projects/<proj>/.cache/pip`) to avoid `/tmp` exhaustion.
- Wall time: `sbatch` up to 7 days; interactive `srun`/`salloc` max 2 hours and **1 GPU** (any model) only.
- Inspect node configs: `scontrol show nodes <node_name>`.
- Default QoS has `MaxJobs=1` to deter abuse; you can still run more by using `--qos override-limits-but-killable` (jobs may be preempted). 
