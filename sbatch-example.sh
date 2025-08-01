#!/bin/bash

#SBATCH --job-name=some_name_to_make_it_easier_for_you
#SBATCH --time=00:01:00
#SBATCH --gres=gpu:example:0

# NOTE:
# For a list of helpful flags to specify above, check out Slurm Overview in slurm.md.

module load Miniforge3  
conda activate my_environment  
python my_script.py
