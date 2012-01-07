#/bin/bash -x

for i in `seq 1 10`; do ./_run_all.sh 256000 $i; done
#./_run_all.sh 256000 1
