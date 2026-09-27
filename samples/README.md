> [!CAUTION]
> **THIS IS A TUTORIAL, NOT FOR PRODUCTION USE.**
> These examples demonstrate how to run containers with the cluster's enroot/pyxis stack. Do not use them as-is; adapt them to your own work. Image and model names refer to public images you can find online yourself.

# Samples

Worked examples that run popular containers on the cluster, step by step. Each
one was run end to end on the cluster before being published. Read the
[Container Guide](../container-guide.md) first; these assume you know it.

| Sample | Image | What it does |
|---|---|---|
| [Isaac Sim](isaac-sim/) | `nvcr.io/nvidia/isaac-sim:6.1.0` | Renders a scene headless and saves images and labels |
| [FLUX.2](flux2/) | `nvcr.io/nvidia/pytorch:26.08-py3` | Generates an image from a text prompt with FLUX.2-dev |
| [vLLM](vllm/) | `nvcr.io/nvidia/vllm:26.08-py3` | Serves Qwen3.8-27B-FP8 inside a job and sends it requests |

Every sample keeps images, models and caches in an SSD project directory set as
`P=/projects/YOUR_PROJECT` at the top of each script.
