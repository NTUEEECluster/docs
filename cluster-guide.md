# Cluster Guide

## Layout

```
your computer ──SSH──> login nodes ──Slurm──> compute nodes
  (NTU network/VPN)    (no GPU)                (GPU and CPU nodes)
                           │                        │
                           └──── shared storage ────┘
```

- **Login nodes** are for editing, file transfer and job submission. You land
  on one of several; they share the same files.
- **Compute nodes** run your jobs. GPU nodes carry one GPU model each; CPU nodes
  have no GPU. All are in the single partition `cluster02`. You can only SSH
  into a compute node while you have a job running on it.
- **Storage** is network-backed and identical on every node, so a file written
  on the login node is visible in your job. See the [Storage Guide](storage-guide.md).
- **VPN** is not maintained by the cluster team but NTU IT service. Please ask relevant
  offices for directions.

Nodes, GPU models and counts change over time, so look them up live instead of
relying on a list.

## Look up nodes

```bash
# every node: CPUs, RAM (MiB), GPUs, state
sinfo -o "%.20N %.6c %.8m %.28G %.10t"

# GPU models you can name in --gres
sinfo -h -o "%G" | tr ',' '\n' | sed -E 's/\(.*//; s/:[0-9]+$//' | sort -u

# which GPUs are in use right now, per node
sinfo -N -O "NodeList:18,Gres:22,GresUsed:34,StateCompact:8"

# full details of one node
scontrol show node <node_name>
```

A `--gres` entry reads `gpu:<model>:<count>`; the model is what you put in your
job's `--gres=gpu:<model>:<N>`. A model you are not allowed to use is rejected
at submission with a message saying so.

Node states: `idle` (free), `mix` (partly used), `alloc` (full), `drain` /
`down` (unavailable), `maint` (maintenance). A `*` after the state means the
node is not responding.

## GPU and software notes

- All GPU nodes run NVIDIA driver 595, which supports CUDA up to 13.x.
- `pro6000` and `rtx5090` are Blackwell (`sm_120`): use CUDA 12.8 or newer and
  a matching PyTorch build (e.g. `cu128`). Older builds fail with
  `no kernel image is available for execution on the device`.
- Software comes from Lmod modules and your own Conda environments; see the
  [Slurm Guide](slurm-guide.md#software). There is no `sudo`.
