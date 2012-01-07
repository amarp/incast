#!/usr/bin/ruby

if ARGV.size < 5
    puts "Usage: ./bin.rb numFlows bufSize runTimeInSec synchSize runType"
    exit
end

flows = ARGV[0]
bufSizeInPackets = ARGV[1]
runTimeInSec = ARGV[2]
synchSize = ARGV[3].to_i
synchSizeInK = synchSize/1000
runType = ARGV[4]
fileName = "dupacksAtTimeout.dat"

BASEDIR = ".."
puts BASEDIR
DATA_DUMP_DIR = "#{BASEDIR}/data_dump"
GRAPHDIR = "#{BASEDIR}/graphs"
PREFIXDIR = "#{DATA_DUMP_DIR}/#{runType}_flow_#{flows}_s_#{synchSizeInK}K_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s"
puts PREFIXDIR
TEMPDIR = "#{PREFIXDIR}/temp"

#puts fileName

system("java Binner #{TEMPDIR}/#{fileName} > #{TEMPDIR}/temp.dat")

puts "graphing ..."
out = File.new("#{TEMPDIR}/graphs.gp", "w")

out.puts "set terminal postscript eps monochrome;"
out.puts "set size 0.65"
out.puts "set output '#{TEMPDIR}/#{fileName}_binned.eps';"
out.puts "set title \"Duplicate ACK Distribution under Reno\";"
out.puts "set xlabel \"# of Duplicate ACKs\"; set ylabel \"# of Occurrences\";"
out.puts "set xrange [-.5: ]"
out.puts "unset key"
out.puts "set boxwidth 1"
out.puts "plot '#{TEMPDIR}/temp.dat' using 1:2 with boxes fill pattern 1"

out.puts ""

out.close

system("cat #{TEMPDIR}/graphs.gp | gnuplot -")
system("rm #{TEMPDIR}/temp.dat")
system("rm #{TEMPDIR}/graphs.gp")
