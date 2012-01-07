#!/usr/bin/ruby

runType = "reno"

if ARGV.size < 1
    puts "Usage: ./gen_tput_vs_servers_vs_buf.rb runType"
    exit
end

runType = ARGV[0]

BASEDIR = ".."
puts BASEDIR
DATA_DUMP_DIR = "#{BASEDIR}/data_dump/buf"
GRAPHDIR = "#{BASEDIR}/graphs"

synchSizeInK = 256
bufSizeInPackets = 64
runTimeInSec = 20
for gtype in ["monochrome", "color"]

    
    out = File.new("../temp/gput_vs_servers.gp", "w") 
    
    out.puts "set terminal postscript eps #{gtype};"
    out.puts "set size 0.65;"
    out.puts "set output '#{GRAPHDIR}/_graph2_goodput_degradation_#{runType}_variable_buf_synch_#{synchSizeInK}K_#{gtype}.eps';"
    out.puts "set title \"Average Goodput VS \# Servers \\n (SRU = #{synchSizeInK}KB)\";"
    out.puts "set xlabel \"Number of Servers\"; set ylabel \"Goodput (Mbps)\";"
    #out.puts "set xtic rotate by 90;"
    out.puts "set logscale x 2;"
    out.puts "set logscale y;"
    out.puts "set yrange [1:1000]"
    out.puts "set key left bottom"
    
    str = "plot "
    for bufSizeInPackets in [32, 64, 128, 256, 512, 1024]
        out2 = File.new("../temp/gput_cum_avg_graph2_#{bufSizeInPackets}.dat", "w")
        out2.puts "1 944"
        out2.puts "2 971"
        for flowId in [4, 8, 16, 32, 64, 128]
            puts "----- flow #{flowId} -----"
            prefixDir = "#{DATA_DUMP_DIR}/#{runType}_flow_#{flowId}_s_#{synchSizeInK}K_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s"
            puts prefixDir
            tempDir = "#{prefixDir}/temp"
            gput = `cat #{tempDir}/gput_cum_avg.dat | #{BASEDIR}/column.pl -t " " 1`
            out2.puts "#{flowId} #{gput}"
        end
        out2.close
        #str += " '../temp/gput_cum_avg_graph2_#{bufSizeInPackets}.dat' using 1:2 with linespoint title '#{bufSizeInPackets} packet buffer'"
        str += " '../temp/gput_cum_avg_graph2_#{bufSizeInPackets}.dat' using 1:2 with linespoint title '#{bufSizeInPackets}KB buf'"
        
        if bufSizeInPackets != 1024
            str += ","
        end
        
    end
    
    str += ";"
    out.puts "#{str}"
    
    out.close
    system("cat ../temp/gput_vs_servers.gp | gnuplot -")
    
    system("rm ../temp/gput_vs_servers.gp")
    system("rm ../temp/gput_cum_avg_graph2_#{bufSizeInPackets}.dat")
    
end
