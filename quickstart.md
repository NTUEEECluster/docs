# Quick Start

Read the [Terms and Conditions](terms-n-conditions.md) first. This page gets
you from login to a first job.

## 1. Log in

You need your username (your NTU email before the `@`, lower-case), the
default password and login IP from your approval email, and a connection to
NTUSECURE or the NTU VPN.

```
ssh <username>@<login_IP>
```

On first connection, accept the host key only if the fingerprint is:

```
SHA256:AhYlWQBTsN/4GAzYTVTiZzrVhPhcurFMu1sBMglqvdM
```

The first login forces a password change. Nothing is shown while you type.

```
(username@login_IP) Password: <default password>
Password expired. Change your password now.
(username@login_IP) Current Password: <default password again>
(username@login_IP) New password: <new password>
(username@login_IP) Retype new password: <new password again>
```

You may be disconnected; reconnect with the new password. Passwords also
expire periodically and are changed the same way. Log in once from a terminal
before using an IDE, which cannot handle the password change.

| Problem | Fix |
|---|---|
| `Connection refused` / timeout | Connect to NTUSECURE or the NTU VPN first. |
| Forgot password | Email us from your school email. |

## 2. Know the login node

- Each user gets at most **3 CPU cores and 16 GB RAM**. Going over the RAM cap
  kills **all** your processes on that login node.
- When your last SSH session on a login node ends, all your processes there
  are killed, including `tmux` and `nohup`.
- There are no GPUs. Editing, file transfer and job submission only; run real
  work as jobs.

## 3. Set up storage

`$HOME` is 50 GB and `/tmp` is 4 GB. Create a project directory with
`storagemgr` and redirect caches there before installing anything; see the
[Storage Guide](storage-guide.md). This step is required.

## 4. Run a job

Create an environment and submit a batch job, following the
[Slurm Guide](slurm-guide.md):

```bash
sbatch job.sh          # batch job; keeps running after you log out
squeue --me            # your jobs and why they are pending
scancel <jobid>        # cancel
```

For a short interactive session on a GPU (up to 2 h, 1 GPU):

```bash
srun --gres=gpu:a40:1 --time=1:00:00 --pty bash
```

## Next

- [Cluster Guide](cluster-guide.md): nodes and how to look them up
- [Slurm Guide](slurm-guide.md): job templates, limits, billing
- [Storage Guide](storage-guide.md): where to keep what
- [Container Guide](container-guide.md): Docker/NGC images (advanced)
