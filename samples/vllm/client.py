# TUTORIAL ONLY - not for production use. See README.md.
"""Send one chat request and a small batch to a local vLLM server."""
import argparse
import concurrent.futures
import json
import time
import urllib.request

parser = argparse.ArgumentParser()
parser.add_argument("--port", type=int, required=True)
parser.add_argument("--model", required=True)
args = parser.parse_args()
URL = f"http://127.0.0.1:{args.port}/v1/chat/completions"


def chat(prompt, max_tokens=256):
    body = {
        "model": args.model,
        "messages": [{"role": "user", "content": prompt}],
        "max_tokens": max_tokens,
        "temperature": 0.7,
        # Qwen reasons ("thinks") first by default; turn it off for short answers.
        "chat_template_kwargs": {"enable_thinking": False},
    }
    req = urllib.request.Request(URL, json.dumps(body).encode(), {"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=600) as r:
        out = json.load(r)
    return out["choices"][0]["message"]["content"], out["usage"]["completion_tokens"]


text, _ = chat("In three sentences, explain what a GPU cluster scheduler does.")
print("=== single request\n" + text.strip())

prompts = [f"Write a short paragraph about the number {n}." for n in range(32)]
t0 = time.time()
with concurrent.futures.ThreadPoolExecutor(max_workers=32) as pool:
    results = list(pool.map(lambda p: chat(p, 256), prompts))
dt = time.time() - t0
tokens = sum(n for _, n in results)
print(f"=== batch: {len(prompts)} requests, {tokens} tokens in {dt:.1f} s ({tokens / dt:.0f} tokens/s)")
