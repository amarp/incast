#!/bin/bash -x

# usage :  ./_do_all file_with_node_listing cmd_file

cat $1 | while read host 
do 
	./$2 $host $3
	#echo $host
done

