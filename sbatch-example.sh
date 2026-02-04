#!/bin/bash

#SBATCH --job-name=some_name_to_make_it_easier_for_you
#SBATCH --time=00:01:00
#SBATCH --gpus=0       # Write the number of GPUs you need.
#SBATCH --constraint=  # Write gpu, gpu_16g, gpu_32g, or gpu_48g based on your requirement.
                       # Check cluster.md for a full list of possible requirements.

# NOTE:
# For a list of helpful flags to specify above, check out Slurm Overview in slurm.md.

module load Miniforge3  
conda activate my_environment  
python my_script.py
