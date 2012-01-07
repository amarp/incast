#!/bin/bash

if [ $# -ne 3 ]
then
    echo "Error in $0 - Invalid Argument Count"
    echo "Syntax: $0 number_of_servers sru_size run_number"
    exit
fi

head -n $1 node_list_all.txt > node_list.txt

cat node_list.txt

echo "######################################################################"
echo "RUNNING SERVERS ON ALL MACHINES"
echo "######################################################################"
./_do_all.sh node_list.txt _run_server.sh

sleep 5
echo "######################################################################"
echo "RUNNING CLIENT"
echo "######################################################################"
let i_servers=$(wc -l node_list.txt | cut -f1 --delim=' ')
echo ${i_servers}

#cat node_list.txt | while read host 
#do 
#        server_list="${server_list} $host"
#        echo -n $server_list > temp.server_list.txt
#        #echo $host
#done

# Amar:: I hate bash for doing this to me. :(
# http://db.ilug-bom.org.in/Documentation/abs-guide/redircb.html#REDIR2
#server_list=$(tail -n 1 temp.server_list.txt)
#echo ${server_list}
#rm temp.server_list.txt
echo $2
mkdir -p ./logs/$3
../src/client/a.out ${i_servers} node_list.txt 65125 $2 1 100 | tee ./logs/$3/client_$1_$2.log

sleep 5
echo "######################################################################"
echo "KILLING SERVERS ON ALL MACHINES"
echo "######################################################################"
./_do_all.sh node_list.txt _kill_server.sh

rm node_list.txt

