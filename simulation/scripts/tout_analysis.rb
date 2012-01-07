#!/usr/bin/ruby

# flows synchSize bufSize runTimeInSec
if ARGV.size < 5
    puts "This script parses trace file"
    puts "Usage: ./tout_analysis.rb numFlows bufSize runTimeInSec synchSize runType"
    exit
end

flows = ARGV[0]

# if flows.to_i < 2
#     puts "You should specify more than 1 flow!"
#     exit
# end

bufSizeInPackets = ARGV[1]
runTimeInSec = ARGV[2]
synchSize = ARGV[3].to_i
synchSizeInK = synchSize/1000

runType = ARGV[4]

BASEDIR = ".."
puts BASEDIR
DATA_DUMP_DIR = "#{BASEDIR}/data_dump"
GRAPHDIR = "#{BASEDIR}/graphs"
PREFIXDIR = "#{DATA_DUMP_DIR}/#{runType}_flow_#{flows}_s_#{synchSizeInK}K_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s"
puts PREFIXDIR
TEMPDIR = "#{PREFIXDIR}/temp"


out = File.new("#{TEMPDIR}/dupacksAtTimeout.dat", "w")
# Format of dupacksAtTimeout.dat => "dupacksAtTimeout cwndAtTimeout timeAtWhichTimeoutOccured flow# seq_#_of_timedout_pkt"

for i in 1..flows.to_i

    dupack1 = -1
    dupack2 = -1
    init = -1
    lastcwnd = -1


    t_dupack1 = -1
    t_dupack2 = -1

    # 0 to begin with, 1 if ncwndcuts_ encountered, 2 if ncwndcuts1_ encountered 
    # if in state1 when nrexmit_ is encountered, dupack count has to be 0 as the last time the cwnd was reset it was because of idle time 
    state = 0

    dupack_reset = 0

    last_ack = 0


    filename = "#{PREFIXDIR}/tcp#{i}.tr"
    #out1 = File.new("#{TEMPDIR}/dupacksAndCwndAtTimeout_#{i}.dat", "w")

    File.open(filename) do |file|
        while line = file.gets

            if line.include? " ack_"
                a, b, c, d, e, f, value = line.chomp.split(/\s+/)
                last_ack = value.to_i
            end

            if line.include? "ncwndcuts_"
                state = 1
            end

            if line.include? "ncwndcuts1_"
                state = 2
            end

            if line.include? "nrexmit_"
                time, b, c, d, e, f, g = line.chomp.split(/\s+/)
                #puts "haha : #{dupack1} #{dupack2}"
                if init != -1
                    if dupack1 != -1 && dupack2 == 0 && state == 2
                        # dupack1 is the value we want
                        # dupack2 should be 0 if numdupacks got 
                        # reset due to a timeout
                        
                        out.puts "#{dupack1} #{lastcwnd.to_i} #{time} #{i} #{last_ack.to_i + 1}"
                        #out1.puts "#{dupack1} #{lastcwnd.to_i} #{time} #{i} #{last_ack.to_i + 1}"
                    else  
                        out.puts "0 #{lastcwnd.to_i} #{time} #{i} #{last_ack.to_i + 1}"
                        #out1.puts "0 #{lastcwnd.to_i} #{time} #{i} #{last_ack.to_i + 1}"
                    end
                    
                    dupack1 = -1
                    dupack2 = -1
                else
                    init = 0
                end
            end

            if line.include? "cwnd_"
                a, b, c, d, e, f, value = line.chomp.split(/\s+/)
                lastcwnd = value.to_f
            end

            if line.include? "dupacks_"
                a, b, c, d, e, f, value = line.chomp.split(/\s+/)
                if b != "-1"

                    #puts line
                    #puts "#{a} #{b} #{c} #{d} #{e} #{f}"
                    #puts value

                    #if dupack1 == -1 && value != "0"
                    if dupack1 == -1
                        #puts "setting dupack1 to #{value}"
                        dupack1 = value.to_i
                        t_dupack1 = a.to_f
                    elsif dupack2 == -1
                        #puts "setting dupack2 to #{value}"
                        dupack2 = value.to_i
                        t_dupack2 = a.to_f
                    else
                        #puts "setting dupack2 to #{value}"
                        #puts "setting dupack1 to #{dupack2}"
                        dupack1 = dupack2
                        dupack2 = value.to_i

                        t_dupack1 = t_dupack2
                        t_dupack2 = a.to_f
                    end

                    if dupack2 == 0
                        # either we just got out of fastRecovery or there was a timeout!
                        # dupack2 would have been set to this value (not dupack1)
                        diff = t_dupack2 - t_dupack1

                        # WILL WORK ONLY FOR 200ms RTO VALUE
                        if diff < 0.1
                            # fastRecovery exited - dupack count not reset due to timeout
                            dupack1 = dupack2
                            t_dupack1 = t_dupack2
                        else
                            puts "timeout"
                        end
                    end

                end
            end
        end

        #out1.close
    end
    
end
out.close

=begin
puts "graphing ..."
out = File.new("#{TEMPDIR}/dupackGraph.gp", "w")

out.puts "set terminal postscript eps monochrome;"
out.puts "set size 0.65"
out.puts "set output '#{GRAPHDIR}/_graph_dupackHistogram_#{runType}_flows_#{flows}_synch_#{synchSize}_buf_#{bufSizeInPackets}_time_#{runTimeInSec}.eps';"
out.puts "set title \"Duplicate ACK Distribution at Timeout Occurrence\";"
out.puts "set xlabel \"# of Duplicate ACKs\"; set ylabel \"Count\";"
out.puts "unset key;"
out.puts "set boxwidth .5 relative;"

str = "plot '#{PREFIXDIR}/temp/dupacksAtTimeout.dat' using (int($1)):(1.0) smooth frequency with impulses;"

out.puts "\
#{str}"
out.puts ""

out.close

system("cat #{TEMPDIR}/dupackGraph.gp | gnuplot -")



puts "graphing ..."
out = File.new("#{TEMPDIR}/cwndGraph.gp", "w")

out.puts "set terminal postscript eps monochrome;"
out.puts "set size 0.65"
out.puts "set output '#{GRAPHDIR}/_graph_cwndHistogram_#{runType}_flows_#{flows}_synch_#{synchSize}_buf_#{bufSizeInPackets}_time_#{runTimeInSec}.eps';"
out.puts "set title \"CWND Distribution at Timeout Occurrence\";"
out.puts "set xlabel \"CWND\"; set ylabel \"Count\";"
out.puts "unset key;"
out.puts "set boxwidth .5 relative;"

str = "plot '#{PREFIXDIR}/temp/dupacksAtTimeout.dat' using (int($2)):(1.0) smooth frequency with impulses;"

out.puts "\
#{str}"
out.puts ""

out.close

system("cat #{TEMPDIR}/cwndGraph.gp | gnuplot -")
=end

##################################################

## BINNER

system("java Binner #{TEMPDIR}/dupacksAtTimeout.dat 0 > #{TEMPDIR}/dupack_dist.dat")
system("java Binner #{TEMPDIR}/dupacksAtTimeout.dat 1 > #{TEMPDIR}/cwnd_dist.dat")

puts "graphing ..."
out = File.new("#{TEMPDIR}/graphs.gp", "w")

out.puts "set terminal postscript eps monochrome;"
out.puts "set size 0.65"
out.puts "set output '#{TEMPDIR}/dupack_binned.eps';"
#out.puts "set output '#{GRAPHDIR}/_graph_dupack_binned_#{runType}_flows_#{flows}_synch_#{synchSize}_buf_#{bufSizeInPackets}_time_#{runTimeInSec}.eps';"
out.puts "set title \"Duplicate ACK Distribution\";"
out.puts "set xlabel \"# of Duplicate ACKs at Timeout\"; set ylabel \"# of Occurrences\";"
out.puts "set xrange [-.5: ]"
out.puts "unset key"
out.puts "set boxwidth 1"
out.puts "plot '#{TEMPDIR}/dupack_dist.dat' using 1:2 with boxes fill pattern 1;"
out.puts ""

out.puts "set terminal postscript eps monochrome;"
out.puts "set size 0.65"
out.puts "set output '#{TEMPDIR}/cwnd_binned.eps';"
#out.puts "set output '#{GRAPHDIR}/_graph_cwnd_binned_#{runType}_flows_#{flows}_synch_#{synchSize}_buf_#{bufSizeInPackets}_time_#{runTimeInSec}.eps';"
out.puts "set title \"Cwnd Distribution\";"
out.puts "set xlabel \"Cwnd value at Timeout\"; set ylabel \"# of Occurrences\";"
out.puts "set xrange [-.5: ]"
out.puts "unset key"
out.puts "set boxwidth 1"
out.puts "plot '#{TEMPDIR}/cwnd_dist.dat' using 1:2 with boxes fill pattern 1;"
out.puts ""

out.close

system("cat #{TEMPDIR}/graphs.gp | gnuplot -")
#system("rm #{TEMPDIR}/dupack_dist.dat")
#system("rm #{TEMPDIR}/cwnd_dist.dat")
system("rm #{TEMPDIR}/graphs.gp")

#system("rm #{TEMPDIR}/dupacksAndCwndAtTimeout*")


system("./detect_dropped_rexmit.rb #{PREFIXDIR} #{flows} >  #{TEMPDIR}/dropped_rextmits.dat")

if runType.include? "dup1"
    system("./detect_uncategorized_timeouts.rb #{PREFIXDIR} 0 >  #{TEMPDIR}/uncategorized_timeouts_in_dupack_tail.dat")
else
    system("./detect_uncategorized_timeouts.rb #{PREFIXDIR} 2 >  #{TEMPDIR}/uncategorized_timeouts_in_dupack_tail.dat")
end

system("./detect_last_packet_drop.rb #{PREFIXDIR} >  #{TEMPDIR}/dropped_last_packet.dat")
