#!/usr/bin/ruby

BASEDIR = ".."
puts BASEDIR
DATA_DUMP_DIR = "#{BASEDIR}/data_dump/tcp_256K"
GRAPHDIR = "#{BASEDIR}/graphs"

synchSizeInK = 256
bufSizeInPackets = 64
runTimeInSec = 20

for gtype in ["monochrome", "color"]

    out = File.new("../temp/tput_vs_synchSize.gp", "w") 
    
    out.puts "set terminal postscript eps #{gtype};"
    out.puts "set size 0.65;"
    out.puts "set output '#{GRAPHDIR}/_graph2_goodput_new_reno_variants_buf_#{bufSizeInPackets}_synch_#{synchSizeInK}K_#{gtype}.eps';"
    out.puts "set title \"Comparison \\n Limited Transmit, da_thresh=1, da_thresh=1 w/ no SlowStart \\n (SRU = #{synchSizeInK}KB, buf = #{bufSizeInPackets}KB)\";"
    out.puts "set xlabel \"Number of Servers\"; set ylabel \"Goodput (Mbps)\";"
    out.puts "set logscale x 2;"
    out.puts "set logscale y;"
    out.puts "set yrange [1:1000]"
    out.puts "set key bottom left;"
    
    str = "plot "
    for runType in ["newreno", "newreno_lt", "newreno_dup1", "newreno_dup1_noss"]
        runName = runType
        if runType == "newreno_dup1" then
            runName = "newreno, da_thresh = 1"
        elsif runType == "newreno_lt" then
            runName = "newreno, limited transmit"
        elsif runType == "newreno_dup1_noss" then
            runName = "newreno, da_thresh = 1, no slow start"
        end

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
        str += " '../temp/gput_cum_avg_graph3_#{runType}_synch_#{synchSizeInK}.dat' using 1:2 with linespoint title '#{runName}'"
        
        if runType != "newreno_dup1_noss"
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

# Number of timeouts!
for gtype in ["monochrome", "color"]

    out = File.new("../temp/tout_vs_servers.gp", "w") 
    
    out.puts "set terminal postscript eps #{gtype};"
    out.puts "set size 0.65;"
    out.puts "set output '#{GRAPHDIR}/_graph2_num_timeouts_new_reno_variants_buf_#{bufSizeInPackets}_synch_#{synchSizeInK}K_#{gtype}.eps';"
    out.puts "set title \"Average number of timeouts VS \# Servers \\n (SRU = #{synchSizeInK}K)\";"
    out.puts "set xlabel \"Number of Servers\"; set ylabel \"Average number of timeouts per synchronization block\";"
    #out.puts "set xtic rotate by 90;"
    out.puts "set logscale x 2;"
    out.puts "set key right bottom;"
    
    str = "plot "
    for runType in ["newreno", "newreno_lt", "newreno_dup1", "newreno_dup1_noss"]
    
        out2 = File.new("../temp/avg_tout_graph2_#{runType}_#{bufSizeInPackets}.dat", "w")
        #     out2.puts "1 0"
        #     out2.puts "2 0"
        for flowId in [4, 8, 16, 32, 64, 128]
            puts "----- flow #{flowId} -----"
            prefixDir = "#{DATA_DUMP_DIR}/#{runType}_flow_#{flowId}_s_#{synchSizeInK}K_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s"
            puts prefixDir
            tempDir = "#{prefixDir}/temp"
            gput = `cat #{tempDir}/tout_avg.dat | #{BASEDIR}/column.pl -t " " 3`
            num_blocks = `cat #{tempDir}/synch1.dat | wc -l  | #{BASEDIR}/column.pl -t " " 0`
            out2.puts "#{flowId} #{gput.to_f} #{num_blocks.to_i} #{gput.to_f/num_blocks.to_f}"
        end
        out2.close
        str += " '../temp/avg_tout_graph2_#{runType}_#{bufSizeInPackets}.dat' using 1:4 with linespoint title '#{runType}'"
    
        if runType != "newreno_dup1_noss"
            str += ","
        end
    
    end
    
    str += ";"
    out.puts "#{str}"
    
    out.close
    system("cat ../temp/tout_vs_servers.gp | gnuplot -")
    
    system("rm ../temp/tout_vs_servers.gp")
    system("rm ../temp/avg_tout_graph2_#{runType}_#{bufSizeInPackets}.dat")
    
end
