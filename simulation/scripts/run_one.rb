#!/usr/bin/ruby

# flows synchSize bufSize runTimeInSec
if ARGV.size < 5
    puts "This is a Ruby script to generate ns tcl files to simulate incast"
    puts "Usage: ./run_one.rb numFlows bufSize runTimeInSec synchSize runType minRto"
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

if ARGV.size == 6
    minRtoVal = ARGV[5]
    puts "min_rto = #{minRtoVal}"
else
    # 200u (for rto runs only)
    minRtoVal = 0.0002
    puts "default! min_rto = #{minRtoVal}"
end

puts "Generating ns file ..."
system("./gen_ns_file.rb #{flows} #{synchSize} #{bufSizeInPackets} #{runTimeInSec} #{runType} #{minRtoVal}")

puts "Running ns file ..."
system("ns ../tcl_gen/#{runType}_incast_flows_#{flows}_synchSizeInK_#{synchSizeInK}_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s.tcl")

BASEDIR = ".."
puts BASEDIR
DATA_DUMP_DIR = "#{BASEDIR}/data_dump"
GRAPHDIR = "#{BASEDIR}/graphs"
PREFIXDIR = "#{DATA_DUMP_DIR}/#{runType}_flow_#{flows}_s_#{synchSizeInK}K_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s"
puts PREFIXDIR
TEMPDIR = "#{PREFIXDIR}/temp"

#Dir.mkdir(TEMPDIR) unless TEMPDIR == '' || File.exist?(TEMPDIR)
system("mkdir -p #{TEMPDIR}");
system("rm #{TEMPDIR}/*")

# TIMEOUTS
# FORMAT :: flow#, synchSize, #touts
puts "Processing TIMEOUTS ..."
out = File.new("#{TEMPDIR}/tout.dat", "w")
for i in 1..flows.to_i
    puts "----- flow #{i} -----"

    num = `cat #{PREFIXDIR}/tcp#{i}.tr | grep "nrexmit_" | tail -n1 | #{BASEDIR}/column.pl -t " " 6`
    out.puts "#{i} #{synchSize} #{num}"
end

out.close
puts "=====> cat #{TEMPDIR}/tout.dat =====> Per flow #timeouts"
system("cat #{TEMPDIR}/tout.dat")

puts "Processing Individual Timeouts ..."
for i in 1..flows.to_i
    puts "----- flow #{i} -----"
    system(`cat #{PREFIXDIR}/tcp#{i}.tr | grep "nrexmit_" | #{BASEDIR}/column.pl -t " " 0 > #{TEMPDIR}/timeout#{i}.dat`)
end

# FORMAT :: bufSize, numFlows, synchSize, average#touts
out = File.new("#{TEMPDIR}/tout_avg.dat", "w")
num_avg = `cat #{TEMPDIR}/tout.dat | grep " #{synchSize} " | #{BASEDIR}/column.pl -t " " 2 | stats mean`
out.puts "#{bufSizeInPackets} #{flows} #{synchSize} #{num_avg}"

out.close
puts "=====> cat #{TEMPDIR}/tout_avg.dat =====> Average #timeouts"
system("cat #{TEMPDIR}/tout_avg.dat")

# RETRANSMITS
# FORMAT :: flow#, synchSize, #rexmits
puts "Processing RETRANSMITS ..."
out = File.new("#{TEMPDIR}/rexmit.dat", "w")
for i in 1..flows.to_i
    puts "----- flow #{i} -----"

    num = `cat #{PREFIXDIR}/tcp#{i}.tr | grep "nrexmitpack_" | tail -n1 | #{BASEDIR}/column.pl -t " " 6`
    out.puts "#{i} #{synchSize} #{num}"
end

out.close
puts "=====> cat #{TEMPDIR}/rexmit.dat =====> Per flow #retransmits"
system("cat #{TEMPDIR}/rexmit.dat")

# FORMAT :: bufSize, numFlows, synchSize, average#rexmits
out = File.new("#{TEMPDIR}/rexmit_avg.dat", "w")
num_avg = `cat #{TEMPDIR}/rexmit.dat | grep " #{synchSize} " | #{BASEDIR}/column.pl -t " " 2 | stats mean`
out.puts "#{bufSizeInPackets} #{flows} #{synchSize} #{num_avg}"

out.close
puts "=====> cat #{TEMPDIR}/rexmit_avg.dat =====> Average #retransmits"
system("cat #{TEMPDIR}/rexmit_avg.dat")

# GOODPUT
# FORMAT :: synchSize, average_goodput
puts "Processing GOODPUT ..."
out = File.new("#{TEMPDIR}/gput_cum_avg.dat", "w")
gput_avg = `tail -n1 #{PREFIXDIR}/tput_cum_tot_avg.tr | #{BASEDIR}/column.pl -t " " 1`
out.puts "#{synchSize} #{gput_avg}"

out.close
puts "=====> cat #{TEMPDIR}/gput_cum_avg.dat =====> Average Goodput"
system("cat #{TEMPDIR}/gput_cum_avg.dat")

=begin
## CWND
for i in 1..flows.to_i
    system("cat #{PREFIXDIR}/tcp#{i}.tr | grep \"cwnd_\" | #{BASEDIR}/column.pl -t \" \" 0 6 > #{PREFIXDIR}/cwnd_flow#{i}.dat")
end
=end

#####

=begin
fid = (flows.to_i * 2) + 1
system(`cat #{PREFIXDIR}/out.tra | grep "^r" | grep "\\-\\-\\- #{fid} " | grep " 1 2 ack" | #{BASEDIR}/column.pl -t " " 1 10 > #{TEMPDIR}/acks1.dat`)
system(`cat #{TEMPDIR}/acks1.dat | awk '{time = $1; if((time > 1.0) && (time < 1.3)) {printf("%f %d\\n", $1, $2%100);}}' > #{TEMPDIR}/acks1_mag.dat`)
system(`cat #{PREFIXDIR}/out.tra | grep "^+" | grep "\\-\\-\\- #{fid} " | grep " 2 1 tcp" | #{BASEDIR}/column.pl -t " " 1 10 > #{TEMPDIR}/data1.dat`)
system(`cat #{TEMPDIR}/data1.dat | awk '{time = $1; if((time > 1.0) && (time < 1.3)) {printf("%f %d\\n", $1, $2%100);}}' > #{TEMPDIR}/data1_mag.dat`)
=end
system(`cat #{PREFIXDIR}/out.tra | grep "^r" | grep "\\-\\-\\- 1 " | grep " 1 2 tcp 1040" | #{BASEDIR}/column.pl -t " " 1 10 > #{TEMPDIR}/synch1.dat`)
#system(`cat #{TEMPDIR}/synch1.dat | awk '{time = $1; if((time > 1.0) && (time < 1.3)) {printf("%f %d\\n", $1, $2);}}' > #{TEMPDIR}/synch1_mag.dat`)

=begin
fid = (flows.to_i * 2) + 3
system(`cat #{PREFIXDIR}/out.tra | grep "^r" | grep "\\-\\-\\- #{fid} " | grep " 1 3 ack" | #{BASEDIR}/column.pl -t " " 1 10 > #{TEMPDIR}/acks2.dat`)
system(`cat #{TEMPDIR}/acks2.dat | awk '{time = $1; if((time > 1.0) && (time < 1.3)) {printf("%f %d\\n", $1, $2%100);}}' > #{TEMPDIR}/acks2_mag.dat`)
system(`cat #{PREFIXDIR}/out.tra | grep "^+" | grep "\\-\\-\\- #{fid} " | grep " 3 1 tcp" | #{BASEDIR}/column.pl -t " " 1 10 > #{TEMPDIR}/data2.dat`)
system(`cat #{TEMPDIR}/data2.dat | awk '{time = $1; if((time > 1.0) && (time < 1.3)) {printf("%f %d\\n", $1, $2%100);}}' > #{TEMPDIR}/data2_mag.dat`)
system(`cat #{PREFIXDIR}/out.tra | grep "^r" | grep "\\-\\-\\- 3 " | grep " 1 3 tcp 1040" | #{BASEDIR}/column.pl -t " " 1 10 > #{TEMPDIR}/synch2.dat`)
system(`cat #{TEMPDIR}/synch2.dat | awk '{time = $1; if((time > 1.0) && (time < 1.3)) {printf("%f %d\\n", $1, $2);}}' > #{TEMPDIR}/synch2_mag.dat`)
=end

puts "graphing ..."
out = File.new("#{TEMPDIR}/graphs.gp", "w")

=begin

## SEQUENCE NUMBER PLOT - ACK, SYNCH
# out.puts "set terminal postscript eps monochrome;"
# out.puts "set size 0.65"
# out.puts "set output '#{GRAPHDIR}/_graph_acks_flow1_flows_#{flows}_synch_#{synchSize}_buf_#{bufSizeInPackets}_time_#{runTimeInSec}.eps';"
# out.puts "set title \"Sequence Number Plot for Server 1\";"
# out.puts "set xlabel \"time (seconds)\"; set ylabel \"sequence #\";"
# out.puts "plot '#{TEMPDIR}/acks1.dat' using 1:2 with points pt 2 pointsize 0.4 title 'flow1 acks', '#{TEMPDIR}/synch1.dat' using 1:2 with points pt 2 pointsize 0.5 title 'synch packets';"
# out.puts ""

# MAGNIFIED SECTIONS - DATA, ACK, SYNCH
out.puts "set terminal postscript eps monochrome;"
out.puts "set size 0.65"
out.puts "set output '#{GRAPHDIR}/_graph_data_flow1_magnified_flows_#{flows}_synch_#{synchSize}_buf_#{bufSizeInPackets}_time_#{runTimeInSec}.eps';"
out.puts "set title \"Sequence Number Plot for Server 1\";"
out.puts "set xlabel \"time (seconds)\"; set ylabel \"sequence #\";"
out.puts "set xtics rotate by 90;"
out.puts "plot '#{TEMPDIR}/acks1_mag.dat' using 1:2 with points pt 2 pointsize 0.4 title 'flow1 acks', '#{TEMPDIR}/data1_mag.dat' using 1:2 with points pt 1 pointsize 0.4 title 'flow1 data', '#{TEMPDIR}/synch1_mag.dat' using 1:2 with points pt 2 title 'synch1 packets';"
out.puts ""

out.puts "set terminal postscript eps monochrome;"
out.puts "set size 0.65"
out.puts "set output '#{GRAPHDIR}/_graph_data_flow2_magnified_flows_#{flows}_synch_#{synchSize}_buf_#{bufSizeInPackets}_time_#{runTimeInSec}.eps';"
out.puts "set title \"Sequence Number Plot for Server 1\";"
out.puts "set xlabel \"time (seconds)\"; set ylabel \"sequence #\";"
out.puts "set xtics rotate by 90;"
out.puts "plot '#{TEMPDIR}/acks2_mag.dat' using 1:2 with points pt 2 pointsize 0.4 title 'flow2 acks', '#{TEMPDIR}/data2_mag.dat' using 1:2 with points pt 1 pointsize 0.4 title 'flow2 data', '#{TEMPDIR}/synch2_mag.dat' using 1:2 with points pt 2 title 'synch2 packets';"
out.puts ""

=end

# GOODPUT GRAPH - Cumulative and moving averages.
# system("cp #{PREFIXDIR}/tput_cum_tot_avg.tr #{TEMPDIR}/tput_cum_tot_avg.dat")

# GOODPUT GRAPH - Instantaneous Aggregate Goodput.
# system("cp #{PREFIXDIR}/tput_instantaneous.tr #{TEMPDIR}/tput_instantaneous.dat")
# xgraph #{TEMPDIR}/tput_cum_tot_avg.dat -geometry 800x400 &

## system(`cat #{PREFIXDIR}/tput_moving.tr | #{BASEDIR}/column.pl -t " " 0 1 > #{TEMPDIR}/tput1.dat`)
## xgraph #{TEMPDIR}/tput1.dat -geometry 800x400 &

out.puts "set terminal postscript eps monochrome;"
out.puts "set size 0.65"
out.puts "set output '#{GRAPHDIR}/_graph_gput_#{runType}_flows_#{flows}_synch_#{synchSize}_buf_#{bufSizeInPackets}_time_#{runTimeInSec}.eps';"
out.puts "set title \"Goodput, Timeout and Synchronization Events\";"
out.puts "set xlabel \"time (seconds)\"; set ylabel \"Mbps\";"
out.puts "unset key;"
##out.puts "plot '#{TEMPDIR}/tput_cum_tot_avg.dat' using 1:2 with lines lt 1 title 'cumulative', '#{TEMPDIR}/tput1.dat' using 1:2 with lines lt 2 title 's1';"
flow_total_index = flows.to_i + 2
#out.puts "plot '#{TEMPDIR}/tput_cum_tot_avg.dat' using 1:2 with lines lt 1 title 'cumulative', '#{TEMPDIR}/tput_instantaneous.dat' using 1:#{flow_total_index} with lines lt 2 title 'inst. aggregate';"
y = 1000/(flows.to_i * 2)
str = "plot '#{PREFIXDIR}/tput_cum_tot_avg.tr' using 1:2 with lines lt 1 title 'cumulative', '#{PREFIXDIR}/tput_instantaneous.tr' using 1:#{flow_total_index} with lines lt 2 title 'inst. aggregate'"
for i in 1..flows.to_i
    if File.exist?("#{TEMPDIR}/timeout#{i}.dat")
        newy = y * ((2*i) - 1)
        str += ", '#{TEMPDIR}/timeout#{i}.dat' using 1:(#{newy}) with points pt 2 pointsize 0.4"
    end
end
str += ", '#{TEMPDIR}/synch1.dat' using 1:(0) with points pt 4 pointsize 0.5;"

out.puts "\
#{str}"
out.puts ""

out.close
##system("cat #{TEMPDIR}/graphs.gp | gnuplot -")

#system("rm #{TEMPDIR}/ack.gp #{TEMPDIR}/acks*.dat #{TEMPDIR}/data*.dat #{TEMPDIR}/synch*.dat #{TEMPDIR}/tput*.dat #{TEMPDIR}/*")
#system("rm #{TEMPDIR}/*")

puts "compressing and freeing space ..."
#system("tar -cjvf #{PREFIXDIR}/sim.tar.bz2 #{PREFIXDIR}/*")
#system("rm #{PREFIXDIR}/*.tr #{PREFIXDIR}/*.tra #{PREFIXDIR}/*.nam #{PREFIXDIR}/*.dat")

system("./tout_analysis.rb #{flows} #{bufSizeInPackets} #{runTimeInSec} #{synchSize} #{runType}")

system("rm #{PREFIXDIR}/*.nam")
#system("rm #{PREFIXDIR}/*.tra #{PREFIXDIR}/*.nam #{PREFIXDIR}/*.dat")
#system("rm #{PREFIXDIR}/tcp*.tr")

puts "##################################################"
