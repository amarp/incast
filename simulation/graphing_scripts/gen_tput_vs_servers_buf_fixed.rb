#!/usr/bin/ruby

runType = "newreno"
#runType = "reno"
#runType = "reno_rto"

if ARGV.size < 1
    puts "Usage: ./gen_tput_vs_servers_buf_fixed.rb runType"
    exit
end

runType = ARGV[0]

BASEDIR = ".."
puts BASEDIR
DATA_DUMP_DIR = "#{BASEDIR}/data_dump/tcp_256K"
#DATA_DUMP_DIR = "#{BASEDIR}/data_dump/tcp_newreno_256K"
GRAPHDIR = "#{BASEDIR}/graphs"

synchSizeInK = 256
#synchSizeInK = 8000
bufSizeInPackets = 64
runTimeInSec = 20
#runTimeInSec = 50


for gtype in ["monochrome", "color"]

    out = File.new("../temp/gput_vs_servers.gp", "w") 
    
    out.puts "set terminal postscript eps #{gtype};"
    out.puts "set size 0.65;"
    out.puts "set output '#{GRAPHDIR}/_graph2_goodput_degradation_#{runType}_buf_#{bufSizeInPackets}_synch_#{synchSizeInK}K_#{gtype}.eps';"
    out.puts "set title \"Average Goodput VS \# Servers \\n (SRU = #{synchSizeInK}KB)\";"
    out.puts "set xlabel \"Number of Servers\"; set ylabel \"Goodput (Mbps)\";"
    #out.puts "set xtic rotate by 90;"
    out.puts "set logscale x 2;"
    out.puts "set logscale y;"
    out.puts "set yrange [1:1000]"
    
    str = "plot "
    #for bufSizeInPackets in [32, 64]
    
    out2 = File.new("../temp/gput_cum_avg_graph2_#{bufSizeInPackets}.dat", "w")
    out2.puts "1 944"
    out2.puts "2 971"
    for flowId in [4, 8, 16, 32, 64, 128]
    #for flowId in 1..32
        puts "----- flow #{flowId} -----"
        prefixDir = "#{DATA_DUMP_DIR}/#{runType}_flow_#{flowId}_s_#{synchSizeInK}K_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s"
        puts prefixDir
        tempDir = "#{prefixDir}/temp"
        gput = `cat #{tempDir}/gput_cum_avg.dat | #{BASEDIR}/column.pl -t " " 1`
        out2.puts "#{flowId} #{gput}"
    end
    out2.close
    str += " '../temp/gput_cum_avg_graph2_#{bufSizeInPackets}.dat' using 1:2 with linespoint title 'with #{bufSizeInPackets}KB buffer'"
    
    #if bufSizeInPackets != 64
    #    str += ","
    #end
    
    #end
    
    str += ";"
    out.puts "#{str}"
    
    out.close
    system("cat ../temp/gput_vs_servers.gp | gnuplot -")
    
    system("rm ../temp/gput_vs_servers.gp")
    system("rm ../temp/gput_cum_avg_graph2_#{bufSizeInPackets}.dat")
    
end

# Number of timeouts!
for gtype in ["monochrome", "color"]

    out = File.new("../temp/tout_vs_servers.gp", "w") 
    
    out.puts "set terminal postscript eps #{gtype};"
    out.puts "set size 0.65;"
    out.puts "set output '#{GRAPHDIR}/_graph2_num_timeouts_#{runType}_buf_#{bufSizeInPackets}_synch_#{synchSizeInK}K_#{gtype}.eps';"
    out.puts "set title \"Average number of timeouts VS \# Servers \\n (SRU = #{synchSizeInK}K)\";"
    out.puts "set xlabel \"Number of Servers\"; set ylabel \"Average \# of timeouts per block\";"
    #out.puts "set xtic rotate by 90;"
    #out.puts "set logscale x 2;"
    
    str = "plot "
    #for bufSizeInPackets in [32, 64]
    
    out2 = File.new("../temp/avg_tout_graph2_#{bufSizeInPackets}.dat", "w")
    out2.puts "1 0"
    out2.puts "2 0"
    for flowId in [4, 8, 16, 32, 64, 128]
    #for flowId in 1..32
        puts "----- flow #{flowId} -----"
        prefixDir = "#{DATA_DUMP_DIR}/#{runType}_flow_#{flowId}_s_#{synchSizeInK}K_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s"
        puts prefixDir
        tempDir = "#{prefixDir}/temp"
        gput = `cat #{tempDir}/tout_avg.dat | #{BASEDIR}/column.pl -t " " 3`
        num_blocks = `cat #{tempDir}/synch1.dat | wc -l  | #{BASEDIR}/column.pl -t " " 0`
        out2.puts "#{flowId} #{gput.to_f} #{num_blocks.to_i} #{gput.to_f/num_blocks.to_f}"
    end
    out2.close
    str += " '../temp/avg_tout_graph2_#{bufSizeInPackets}.dat' using 1:4 with linespoint title 'with #{bufSizeInPackets} pkt buffer'"
    
    #if bufSizeInPackets != 64
    #    str += ","
    #end
    
    #end
    
    str += ";"
    out.puts "#{str}"
    
    out.close
    system("cat ../temp/tout_vs_servers.gp | gnuplot -")
    
    system("rm ../temp/tout_vs_servers.gp")
    system("rm ../temp/avg_tout_graph2_#{bufSizeInPackets}.dat")
    
end
