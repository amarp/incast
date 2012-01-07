#!/usr/bin/ruby

BASEDIR = ".."
puts BASEDIR
DATA_DUMP_DIR = "#{BASEDIR}/data_dump"
GRAPHDIR = "#{BASEDIR}/graphs"

synchSizeInK = 1000
bufSizeInPackets = 64
runTimeInSec = 50

for gtype in ["monochrome", "color"]

    out = File.new("../temp/tput_vs_synchSize.gp", "w") 
    
    out.puts "set terminal postscript eps #{gtype};"
    out.puts "set size 0.65;"
    out.puts "set output '#{GRAPHDIR}/_graph2_goodput_new_reno_variants_#{synchSizeInK}K_#{gtype}.eps';"
    out.puts "set title \"DupAck=1 and Limited Transmit Comparison \\n (SRU = #{synchSizeInK}KB, buf = #{bufSizeInPackets})\";"
    out.puts "set xlabel \"Number of Servers\"; set ylabel \"Goodput (Mbps)\";"
    out.puts "set logscale x 2;"
    out.puts "set logscale y;"
    out.puts "set yrange [1:1000]"
    out.puts "set key left bottom;"
    
    str = "plot "
    for runType in ["newreno", "newreno_lt", "newreno_dup1", "newreno_noss"]
        
        out2 = File.new("../temp/gput_cum_avg_graph3_#{runType}_synch_#{synchSizeInK}.dat", "w")
        for flowId in [4, 8, 16, 32, 64, 128]
            puts "----- flow #{flowId} -----"
            prefixDir = "#{DATA_DUMP_DIR}/#{runType}_flow_#{flowId}_s_#{synchSizeInK}K_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s"
            puts prefixDir
            tempDir = "#{prefixDir}/temp"
            gput = `cat #{tempDir}/gput_cum_avg.dat | #{BASEDIR}/column.pl -t " " 1`
            out2.puts "#{flowId} #{gput}"
        end
        out2.close
        str += " '../temp/gput_cum_avg_graph3_#{runType}_synch_#{synchSizeInK}.dat' using 1:2 with linespoint title '#{runType}'"
        
        if runType != "newreno_noss"
            str += ","
        end
    end
    
    str += ";"
    out.puts "#{str}"
    
    out.close
    system("cat ../temp/tput_vs_synchSize.gp | gnuplot -")
    
    system("rm ../temp/tput_vs_synchSize.gp")
    system("rm ../temp/gput_cum_avg_graph2_*.dat")
    
end
