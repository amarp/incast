#!/bin/bash

echo $1
echo $2

#./_run_servers_and_client.sh 2 $1 $2
#./_run_servers_and_client.sh 4 $1 $2
#./_run_servers_and_client.sh 6 $1 $2
#./_run_servers_and_client.sh 8 $1 $2
#./_run_servers_and_client.sh 10 $1 $2

#for i in `seq 9 15`; do ./_run_servers_and_client.sh $i $1 $2; done
#for i in `seq 17 31`; do ./_run_servers_and_client.sh $i $1 $2; done

for i in `seq 1 32`; do ./_run_servers_and_client.sh $i $1 $2; done
