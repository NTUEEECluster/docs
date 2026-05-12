#!/bin/bash

#SBATCH --job-name=some_name_to_make_it_easier_for_you
#SBATCH --time=01:00:00         # hh:mm:ss; sbatch hard cap is 3 days (3-00:00:00)
#SBATCH --gpus=a40:1            # required: <model>:<count>. Models: 6000ada, a40, a6000, l40, pro6000
#SBATCH --output=job-%j.out     # %j is replaced with the job ID
#SBATCH --error=job-%j.err

# NOTE:
# - Do NOT set --mem or --cpus-per-task; CPU/RAM are auto-assigned per GPU count.
# - For more flags and policies, see slurm.md and cluster.md.

module load Miniforge3
source activate my_environment
python my_script.py
