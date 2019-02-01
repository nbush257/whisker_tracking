#! /bin/bash/
for filename in /projects/p30144/merge_missing_data/*.mat
do
f_out=${filename/tracked.mat/toMerge.mat}
echo $f_out
if [[ ! -f "$f_out" ]]; then
export FNAME=$filename
echo $FNAME 
msub -v FNAME whisk2merge_msub.sh
fi
done


