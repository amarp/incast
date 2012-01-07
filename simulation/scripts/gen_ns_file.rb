#!/usr/bin/ruby

# flows synchSize bufSize runTimeInSec
if ARGV.size < 5
    puts "This is a Ruby script to generate a ns tcl file to simulate incast"
    puts "Usage: ./gen_ns_file.rb numFlows synchSize bufSize runTimeInSec runType(for dir creation) minRto"
    exit
end

=begin
puts "No. of args = #{ARGV.size}"
ARGV.each { |a| puts "Arg = #{a}" }
puts ARGV[0] if ARGV[0] 
puts ARGV[1] if ARGV[1] 
=end

flows = ARGV[0]

# if flows.to_i < 2
#     puts "You should specify more than 1 flow!"
#     exit
# end

synchSize = ARGV[1].to_i
synchSizeInK = synchSize/1000
bufSizeInPackets = ARGV[2]
runTimeInSec = ARGV[3]
runType = ARGV[4]

if ARGV.size == 6
    minRtoVal = ARGV[5]
    puts "min_rto = #{minRtoVal}"
else
    # 200u (for rto runs only)
    minRtoVal = 0.0002
    puts "default! min_rto = #{minRtoVal}"
end

tcp_agent_type = "Reno"
tcp_sink_agent_type = "TCPSink"
queue_type = "DropTail"
max_ssthresh = 0

if runType == "reno" || runType == "reno_lt" || runType == "reno_dup1" || runType == "reno_rto"  || runType == "reno_noss" then
    tcp_agent_type = "Reno"
    tcp_sink_agent_type = "TCPSink"
    queue_type = "DropTail"
elsif runType == "newreno" || runType == "newreno_lt" || runType == "newreno_dup1"  || runType == "newreno_rto"  || runType == "newreno_noss" || runType == "newreno_dup1_noss" then
    tcp_agent_type = "Newreno"
    tcp_sink_agent_type = "TCPSink"
    queue_type = "DropTail"
elsif runType == "delack_newreno" then
    tcp_agent_type = "Newreno"
    tcp_sink_agent_type = "TCPSink/DelAck"
    queue_type = "DropTail"
elsif runType == "sack" || runType == "sack_rto" || runType == "sack_noss" || runType == "sack_dup1" then
    tcp_agent_type = "Sack1"
    tcp_sink_agent_type = "TCPSink/Sack1"
    queue_type = "DropTail"
elsif runType == "fack" || runType == "fack_dup1" then
    tcp_agent_type = "Fack"
    tcp_sink_agent_type = "TCPSink/Sack1"
    queue_type = "DropTail"
elsif runType == "reno_red" then
    tcp_agent_type = "Reno"
    tcp_sink_agent_type = "TCPSink"
    queue_type = "RED"
elsif runType == "newreno_red" then
    tcp_agent_type = "Newreno"
    tcp_sink_agent_type = "TCPSink"
    queue_type = "RED"
elsif runType == "sack_red" then
    tcp_agent_type = "Sack1"
    tcp_sink_agent_type = "TCPSink/Sack1"
    queue_type = "RED"
end

# setting max_ssthresh to anything above 0 makes sure that this value is considered;
# setting it to 1 ensures that we are never in slow-start, and always apply additive increase
# see TcpAgent::reset() and void TcpAgent::opencwnd() 
# point of interest -> TcpAgent::reset() => if ((max_ssthresh_ > 0) && (max_ssthresh_ < ssthresh_)) ssthresh_ = max_ssthresh_;
# and TcpAgent::opencwnd() uses max_ssthresh_ in congestion aviodance
if runType == "newreno_noss" || runType == "reno_noss" || runType == "sack_noss" || runType == "newreno_dup1_noss" then
    max_ssthresh = 1
end

traceDirName = "../data_dump/#{runType}_flow_#{flows}_s_#{synchSizeInK}K_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s"
puts traceDirName

out = File.new("../tcl_gen/#{runType}_incast_flows_#{flows}_synchSizeInK_#{synchSizeInK}_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s.tcl", "w") 

## NS TCL FILE GENERATION ##
out.puts "
set ns [new Simulator]

$ns color 1 red
$ns color 2 blue
$ns color 3 cyan
$ns color 4 green
$ns color 5 orange
$ns color 6 black
$ns color 7 yellow
$ns color 8 purple
$ns color 9 gold
$ns color 10 chocolate
$ns color 11 brown
$ns color 12 tan
$ns color 13 black
$ns color 14 pink
$ns color 15 magenta
$ns color 16 violet
$ns color 17 red
$ns color 18 blue
$ns color 19 cyan
$ns color 20 green
$ns color 21 orange
$ns color 22 black
$ns color 23 yellow
$ns color 24 purple
$ns color 25 gold
$ns color 26 chocolate
$ns color 27 brown
$ns color 28 tan
$ns color 29 black
$ns color 30 pink
$ns color 31 magenta
$ns color 32 violet
$ns color 33 red
$ns color 34 blue
$ns color 35 cyan
$ns color 36 green
$ns color 37 orange
$ns color 38 black
$ns color 39 yellow
$ns color 40 purple
$ns color 41 gold
$ns color 42 chocolate
$ns color 43 brown
$ns color 44 tan
$ns color 45 black
$ns color 46 pink
$ns color 47 magenta
$ns color 48 violet

set xnam 0

set tracedir #{traceDirName}
set synchSize #{synchSize}
set bufSize #{bufSizeInPackets}
set runTimeInSec #{runTimeInSec}.0

set fall [open ./$tracedir/out.tra w]
$ns trace-all $fall
#set fnam [open ./$tracedir/out.nam w]
# $ns namtrace-all $fnam

# create output files for bandwidth per nodes (moving average)
set f0 [open ./$tracedir/tput_moving.tr w]
set f1 [open ./$tracedir/tput_instantaneous.tr w]

# record average bw statistics
set favg_ind [open ./$tracedir/tput_cum_ind_avg.tr w]
set favg_tot [open ./$tracedir/tput_cum_tot_avg.tr w]

"

for i in 1..flows.to_i
    out.puts "set avg#{i} 0"
    out.puts "set bw_interval_#{i} 0.0"
end

out.puts "
set i 0

proc finish {} {

        #global ns fall fnam f0 f1 favg_ind favg_tot tracedir
        global ns fall f0 f1 favg_ind favg_tot tracedir
        $ns flush-trace
	#Close the trace file
        #close $fnam
	#Execute nam on the trace file
        #exec nam ./$tracedir/out.nam &

        #Close the output files
        close $f0
        close $f1
        close $favg_ind
        close $favg_tot

        exit 0
    }

set client_node [$ns node]
set router [$ns node]
"

for i in 1..flows.to_i
    out.puts "set server_node_#{i} [$ns node]"
end

out.puts "
$ns duplex-link $client_node $router 1000Mb 25us #{queue_type}
$ns queue-limit $client_node $router 1000
$ns queue-limit $router $client_node $bufSize
"

for i in 1..flows.to_i
    out.puts "
$ns duplex-link $router $server_node_#{i} 1000Mb 25us #{queue_type}
# $ns queue-limit $router $server_node_#{i} 4
# $ns queue-limit $server_node_#{i} $router 8
"
end

out.puts "
$ns duplex-link-op $client_node $router orient right
$ns duplex-link-op $client_node $router queuePos 0.5
"

for i in 1..flows.to_i
    out.puts "\
$ns duplex-link-op $router $server_node_#{i} orient right-up
$ns duplex-link-op $router $server_node_#{i} queuePos 0.5
"
end


if runType.include? "sack"
    out.puts "\
Agent/TCP set partial_ack_ true
"
end

out.puts "
# dummy
set tcpc0 [new Agent/TCP/FullTcp]
$ns attach-agent $client_node $tcpc0

# client_node
"

fid_count = 1
for i in 1..flows.to_i
    out.puts "\
set tcpc#{i} [new Agent/TCP/#{tcp_agent_type}]
$tcpc#{i} set max_ssthresh_ #{max_ssthresh}
$tcpc#{i} set fid_ #{fid_count}
$ns attach-agent $client_node $tcpc#{i}

set tcpc#{i}_sink [new Agent/#{tcp_sink_agent_type}]
$tcpc#{i}_sink set fid_ #{fid_count + 1}
$ns attach-agent $client_node $tcpc#{i}_sink

"

    fid_count = fid_count + 2
end


for i in 1..flows.to_i
    out.puts "\
# server_node_#{i}
set tcp#{i} [new Agent/TCP/#{tcp_agent_type}]
$tcp#{i} attach [open ./$tracedir/tcp#{i}.tr w]"
    
    out.puts "$tcp#{i} set bugFix_ false"

if runType == "reno_lt" || runType == "newreno_lt"
    out.puts "$tcp#{i} set singledup_ 1"
elsif runType == "reno_dup1" || runType == "newreno_dup1" || runType == "newreno_dup1_noss" || runType == "sack_dup1" || runType == "fack_dup1"
    out.puts "$tcp#{i} set numdupacks_ 1"
elsif runType == "reno_rto" || runType == "newreno_rto" || runType == "sack_rto"
    out.puts "$tcp#{i} set minrto_ #{minRtoVal}"
    out.puts "$tcp#{i} set maxrto_ #{minRtoVal}"
    #out.puts "$tcp#{i} set minrto_ 0.0002"
    #out.puts "$tcp#{i} set maxrto_ 0.0002"
end

 

    out.puts "\
$tcp#{i} trace cwnd_
$tcp#{i} trace ack_
$tcp#{i} trace ssthresh_
$tcp#{i} trace nrexmit_
$tcp#{i} trace nrexmitpack_
$tcp#{i} trace nrexmitbytes_
$tcp#{i} trace ncwndcuts_
$tcp#{i} trace ncwndcuts1_
$tcp#{i} trace dupacks_
# $tcp#{i} trace curseq_
# $tcp#{i} trace maxseq_
$tcp#{i} set fid_ #{fid_count}
$ns attach-agent $server_node_#{i} $tcp#{i}

set tcp#{i}_server_sink [new Agent/#{tcp_sink_agent_type}]
$tcp#{i}_server_sink set fid_ #{fid_count + 1}
$ns attach-agent $server_node_#{i} $tcp#{i}_server_sink

"
    fid_count = fid_count + 2
end

out.puts "# connect the seding agents to sinks"
for i in 1..flows.to_i
    out.puts "\
$ns connect $tcpc#{i} $tcp#{i}_server_sink 
$ns connect $tcp#{i} $tcpc#{i}_sink
"
end

out.puts ""
for i in 1..flows.to_i
    out.puts "\
$tcpc#{i}_sink listen
$tcp#{i}_server_sink listen
"
end

out.puts ""
out.puts "set capp [new Application/IncastTcpAppClient $tcpc0 $synchSize]"

out.puts ""
for i in 1..flows.to_i
    out.puts "\
set sapp#{i} [new Application/IncastTcpAppServer $tcp#{i} $synchSize]
"
end

out.puts ""
for i in 1..flows.to_i
    out.puts "\
$capp connect $sapp#{i} $tcpc#{i} $tcpc#{i}_sink
"
end

out.puts ""
for i in 1..flows.to_i
    out.puts "\
$tcp#{i}_server_sink setparent $sapp#{i}
"
end

out.puts "
$ns at 0.1 \"$capp start\"
$ns at 0.1 \"record\"
$ns at $runTimeInSec \"finish\"
"

str = ""
for i in 1..flows.to_i
    str += " tcpc#{i}_sink avg#{i} bw_interval_#{i}"
end

out.puts "
# Define a procedure which periodically records the bandwidth received by the
# three traffic sinks sink0/1/2 and writes it to the file f0.
proc record {} {
    global ns f0 f1 favg_ind favg_tot i #{str}"

out.puts "
    # Set the time after which the procedure should be called again
    set time 0.01

    set i [expr $i + $time]

    #Get the current time
    set now [$ns now]

    # Record how many bytes have been received by the traffic sinks.
"

for i in 1..flows.to_i
    out.puts "\
    set bw#{i} [$tcpc#{i}_sink set bytes_]
    set bw_interval_#{i} [expr $bw_interval_#{i} + $bw#{i}]"
end


str = ""
for i in 1..flows.to_i
    str += " [expr $bw_interval_#{i}/$i*8/1000000]"
end


str += " [expr ("

for i in 1..(flows.to_i-1)
	str+= " $bw_interval_#{i} +"
end

str += " $bw_interval_#{flows.to_i})/$i * 8/1000000]"


out.puts "
    if {$i >= 1.0} {
        puts $f0 \"$now#{str}\""

for i in 1..flows.to_i
    out.puts "        set bw_interval_#{i} 0"
end

out.puts "        set i 0.0
    }
"

out.puts "
    # Calculate the bandwidth (in MBit/s) and write it to the files
    # puts $f0 \"$now [expr $bw0/$time*8/1000000] [expr $bw1/$time*8/1000000] [expr ($bw0+$bw1)/$time*8/1000000]\"
"

str = "    puts $f1 \"$now "

for i in 1..flows.to_i
	str += "[expr $bw#{i}/$time*8/1000000] "
end

str += "[expr { wide("

for i in 1..(flows.to_i-1)
	str += "$bw#{i}+"
end

str += "$bw#{flows.to_i})/$time*8/1000000 }]\""

out.puts "#{str}"

for i in 1..flows.to_i
    out.puts "\
    set avg#{i} [expr { wide($avg#{i}) + $bw#{i} }]"
end

str = ""
for i in 1..flows.to_i
    str += " [expr $avg#{i}/($now-.09999999)*8/1000000]"
end

str1 = ""
for i in 1..flows.to_i
    str1 += "$avg#{i}"
    if i != flows.to_i
        str1 += "+"
    end
end

out.puts "
    puts $favg_ind \"$now#{str}\"
    puts $favg_tot \"$now [expr { wide(#{str1})/($now-.09999999)*8/1000000 }]\"

    # Reset the bytes_ values on the traffic sinks
"

for i in 1..flows.to_i
    out.puts "\
    $tcpc#{i}_sink set bytes_ 0"
end

out.puts "
    # Re-schedule the procedure
    $ns at [expr $now+$time] \"record\"
}
"

out.puts "$ns run"

out.close

path = "./" + traceDirName
puts "creating directory " + path
Dir.mkdir(path) unless path == '' || File.exist?(path)
