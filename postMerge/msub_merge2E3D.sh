#!/bin/bash
#MSUB -A p30144
#MSUB -q normal
#MSUB -l walltime=06:00:00
#MSUB -M nbush257@gmail.com
#MSUB -m a
#MSUB -N merge2E3D
#MSUB -l nodes=1:ppn=12


# load modules you need to use
module load matlab

cd /home/neb415/
matlab -nodisplay -r "lp;merge2E3D('$FNAME')";
