#!/usr/bin/ruby

dir = ARGV[0]
flows = ARGV[1]
count = 0

for i in 0...flows.to_i
    #puts i

    # Format of the output: "#_of_times_dropped" "flow_#" "seq_#"
    system("cat #{dir}/out.tra | grep '^d'| grep '\\-\\-\\- .* #{i+2}\\.0' | awk '{printf(\"%d %d\\n\", ((($8-1)-(#{flows}*2))/2)+1, $11);}' | sort -k 2 | uniq -c -f 1 | awk '{if($1>1) print($1, $2, $3);}'")
    #system("cat #{dir}/out.tra | grep '^d'| grep '\\-\\-\\- .* #{i+2}\\.0' | awk '{printf(\"%d %d\\n\", ((($8-1)-(#{flows}*2))/2)+1, $11);}' | sort -k 2 | uniq -c -f 1 | grep '^      2 '")
    #puts "--------------------------------------------"
end
