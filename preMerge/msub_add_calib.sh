#!/bin/bash
#MSUB -A p30054
#MSUB -q short
#MSUB -l walltime=4:00:00
#MSUB -M nbush257@gmail.com

#MSUB -m e
#MSUB -N add_calibInfo
#MSUB -l nodes=1:ppn=1


# load modules you need to use
module load matlab


# A command you actually want to execute:
matlab -nodisplay -r "lp;add_calibInfo_to_tracked";

