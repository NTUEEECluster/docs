# TUTORIAL ONLY - not for production use. See README.md.
"""Generate one image with FLUX.2-dev on a single 96 GB GPU.

The text encoder (48 GB) and the transformer (64 GB) do not fit on the GPU
together, so they run one after the other: encode the prompt, free the text
encoder, then load the transformer and VAE and denoise.

Usage: python generate.py OUTPUT.png "prompt"
"""
import gc
import sys
import time

import torch
from diffusers import AutoencoderKLFlux2, Flux2Pipeline, Flux2Transformer2DModel
from transformers import Mistral3ForConditionalGeneration

REPO = "black-forest-labs/FLUX.2-dev"
# local_files_only: diffusers contacts the Hub for sharded models even when
# HF_HUB_OFFLINE=1, and the job then fails.
LOAD = dict(dtype=torch.bfloat16, local_files_only=True)
SEED, STEPS, GUIDANCE, SIZE = 42, 50, 4.0, 1024

out, prompt = sys.argv[1], sys.argv[2]


def report(stage, t0):
    peak = torch.cuda.max_memory_allocated() / 2**30
    print(f"{stage}: {time.time() - t0:.0f} s, peak GPU memory {peak:.1f} GiB", flush=True)
    torch.cuda.reset_peak_memory_stats()


# Stage 1: prompt -> embeddings, text encoder only.
t0 = time.time()
text_encoder = Mistral3ForConditionalGeneration.from_pretrained(
    REPO, subfolder="text_encoder", **LOAD, device_map="cuda"
)
pipe = Flux2Pipeline.from_pretrained(
    REPO, text_encoder=text_encoder, transformer=None, vae=None, **LOAD
)
with torch.no_grad():
    prompt_embeds, _ = pipe.encode_prompt(prompt, device="cuda")
del pipe, text_encoder
gc.collect()
torch.cuda.empty_cache()
report("Text encoding", t0)

# Stage 2: embeddings -> image, transformer and VAE only.
t0 = time.time()
transformer = Flux2Transformer2DModel.from_pretrained(
    REPO, subfolder="transformer", **LOAD, device_map="cuda"
)
vae = AutoencoderKLFlux2.from_pretrained(REPO, subfolder="vae", **LOAD).to("cuda")
pipe = Flux2Pipeline.from_pretrained(
    REPO, transformer=transformer, vae=vae, text_encoder=None, tokenizer=None, **LOAD
)
image = pipe(
    prompt_embeds=prompt_embeds,
    height=SIZE,
    width=SIZE,
    num_inference_steps=STEPS,
    guidance_scale=GUIDANCE,
    generator=torch.Generator("cuda").manual_seed(SEED),
).images[0]
report("Image generation", t0)

image.save(out)
print("Saved", out)
