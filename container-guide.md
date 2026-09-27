# Container Guide

> **For experienced users.** Containers are for batch jobs, not interactive
> work. If you are new, use Conda instead ([Slurm Guide](slurm-guide.md#software)).

Jobs can run inside Docker/OCI images from Docker Hub, NGC or other registries.
Docker itself is not available (it needs root). Instead:

- **enroot** imports an image into a single squashfs file (`.sqsh`) and runs it
  without root.
- **pyxis** adds `--container-*` options to `srun`.

Educational examples (not for production) are in [samples/](samples/).

At each job step pyxis mounts your `.sqsh` read-only, adds a writable layer in
memory and runs your command inside it **as your own user**. Your allocated GPUs,
and only those, appear inside. The host filesystem is hidden unless you mount
it. Containers run on compute nodes only.

## 1. Directories you must set

Left at their defaults, enroot, pip and model downloads write into your home
(50 GB), your `/tmp` (4 GB, shared by all your jobs on every node) or the
container's writable layer (job memory, discarded when the step ends). All
three fill up quickly with images and models. Set every item below to an
**SSD** project directory `$P` (see the [Storage Guide](storage-guide.md);
`readlink -f $P` must show `/projects/_ssd/...`):

| What | Set with | Default location (the limit it hits) | Set to |
|---|---|---|---|
| Image file | `enroot import -o`, then `--container-image` | a registry name unpacks the whole image into `~/.enroot` on every step (home) | `$P/<image>.sqsh` |
| Import scratch | `ENROOT_TEMP_PATH` | `~/.enroot`, about 2× the image during import (home) | `$P/.tmp/$SLURM_JOB_ID` |
| Layer cache | `ENROOT_CACHE_PATH` | `~/.enroot/cache` (home) | `$P/.enroot-cache` |
| Job scratch | `TMPDIR` | `/tmp` (4 GB) | `$P/.tmp/$SLURM_JOB_ID` |
| Home inside the container | `--container-mounts=$P/<app>/home:$HOME` | container layer: app caches rebuilt every step, held in job memory | `$P/<app>/home` |
| Model downloads | `HF_HOME` (Hugging Face), `TORCH_HOME` (PyTorch hub) | `~/.cache/...` (home, or job memory inside the container) | `$P/hf`, `$P/torch` |
| Extra pip packages | `PYTHONUSERBASE`, `PIP_CACHE_DIR` | `~/.local`, `~/.cache/pip` | `$P/<app>/pyuser`, `$P/.tmp/pip` |
| Other caches | `XDG_CACHE_HOME`, `TRITON_CACHE_DIR` | `~/.cache` | `$P/.tmp/cache`, `$P/.tmp/triton` |
| Your data and outputs | `--container-mounts=$P:$P` | not visible; anything written outside a mount is lost | the same path inside and out |

Create the shared ones once:

```bash
P=/projects/YOUR_PROJECT
mkdir -p $P/.tmp $P/.enroot-cache $P/hf
```

### Checklist before running a container

- [ ] `$P` is an SSD project directory with free space for the image (and 2×
      that during import) plus any models.
- [ ] `$P/.tmp`, `$P/.enroot-cache` and, for model downloads, `$P/hf` exist.
- [ ] The import job sets `ENROOT_TEMP_PATH` and `ENROOT_CACHE_PATH` under `$P`.
- [ ] `--container-image` points at a `.sqsh` file in `$P`, not a registry name.
- [ ] The job sets `TMPDIR=$P/.tmp/$SLURM_JOB_ID` and removes it at the end.
- [ ] `--container-mounts` includes `$P:$P` and `$P/<app>/home:$HOME`.
- [ ] `HF_HOME`, `TORCH_HOME`, `PYTHONUSERBASE` and `PIP_CACHE_DIR` (whichever
      your code uses) are passed with `--export` and point under `$P`.
- [ ] Results are written under a mounted path, not elsewhere in the container.
- [ ] `~/.enroot` is empty (`du -sh ~/.enroot`).

Keep `~/.enroot` empty, and never put any of these on HDD
(`/projects/_hdd`); every job start would crawl. Image sizes: about the unpacked
image, e.g. 18–25 GB for NGC PyTorch.

## 2. Import an image (once per image)

Import as a CPU batch job:

```bash
#!/bin/bash
#SBATCH -c 8
#SBATCH -t 90
P=/projects/YOUR_PROJECT
export ENROOT_TEMP_PATH=$P/.tmp/$SLURM_JOB_ID ENROOT_CACHE_PATH=$P/.enroot-cache
mkdir -p $ENROOT_TEMP_PATH
trap 'rm -rf $ENROOT_TEMP_PATH' EXIT

cd $P
enroot import -o pytorch.sqsh.part 'docker://nvcr.io#nvidia/pytorch:26.08-py3'
mv pytorch.sqsh.part pytorch.sqsh
```

Image names: `docker://ubuntu:24.04` (Docker Hub),
`docker://nvcr.io#nvidia/pytorch:<tag>` (NGC, note the `#`). The `.part` name
means a failed import never leaves a half-written image that looks complete.

## 3. Run it

```bash
#!/bin/bash
#SBATCH --gres=gpu:pro6000:2
#SBATCH -t 4:00:00
P=/projects/YOUR_PROJECT
export TMPDIR=$P/.tmp/$SLURM_JOB_ID
mkdir -p $TMPDIR $P/pytorch/home
trap 'rm -rf $TMPDIR' EXIT

srun --container-image=$P/pytorch.sqsh \
     --container-mounts=$P:$P,$P/pytorch/home:$HOME \
     --container-workdir=$P \
     --export=ALL,HF_HOME=$P/hf,TORCH_HOME=$P/torch \
     torchrun --nproc_per_node=2 train.py
```

- Always point `--container-image` at your `.sqsh`. A registry name makes pyxis
  pull and unpack the whole image into `~/.enroot` on **every** job step,
  ignoring your `ENROOT_*` settings; it is slow and fills your home.
- Mount host directories at the **same path** inside (`$P:$P`) so paths and
  `TMPDIR` mean the same in and out. Anything written outside a mount is lost
  when the step ends, and `/tmp` inside the container is RAM counted against
  your job.
- Allocated GPUs appear automatically from index 0. Do not set
  `NVIDIA_VISIBLE_DEVICES`.
- `--container-remap-root` makes you root inside the container only (e.g. for
  `apt-get install`); it grants nothing on the host.

## Managing space

```bash
ls -lh $P/*.sqsh                   # your images
du -sh $P/.enroot-cache ~/.enroot  # layer cache and anything left in home
enroot list                        # unpacked containers in ~/.enroot (should be none)
enroot remove -f <name>            # delete one of them
```

- Delete images you no longer use; each is tens of GB.
- The layer cache only speeds up re-imports of the same image; clear it
  (`rm -rf $P/.enroot-cache/*`) when space is tight.
- `--container-name` keeps an unpacked copy in `~/.enroot` between steps. Avoid
  it unless you need a writable container, and remove it afterwards.

## Pulling images: caveats

- Docker Hub limits anonymous pulls and fails with `429`. Use your own account:
  create a read-only access token, then

  ```bash
  mkdir -p ~/.config/enroot
  echo 'machine auth.docker.io login <username> password <token>' >> ~/.config/enroot/.credentials
  chmod 600 ~/.config/enroot/.credentials
  ```

- Pick tags that match the hardware: `pro6000` and `rtx5090` are Blackwell
  (`sm_120`) and need CUDA 12.8+ images; multi-GPU needs NCCL 2.27 or newer.
  Check with `python -c "import torch; print(torch.cuda.get_arch_list())"`.
- Import on a CPU node, as above, not on the login node.
- Pin a specific tag instead of `latest`, so a re-import gives the same image.

## Common problems

| Message | Meaning |
|---|---|
| `returned error code: 429` | Docker Hub limit; use your own account. |
| `401 Unauthorized` | Image or tag does not exist, or is private. |
| `Invalid argument: <file>.sqsh` | Wrong path, or the file is not readable by you. |
| Import stops at `Extracting image layers...` | A quota is full; check `~/.enroot` and `$P/.tmp`. |
| Slow start on every job | You gave a registry name instead of a `.sqsh`. |
| `peer mapping resources exhausted` | One process driving more than 8 GPUs; use one process per GPU or set `NCCL_CUMEM_ENABLE=0`. |
| `pyxis: ... task_init() failed` | Follows another error; read the lines above it. |
