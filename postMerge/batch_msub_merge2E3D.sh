#! /bin/bash/
for filename in /projects/p30144/tracked_3D_matlab_calib/rat2015_14*C2*tracked_3D.mat
do
f_out=${filename/tracked_3D.mat/toE3D.mat}
echo $f_out
if [[ ! -f "$f_out" ]]; then
export FNAME=$filename
echo $FNAME 
msub -v FNAME msub_merge2E3D.sh
fi
done


