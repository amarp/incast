#!/usr/bin/ruby

runType = "newreno"
synchSizeInK = 256
bufSizeInPackets = 64
#runTimeInSec = 20
runTimeInSec = 5
flows = 10

if ARGV.size < 1
    puts "Usage: ./gen_tput_vs_servers_buf_fixed.rb runType"
    exit
end

runType = ARGV[0]

BASEDIR = ".."
puts BASEDIR
DATA_DUMP_DIR = "#{BASEDIR}/data_dump/"
#DATA_DUMP_DIR = "#{BASEDIR}/data_dump/tcp_newreno_256K"
PREFIXDIR = "#{DATA_DUMP_DIR}/#{runType}_flow_#{flows}_s_#{synchSizeInK}K_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s"
puts PREFIXDIR
TEMPDIR = "#{PREFIXDIR}/temp"
GRAPHDIR = "#{BASEDIR}/graphs"

out = File.new("../temp/spike.gp", "w") 

str = "plot "
out.puts "set terminal postscript eps monochrome;"
out.puts "set size 0.65"
out.puts "set output '#{GRAPHDIR}/_spike_#{runType}_flows_#{flows}_sru_#{synchSizeInK}K_buf_#{bufSizeInPackets}K_time_#{runTimeInSec}_Magnified.eps';"
#out.puts "set title \"Goodput, Timeout and Synchronization Events\";"
out.puts "set xlabel \"time (seconds)\"; set ylabel \"Goodput (Mbps)\";"
out.puts "set xrange [2:2.5]"
out.puts "set yrange [0:1000]"
out.puts "unset key;"
flow_total_index = flows.to_i + 2
y = 1000/(flows.to_i * 2)
#str = "plot '#{PREFIXDIR}/tput_cum_tot_avg.tr' using 1:2 with lines lt 1 title 'cumulative', '#{PREFIXDIR}/tput_instantaneous.tr' using 1:#{flow_total_index} with lines lt 2 title 'inst. aggregate'"
str = "plot '#{PREFIXDIR}/tput_instantaneous.tr' using 1:#{flow_total_index} with lines lt 1 title 'inst. aggregate'"
for i in 1..flows.to_i
    if File.exist?("#{TEMPDIR}/timeout#{i}.dat")
        #newy = y * ((2*i) - 1)
        newy = 0
        str += ", '#{TEMPDIR}/timeout#{i}.dat' using 1:(#{newy}) with points pt 2 pointsize 2.0"
    end
end
#str += ", '#{TEMPDIR}/synch1.dat' using 1:(0) with points pt 4 pointsize 1.0;"
str += ", '#{TEMPDIR}/synch1.dat' using 1:(1000) with impulses lw 3"

out.puts "\
#{str}"
out.puts ""

out.close
  
system("cat ../temp/spike.gp | gnuplot -")

system("rm ../temp/spike.gp")
