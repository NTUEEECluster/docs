> [!CAUTION]
> **THIS IS A TUTORIAL, NOT FOR PRODUCTION USE.**
> It demonstrates how to run a container with the cluster's enroot/pyxis stack. Do not use it as-is; adapt it to your own work. Image and model names refer to public images you can find online yourself.

# vLLM: Qwen3.8-27B-FP8

Serves an LLM with vLLM inside a batch job, sends it requests, then stops. Read
the [Container Guide](../../container-guide.md) first.

| | |
|---|---|
| Image | `nvcr.io/nvidia/vllm:26.08-py3` (NVIDIA's vLLM build) |
| Model | `Qwen/Qwen3.8-27B-FP8`, 31 GB, Apache-2.0 |
| Tested GPUs | `pro6000`, `l40` (1 GPU each) |
| Space needed | About 55 GB on an SSD project |

The server listens on `127.0.0.1` inside your job and stops when the job ends.
Running a public or long-lived inference endpoint on the cluster is not allowed
(see the [Terms](../../terms-n-conditions.md)).

## Files

| File | Purpose |
|---|---|
| [`import.sbatch`](import.sbatch) | Step 1: import the image once |
| [`download.sbatch`](download.sbatch) | Step 2: download the model once |
| [`serve.sbatch`](serve.sbatch) | Step 3: start vLLM, run the client, stop |
| [`client.py`](client.py) | One chat request plus a 32-request batch against the local server |

## Steps

Use an **SSD** project directory, set `P` at the top of each `.sbatch`, then:

```bash
P=/projects/YOUR_PROJECT
mkdir -p $P/vllm $P/hf $P/.tmp $P/.enroot-cache
cp client.py $P/vllm/

sbatch import.sbatch                 # about 25 min
sbatch download.sbatch               # after the import finishes, about 10 min
sbatch serve.sbatch                  # after the download finishes
```

`serve.sbatch` prints the time the server took to load, the answer to one
question, and the throughput of a 32-request batch. The server log is
`$P/vllm/server-<jobid>.log`. Measured:

| GPU | Server ready (first run / later runs) | Batch throughput |
|---|---|---|
| `pro6000` | 220 s / 80 s | 690-950 tokens/s |
| `l40` | 380 s / – | 370 tokens/s |

The first run compiles the model (about 100 s) and caches the result in
`$P/vllm/home/.cache/vllm`; later runs on the same GPU model reuse it.

## Adapting it

- **Other models:** change `MODEL` in `download.sbatch` and `serve.sbatch`.
- **Your own requests:** edit `client.py`; the server speaks the OpenAI API, so
  the `openai` Python package works too (`base_url=http://127.0.0.1:<port>/v1`).
- **Other GPUs:** change only `--gres`. On a 48 GB GPU (`l40`, `6000ada`) this
  model leaves about 11 GB for the KV cache, enough for 5 requests of 32k
  tokens at once. Lower `--max-model-len` if you need more.
- **Larger models:** request more GPUs on one node and add
  `--tensor-parallel-size <N>`.

## Common problems

| Symptom | Cause |
|---|---|
| `server died` | Read `server-<jobid>.log`; most often not enough GPU memory for `--max-model-len` |
| `max_num_seqs (256) exceeds available Mamba cache blocks` | This model keeps one state block per running request; `--max-num-seqs 64` fits a 48 GB GPU |
| Answers start with `<think>` | Thinking mode; `client.py` turns it off with `enable_thinking: False` |
