#!/usr/bin/ruby

if ARGV.size < 5
    puts "Usage: ./dart.rb numFlows bufSize runTimeInSec synchSize runType"
    exit
end

flows = ARGV[0]
bufSizeInPackets = ARGV[1]
runTimeInSec = ARGV[2]
synchSize = ARGV[3].to_i
synchSizeInK = synchSize/1000
runType = ARGV[4]

BASEDIR = ".."
puts BASEDIR
DATA_DUMP_DIR = "#{BASEDIR}/data_dump/tcp_256K"
GRAPHDIR = "#{BASEDIR}/graphs"
PREFIXDIR = "#{DATA_DUMP_DIR}/#{runType}_flow_#{flows}_s_#{synchSizeInK}K_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s"
puts PREFIXDIR
TEMPDIR = "#{PREFIXDIR}/temp"


blocks = `cat #{TEMPDIR}/synch1.dat | awk {'print $2'} | ~/tools/UnixStat/bin/stats max`
puts blocks
all_timeouts = `cat #{TEMPDIR}/dupack_dist.dat | awk {'print $2'} | ~/tools/UnixStat/bin/stats sum`
puts all_timeouts

out = File.new("#{TEMPDIR}/graphs.gp", "w")

out.puts "set terminal postscript eps monochrome;"
out.puts "set size 0.65"
out.puts "set output '#{TEMPDIR}/dupack_binned.eps';"
#out.puts "set output '#{GRAPHDIR}/_graph_dupack_binned_#{runType}_flows_#{flows}_synch_#{synchSize}_buf_#{bufSizeInPackets}_time_#{runTimeInSec}.eps';"
out.puts "set title \"Duplicate ACK Distribution\\nTotal \# of timeouts = #{all_timeouts.chomp}. Blocks = #{blocks.chomp}\";"
out.puts "set xlabel \"# of Duplicate ACKs at Timeout\"; set ylabel \"# of Occurrences\";"
out.puts "set xrange [-.5: 20]"
out.puts "set yrange [0:500]"
out.puts "unset key"
out.puts "set boxwidth 1"
out.puts "plot '#{TEMPDIR}/dupack_dist.dat' using 1:2 with boxes fill solid 0.3;"
out.puts ""

out.close

system("cat #{TEMPDIR}/graphs.gp | gnuplot -")
#system("rm #{TEMPDIR}/dupack_dist.dat")
#system("rm #{TEMPDIR}/cwnd_dist.dat")
system("rm #{TEMPDIR}/graphs.gp")
