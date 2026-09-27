> [!CAUTION]
> **THIS IS A TUTORIAL, NOT FOR PRODUCTION USE.**
> It demonstrates how to run a container with the cluster's enroot/pyxis stack. Do not use it as-is; adapt it to your own work. Image and model names refer to public images you can find online yourself.

# Isaac Sim (headless, in a container)

Runs NVIDIA Isaac Sim from its NGC image as a batch job and saves rendered
frames to disk. Read the [Container Guide](../../container-guide.md) first.

| | |
|---|---|
| Recommended version | **Isaac Sim 6.1.0** (`nvcr.io/nvidia/isaac-sim:6.1.0`) |
| Do not use | 5.1.0: its renderer crashes on the cluster's driver (595) |
| Tested GPUs | `pro6000`, `l40`, `rtx5090`, `a40`, `6000ada`, `a6000` |
| Mode | Headless only; there is no display or GUI |
| Space needed | About 60 GB free on an SSD project during import; afterwards 19 GB for the image plus about 10 GB of layer cache in `$P/.enroot-cache`, which you can clear |

## Files

| File | Purpose |
|---|---|
| [`import.sbatch`](import.sbatch) | Step 2: import the image once |
| [`run.sbatch`](run.sbatch) | Step 3: run an example and save its output |
| [`headless.py`](headless.py) | Runs any Isaac Sim example headless, even if it asks for a window |

## 1. Prepare

Use an **SSD** project directory (`readlink -f /projects/YOUR_PROJECT` shows
`/projects/_ssd/...`); on HDD every start is far too slow. Copy the three files
into it and set `P` at the top of both `.sbatch` files.

```bash
P=/projects/YOUR_PROJECT
mkdir -p $P/isaac-sim $P/.tmp $P/.enroot-cache
cp headless.py $P/isaac-sim/
```

## 2. Import the image (once)

```bash
sbatch import.sbatch
```

This produces `$P/isaac-sim/isaac-sim-6.1.0.sqsh` (about 19 GB). If Docker Hub
or NGC pulls fail with `429`, see the Container Guide.

## 3. Run

```bash
sbatch run.sbatch
```

It runs NVIDIA's `sdg_getting_started_01.py` example, which renders a scene and
writes RGB images and 2D bounding boxes to `$P/isaac-sim/out/<jobid>/_out_basic_writer/`.
Replace `EXAMPLE` with your own script to run something else.

- The **first run takes 5 to 10 minutes**: the renderer compiles its shaders
  and caches them in `$P/isaac-sim/cache/kit` (about 0.5 GB per GPU model).
  Later runs on the same GPU model start in about 20 seconds.
- Change `--gres` to another GPU model if you like; Isaac Sim needs GPUs with RT
  cores.

## Why each setting is there

| Setting | Without it |
|---|---|
| `ACCEPT_EULA=Y`, `OMNI_KIT_ACCEPT_EULA=YES` | Isaac Sim refuses to start |
| `PRIVACY_CONSENT=N` | The app hangs at exit trying to send telemetry |
| `$D/cache/kit` mounted at `/isaac-sim/kit/cache` | Every run recompiles shaders (about 5 minutes) |
| `$D/home` mounted at `$HOME` | Caches and logs go to your real home, which is only 50 GB |
| NGX mounts (`libnvidia-ngx`, `nvidia/wine`) | No DLSS: images come out grainy, and `Failed to create NGX context` is logged |
| `OMNICLIENT_HUB_MODE=disabled` | Dozens of harmless `Hub failed to launch` warnings |
| `TMPDIR=/tmp` | A `TMPDIR` exported in your shell (e.g. `$P/.tmp`) is passed into the job but does not exist inside the container |
| `headless.py` | Examples that request a window fail, as there is no display |

## Common problems

| Symptom | Cause |
|---|---|
| Crash in `librtx.scenedb.plugin` right after `app ready` | You are running 5.1.0; use 6.1.0 |
| `Maximum loading time reached while waiting for assets to load` | Normal on a first run while shaders compile |
| Job ends with `Timeout (0:02:00)!` during shutdown | `PRIVACY_CONSENT` is not `N` |
| `Could not get NGX parameters block` | The NGX mounts are missing |
