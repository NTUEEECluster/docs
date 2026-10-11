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

Your password is temporary and must be changed the first time you log in by SSH.
You will be asked for passwords in this order:

  1. Password:          your temporary password
  2. Current password:  your temporary password AGAIN (this is normal)
  3. New password:      your new password
  4. Retype new password: your new password again

What you will see:
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

Your new password must:
  - be at least 12 characters long
  - use at least 3 of: lowercase letters, uppercase letters, digits, symbols
  - not contain your username
  - not be one of your last 24 passwords

If the new password is refused, you are asked again. If you are disconnected
after the change, log in again with your new password.

Five wrong passwords in a row lock the account for 15 minutes. Wait, then try again.



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


## 5. Configure VS Code (if using Remote SSH)

VS Code's scans and file watchers can put pressure on CephFS metadata caches,
slowing shared filesystem I/O and triggering cache-recall warnings.

1. Connect to the cluster in VS Code. Press `F1` and select
   **Preferences: Open Remote Settings (JSON)**. This edits
   `~/.vscode-server/data/Machine/settings.json` on the cluster.
2. Merge these settings into the existing JSON object and save:

   ```json
   {
     "files.watcherExclude": { "**": true },
     "search.exclude": { "**": true },
     "search.followSymlinks": false
   }
   ```

3. Save your work, run **Remote: Close Remote Connection** from the Command
   Palette, then reconnect.

These settings disable workspace file watching and exclude all files from
workspace search by default; automatic detection of external file changes
may be affected. Extensions can scan independently: disable unnecessary
remote extensions and their indexing. Open only your code folder, not your
entire home, datasets or Conda environments.

**If VS Code hangs or causes the shared filesystem to stall, we will kill
all of your VS Code processes on the affected cluster node. Unsaved work
may be lost.**

## 6. Avoid broad filesystem scans

We strongly discourage recursive commands such as `grep -r`, `du` and `find`
over entire dataset directories. Do not scan the whole filesystem: large
scans can overwhelm shared storage, stall commands and slow I/O for everyone.
Limit searches and size checks to specific files or small subdirectories.

## Next

- [Cluster Guide](cluster-guide.md): nodes and how to look them up
- [Slurm Guide](slurm-guide.md): job templates, limits, billing
- [Storage Guide](storage-guide.md): where to keep what
- [Container Guide](container-guide.md): Docker/NGC images (advanced)
- [FAQ](FQA.md): common questions and troubleshooting

