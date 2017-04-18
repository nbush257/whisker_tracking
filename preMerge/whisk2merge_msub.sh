#!/bin/bash
#MSUB -A p30054
#MSUB -q short
#MSUB -l walltime=4:00:00
#MSUB -M nbush257@gmail.com
#MSUB -m a
#MSUB -N whisk2merge
#MSUB -l nodes=1:ppn=16


# load modules you need to use
module load matlab

cd /home/neb415/proc/whisker_tracking/preMerge

# A command you actually want to execute:
matlab -nodisplay -r "whisk2merge_wrapper('$FNAME')";

