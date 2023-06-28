#!/bin/bash

#$-l rt_F=1
#$-j y
#$-cwd
#$ -l h_rt=2:00:00

source /etc/profile.d/modules.sh
module load gcc/12.2.0
module load python/3.10/3.10.10
module load cuda/10.2
module load cudnn/8.0/8.0.5
module load nccl/2.8/2.8.4-1
source ~/optenv/bin/activate