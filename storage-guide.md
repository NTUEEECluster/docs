# Storage Guide

## How storage is set up

All storage is network-backed (Ceph) and mounted identically on every login and
compute node, so a file you write anywhere is visible in your jobs. Nothing is
backed up.

| Path | Limit | Use for |
|---|---|---|
| `/home/<username>` | 50 GB | Code and configs only |
| `/projects/<name>` | per directory, see below | Data, environments, models, container images |
| `/tmp`, `/var/tmp` | 4 GB per user | Small temporary files only |

Project directories sit on one of two tiers. `/projects/<name>` is a link to
the real location, and `readlink -f /projects/<name>` shows which:

| Tier | Path | Speed | Use for |
|---|---|---|---|
| SSD | `/projects/_ssd/<name>` | fast | active datasets, environments, container images, caches |
| HDD | `/projects/_hdd/<name>` | **much slower**, worst under many small reads | large, rarely read files, archives |

Put anything your jobs read repeatedly on SSD. Training from HDD, or running
environments and containers from it, makes jobs crawl.

`/tmp` is not node-local scratch: the same private 4 GB follows you to every
node, persists after jobs and is never cleaned automatically.

## Who gets project storage, and how

| You are | How you get project directories |
|---|---|
| Student with a personal account | Self-service with `storagemgr`, within your group's SSD and HDD allowance |
| Faculty project member | Assigned in the faculty call and created with your account; shared by the project group |
| Hardware contributor | An additional directory is added when your SSDs are bought and physically joined to the cluster |

## Using `storagemgr`

Run `storagemgr` in an SSH session on a login node. It opens an interactive
menu showing your allowance and usage, and creates directories under
`/projects` on the tier you choose.

- Split your allowance however you like, e.g. one 1 TB SSD directory or several
  smaller ones.
- Names use letters, digits and hyphens, must be professional, and are
  permanent.
- Directories are private to you. You may open one to others; you are liable
  for any resulting leak or loss.

Faculty project directories are private per file by default; use `chmod` to
share with your project group.

## Redirect caches (required)

Before any installs or downloads, point scratch and caches at an SSD project
directory. Add to `~/.bashrc`:

```bash
P=/projects/<name>
export TMPDIR=$P/.tmp
export PIP_CACHE_DIR=$P/.tmp/pip CONDA_PKGS_DIRS=$P/.tmp/conda
export HF_HOME=$P/.tmp/hf TRITON_CACHE_DIR=$P/.tmp/triton XDG_CACHE_HOME=$P/.tmp/cache
mkdir -p $TMPDIR
```

In job scripts give each job its own scratch directory, as in the
[Slurm Guide](slurm-guide.md#batch-job-gpu) template.

## When you run out of space

`Disk quota exceeded` can come from home, `/tmp` or a project directory.

```bash
storagemgr                         # project usage against quota (interactive)
du -sh ~ /tmp                      # home and your /tmp
du -sh ~/* ~/.[!.]* | sort -h      # what is large in home
find /tmp -user $USER -mtime +30 -delete
```

Move large items to a project directory. IDE remote installs (e.g.
`~/.vscode-server`) and Conda environments in home are common culprits.
