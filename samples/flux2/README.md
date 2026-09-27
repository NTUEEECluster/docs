> [!CAUTION]
> **THIS IS A TUTORIAL, NOT FOR PRODUCTION USE.**
> It demonstrates how to run a container with the cluster's enroot/pyxis stack. Do not use it as-is; adapt it to your own work. Image and model names refer to public images you can find online yourself.

# FLUX.2-dev (text to image, in a container)

Generates an image from a text prompt with Black Forest Labs' FLUX.2-dev, using
Hugging Face `diffusers` inside NVIDIA's NGC PyTorch image. Read the
[Container Guide](../../container-guide.md) first.

| | |
|---|---|
| Recommended image | **NGC PyTorch 26.08** (`nvcr.io/nvidia/pytorch:26.08-py3`) |
| Tested GPU | 1× `pro6000` (96 GB), with the default job memory |
| Speed | About 2 minutes per job for one 1024×1024 image (50 steps at 1.3 s each) |
| Space needed | About 180 GB free on an SSD project: image 21 GB (twice that while importing), weights 113 GB, Python packages 0.2 GB |
| Model | `black-forest-labs/FLUX.2-dev` on Hugging Face; gated, under the FLUX Non-Commercial License (non-commercial use only) |

## Files

| File | Purpose |
|---|---|
| [`import.sbatch`](import.sbatch) | Step 2: import the image once |
| [`setup.sbatch`](setup.sbatch) | Step 3: install `diffusers` and download the weights once |
| [`generate.sbatch`](generate.sbatch) | Step 4: generate an image |
| [`generate.py`](generate.py) | Runs the model in two stages so it fits on one GPU |

## 1. Prepare

FLUX.2-dev is a gated model: request access on its Hugging Face page and make
sure `hf` can download it before running setup.

Use an **SSD** project directory (`readlink -f /projects/YOUR_PROJECT` shows
`/projects/_ssd/...`). Copy the four files into it and set `P` at the top of
the three `.sbatch` files.

```bash
P=/projects/YOUR_PROJECT
mkdir -p $P/flux2 $P/.tmp $P/.enroot-cache
cp generate.py $P/flux2/
```

## 2. Import the image (once)

```bash
sbatch import.sbatch
```

This produces `$P/flux2/pytorch-26.08-py3.sqsh` (about 21 GB) in about 10 minutes.

## 3. Install and download (once)

```bash
sbatch setup.sbatch
```

This installs `diffusers`, `transformers` and `accelerate` into `$P/flux2/pyuser`,
then downloads the model into `$P/hf` (about 20–60 minutes, depending on the
Hub). The log ends with `✓ Downloaded`. If it stops part way, submit it again;
it resumes.

## 4. Generate

```bash
sbatch generate.sbatch
```

The image is saved as `$P/flux2/out/<jobid>/flux2.png`. The log shows the
time and GPU memory of each stage:

```
Text encoding: 19 s, peak GPU memory 45.4 GiB
Image generation: 99 s, peak GPU memory 62.6 GiB
```

Change `PROMPT` in `generate.sbatch` to draw something else. `SEED`, `STEPS`,
`GUIDANCE` and `SIZE` are at the top of `generate.py`; the same seed and prompt
give the same image.

## Why each setting is there

| Setting | Without it |
|---|---|
| Two stages in `generate.py` | The text encoder (48 GB) and transformer (64 GB) together do not fit on a 96 GB GPU |
| `device_map="cuda"` | Weights pass through host memory first; the job's default 33 GB is not enough |
| `HF_HOME=$P/hf` | The 113 GB of weights go to your home, which is only 50 GB |
| `HF_HUB_OFFLINE=1` and `local_files_only=True` | Every job contacts the Hub, and fails if it is slow or down |
| `PYTHONUSERBASE=$P/flux2/pyuser` | `pip install --user` goes into your home; the image itself is read-only |
| `$P/flux2/home` mounted at `$HOME` | Caches written by the libraries go to your real home |
| `--exclude` in `setup.sbatch` | An extra 64 GB single-file copy of the model is downloaded, which `diffusers` does not use |

## Common problems

| Symptom | Cause |
|---|---|
| `401` or `GatedRepoError` during setup | Your Hugging Face account does not have approved access to the model |
| `ModuleNotFoundError: No module named 'diffusers'` | `setup.sbatch` has not run, or `PYTHONUSERBASE` is not set |
| `OfflineModeIsEnabled: Cannot reach the Hugging Face API` | Your own script calls `from_pretrained` without `local_files_only=True` |
| `IncompleteSnapshotError: ... flux2-dev.safetensors` | Your own script calls `snapshot_download()`; the single-file copy was skipped on purpose, so load with `local_files_only=True` instead |
| `CUDA out of memory` | Both models were loaded at once, e.g. with `pipe.to("cuda")` |
| Warnings about `torchao`, `tie_word_embeddings`, `processor_kwargs` or `local_dir_use_symlinks` | Harmless |
