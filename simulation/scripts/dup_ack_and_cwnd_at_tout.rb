#!/usr/bin/ruby

if ARGV.size < 5
    puts "Usage: ./dup_ack_and_cwnd_at_tout.rb numFlows bufSize runTimeInSec synchSize runType"
    exit
end

flows = ARGV[0]
bufSizeInPackets = ARGV[1]
runTimeInSec = ARGV[2]
synchSize = ARGV[3].to_i
synchSizeInK = synchSize/1000
runType = ARGV[4]
fileName = "dupacksAndCwndAtTimeout"

BASEDIR = ".."
puts BASEDIR
DATA_DUMP_DIR = "#{BASEDIR}/data_dump"
GRAPHDIR = "#{BASEDIR}/graphs"
PREFIXDIR = "#{DATA_DUMP_DIR}/#{runType}_flow_#{flows}_s_#{synchSizeInK}K_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s"
puts PREFIXDIR
TEMPDIR = "#{PREFIXDIR}/temp"


puts "========================="
puts "./tout_analysis.rb #{flows} #{bufSizeInPackets} #{runTimeInSec} #{synchSize} #{runType}"
system("./tout_analysis.rb #{flows} #{bufSizeInPackets} #{runTimeInSec} #{synchSize} #{runType}")
puts "========================="

#puts fileName

puts "graphing ..."
out = File.new("#{TEMPDIR}/graphs1.gp", "w")

out.puts "set terminal postscript eps monochrome;"
out.puts "set size 0.65"
out.puts "set output '#{TEMPDIR}/#{fileName}.eps';"
out.puts "set title \"Duplicate ACK Distribution under Reno\";"
out.puts "set xlabel \"Time\"; set ylabel \"# of Occurrences\";"
out.puts "plot '#{TEMPDIR}/#{fileName}_1.dat' using 3:1 with lines title 'dupack#', '#{TEMPDIR}/#{fileName}_1.dat' using 3:2 with lines title 'cwnd';"
out.puts ""
out.close

system("cat #{TEMPDIR}/graphs1.gp | gnuplot -")
system("rm #{TEMPDIR}/graphs1.gp")
