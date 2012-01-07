
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

set xnam 0

set tracedir newreno_flow_4_s_1024K_buf_64_time_20s
set synchSize 1024000
set bufSize 64
set runTimeInSec 20.0

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

set avg1 0
set bw_interval_1 0.0
set avg2 0
set bw_interval_2 0.0
set avg3 0
set bw_interval_3 0.0
set avg4 0
set bw_interval_4 0.0

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
set server_node_1 [$ns node]
set server_node_2 [$ns node]
set server_node_3 [$ns node]
set server_node_4 [$ns node]

$ns duplex-link $client_node $router 1000Mb 25us DropTail
$ns queue-limit $client_node $router 1000
$ns queue-limit $router $client_node $bufSize

$ns duplex-link $router $server_node_1 1000Mb 25us DropTail
# $ns queue-limit $router $server_node_1 4
# $ns queue-limit $server_node_1 $router 8

$ns duplex-link $router $server_node_2 1000Mb 25us DropTail
# $ns queue-limit $router $server_node_2 4
# $ns queue-limit $server_node_2 $router 8

$ns duplex-link $router $server_node_3 1000Mb 25us DropTail
# $ns queue-limit $router $server_node_3 4
# $ns queue-limit $server_node_3 $router 8

$ns duplex-link $router $server_node_4 1000Mb 25us DropTail
# $ns queue-limit $router $server_node_4 4
# $ns queue-limit $server_node_4 $router 8

$ns duplex-link-op $client_node $router orient right
$ns duplex-link-op $client_node $router queuePos 0.5
$ns duplex-link-op $router $server_node_1 orient right-up
$ns duplex-link-op $router $server_node_1 queuePos 0.5
$ns duplex-link-op $router $server_node_2 orient right-up
$ns duplex-link-op $router $server_node_2 queuePos 0.5
$ns duplex-link-op $router $server_node_3 orient right-up
$ns duplex-link-op $router $server_node_3 queuePos 0.5
$ns duplex-link-op $router $server_node_4 orient right-up
$ns duplex-link-op $router $server_node_4 queuePos 0.5

# dummy
set tcpc0 [new Agent/TCP/FullTcp]
$ns attach-agent $client_node $tcpc0

# client_node
set tcpc1 [new Agent/TCP/Newreno]
$tcpc1 set max_ssthresh_ 0
$tcpc1 set fid_ 1
$ns attach-agent $client_node $tcpc1

set tcpc1_sink [new Agent/TCPSink]
$tcpc1_sink set fid_ 2
$ns attach-agent $client_node $tcpc1_sink

set tcpc2 [new Agent/TCP/Newreno]
$tcpc2 set max_ssthresh_ 0
$tcpc2 set fid_ 3
$ns attach-agent $client_node $tcpc2

set tcpc2_sink [new Agent/TCPSink]
$tcpc2_sink set fid_ 4
$ns attach-agent $client_node $tcpc2_sink

set tcpc3 [new Agent/TCP/Newreno]
$tcpc3 set max_ssthresh_ 0
$tcpc3 set fid_ 5
$ns attach-agent $client_node $tcpc3

set tcpc3_sink [new Agent/TCPSink]
$tcpc3_sink set fid_ 6
$ns attach-agent $client_node $tcpc3_sink

set tcpc4 [new Agent/TCP/Newreno]
$tcpc4 set max_ssthresh_ 0
$tcpc4 set fid_ 7
$ns attach-agent $client_node $tcpc4

set tcpc4_sink [new Agent/TCPSink]
$tcpc4_sink set fid_ 8
$ns attach-agent $client_node $tcpc4_sink

# server_node_1
set tcp1 [new Agent/TCP/Newreno]
$tcp1 attach [open ./$tracedir/tcp1.tr w]
$tcp1 set bugFix_ false
$tcp1 trace cwnd_
$tcp1 trace ack_
$tcp1 trace ssthresh_
$tcp1 trace nrexmit_
$tcp1 trace nrexmitpack_
$tcp1 trace nrexmitbytes_
$tcp1 trace ncwndcuts_
$tcp1 trace ncwndcuts1_
$tcp1 trace dupacks_
# $tcp1 trace curseq_
# $tcp1 trace maxseq_
$tcp1 set fid_ 9
$ns attach-agent $server_node_1 $tcp1

set tcp1_server_sink [new Agent/TCPSink]
$tcp1_server_sink set fid_ 10
$ns attach-agent $server_node_1 $tcp1_server_sink

# server_node_2
set tcp2 [new Agent/TCP/Newreno]
$tcp2 attach [open ./$tracedir/tcp2.tr w]
$tcp2 set bugFix_ false
$tcp2 trace cwnd_
$tcp2 trace ack_
$tcp2 trace ssthresh_
$tcp2 trace nrexmit_
$tcp2 trace nrexmitpack_
$tcp2 trace nrexmitbytes_
$tcp2 trace ncwndcuts_
$tcp2 trace ncwndcuts1_
$tcp2 trace dupacks_
# $tcp2 trace curseq_
# $tcp2 trace maxseq_
$tcp2 set fid_ 11
$ns attach-agent $server_node_2 $tcp2

set tcp2_server_sink [new Agent/TCPSink]
$tcp2_server_sink set fid_ 12
$ns attach-agent $server_node_2 $tcp2_server_sink

# server_node_3
set tcp3 [new Agent/TCP/Newreno]
$tcp3 attach [open ./$tracedir/tcp3.tr w]
$tcp3 set bugFix_ false
$tcp3 trace cwnd_
$tcp3 trace ack_
$tcp3 trace ssthresh_
$tcp3 trace nrexmit_
$tcp3 trace nrexmitpack_
$tcp3 trace nrexmitbytes_
$tcp3 trace ncwndcuts_
$tcp3 trace ncwndcuts1_
$tcp3 trace dupacks_
# $tcp3 trace curseq_
# $tcp3 trace maxseq_
$tcp3 set fid_ 13
$ns attach-agent $server_node_3 $tcp3

set tcp3_server_sink [new Agent/TCPSink]
$tcp3_server_sink set fid_ 14
$ns attach-agent $server_node_3 $tcp3_server_sink

# server_node_4
set tcp4 [new Agent/TCP/Newreno]
$tcp4 attach [open ./$tracedir/tcp4.tr w]
$tcp4 set bugFix_ false
$tcp4 trace cwnd_
$tcp4 trace ack_
$tcp4 trace ssthresh_
$tcp4 trace nrexmit_
$tcp4 trace nrexmitpack_
$tcp4 trace nrexmitbytes_
$tcp4 trace ncwndcuts_
$tcp4 trace ncwndcuts1_
$tcp4 trace dupacks_
# $tcp4 trace curseq_
# $tcp4 trace maxseq_
$tcp4 set fid_ 15
$ns attach-agent $server_node_4 $tcp4

set tcp4_server_sink [new Agent/TCPSink]
$tcp4_server_sink set fid_ 16
$ns attach-agent $server_node_4 $tcp4_server_sink

# connect the seding agents to sinks
$ns connect $tcpc1 $tcp1_server_sink 
$ns connect $tcp1 $tcpc1_sink
$ns connect $tcpc2 $tcp2_server_sink 
$ns connect $tcp2 $tcpc2_sink
$ns connect $tcpc3 $tcp3_server_sink 
$ns connect $tcp3 $tcpc3_sink
$ns connect $tcpc4 $tcp4_server_sink 
$ns connect $tcp4 $tcpc4_sink

$tcpc1_sink listen
$tcp1_server_sink listen
$tcpc2_sink listen
$tcp2_server_sink listen
$tcpc3_sink listen
$tcp3_server_sink listen
$tcpc4_sink listen
$tcp4_server_sink listen

set capp [new Application/IncastTcpAppClient $tcpc0 $synchSize]

set sapp1 [new Application/IncastTcpAppServer $tcp1 $synchSize]
set sapp2 [new Application/IncastTcpAppServer $tcp2 $synchSize]
set sapp3 [new Application/IncastTcpAppServer $tcp3 $synchSize]
set sapp4 [new Application/IncastTcpAppServer $tcp4 $synchSize]

$capp connect $sapp1 $tcpc1 $tcpc1_sink
$capp connect $sapp2 $tcpc2 $tcpc2_sink
$capp connect $sapp3 $tcpc3 $tcpc3_sink
$capp connect $sapp4 $tcpc4 $tcpc4_sink

$tcp1_server_sink setparent $sapp1
$tcp2_server_sink setparent $sapp2
$tcp3_server_sink setparent $sapp3
$tcp4_server_sink setparent $sapp4

$ns at 0.1 "$capp start"
$ns at 0.1 "record"
$ns at $runTimeInSec "finish"

# Define a procedure which periodically records the bandwidth received by the
# three traffic sinks sink0/1/2 and writes it to the file f0.
proc record {} {
    global ns f0 f1 favg_ind favg_tot i  tcpc1_sink avg1 bw_interval_1 tcpc2_sink avg2 bw_interval_2 tcpc3_sink avg3 bw_interval_3 tcpc4_sink avg4 bw_interval_4

    # Set the time after which the procedure should be called again
    set time 0.01

    set i [expr $i + $time]

    #Get the current time
    set now [$ns now]

    # Record how many bytes have been received by the traffic sinks.
    set bw1 [$tcpc1_sink set bytes_]
    set bw_interval_1 [expr $bw_interval_1 + $bw1]
    set bw2 [$tcpc2_sink set bytes_]
    set bw_interval_2 [expr $bw_interval_2 + $bw2]
    set bw3 [$tcpc3_sink set bytes_]
    set bw_interval_3 [expr $bw_interval_3 + $bw3]
    set bw4 [$tcpc4_sink set bytes_]
    set bw_interval_4 [expr $bw_interval_4 + $bw4]

    if {$i >= 1.0} {
        puts $f0 "$now [expr $bw_interval_1/$i*8/1000000] [expr $bw_interval_2/$i*8/1000000] [expr $bw_interval_3/$i*8/1000000] [expr $bw_interval_4/$i*8/1000000] [expr ( $bw_interval_1 + $bw_interval_2 + $bw_interval_3 + $bw_interval_4)/$i * 8/1000000]"
        set bw_interval_1 0
        set bw_interval_2 0
        set bw_interval_3 0
        set bw_interval_4 0
        set i 0.0
    }

    # Calculate the bandwidth (in MBit/s) and write it to the files
    # puts $f0 "$now [expr $bw0/$time*8/1000000] [expr $bw1/$time*8/1000000] [expr ($bw0+$bw1)/$time*8/1000000]"
    puts $f1 "$now [expr $bw1/$time*8/1000000] [expr $bw2/$time*8/1000000] [expr $bw3/$time*8/1000000] [expr $bw4/$time*8/1000000] [expr { wide($bw1+$bw2+$bw3+$bw4)/$time*8/1000000 }]"
    set avg1 [expr { wide($avg1) + $bw1 }]
    set avg2 [expr { wide($avg2) + $bw2 }]
    set avg3 [expr { wide($avg3) + $bw3 }]
    set avg4 [expr { wide($avg4) + $bw4 }]

    puts $favg_ind "$now [expr $avg1/($now-.09999999)*8/1000000] [expr $avg2/($now-.09999999)*8/1000000] [expr $avg3/($now-.09999999)*8/1000000] [expr $avg4/($now-.09999999)*8/1000000]"
    puts $favg_tot "$now [expr { wide($avg1+$avg2+$avg3+$avg4)/($now-.09999999)*8/1000000 }]"

    # Reset the bytes_ values on the traffic sinks
    $tcpc1_sink set bytes_ 0
    $tcpc2_sink set bytes_ 0
    $tcpc3_sink set bytes_ 0
    $tcpc4_sink set bytes_ 0

    # Re-schedule the procedure
    $ns at [expr $now+$time] "record"
}
$ns run
