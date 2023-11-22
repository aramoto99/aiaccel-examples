#!/bin/bash

#$-l rt_C.small=1
#$-j y
#$-cwd

source /etc/profile.d/modules.sh
module load gcc/12.2.0
module load python/3.11

export PYTHONPATH=~/mpi_work/aiaccel:$PYTHONPATH
source ~/mpi_work/mpienv/bin/activate


python -m aiaccel.cli.start --config config.yaml --make_hostfile

mpiexec -n 2 -hostfile ./hostfile python -m mpi4py.futures -m aiaccel.cli.start --config config.yaml --clean --from_mpi_bat

deactivate
