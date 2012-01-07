#!/usr/bin/ruby

# eg : ./detect_last_packet_drop.rb ../data_dump/tcp_256K/newreno_flow_8_s_256K_buf_64_time_20s/
dir = ARGV[0]

# last packet in the (n-1)st synch round.
# seq_number = 2 + (256 * n) -1

# Format of the output: "dupacksAtTimeout" "timeAtWhichTimeoutOccured" "flow_#" "seq_#"
system("cat #{dir}/temp/dupacksAtTimeout.dat | awk '{dupacksAtTimeout = $1; flow_id = $4; seq = $5; num = (seq - 1)%256;  if(num == 0) {printf(\"%d %f %d %d\\n\", $1, $3, $4, $5);}}'")

