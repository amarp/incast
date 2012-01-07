#!/usr/bin/ruby

runType = "newreno"

if ARGV.size < 1
    puts "Usage: ./gen_tput_vs_servers_vs_block_size.rb runType"
    exit
end

runType = ARGV[0]

BASEDIR = ".."
puts BASEDIR
DATA_DUMP_DIR = "#{BASEDIR}/data_dump/block"
GRAPHDIR = "#{BASEDIR}/graphs"

synchSizeInK = 256
bufSizeInPackets = 64
runTimeInSec = 20
for gtype in ["monochrome", "color"]

    out = File.new("../temp/gput_vs_servers_vs_block.gp", "w") 
    
    out.puts "set terminal postscript eps #{gtype};"
    out.puts "set size 0.65;"
    out.puts "set output '#{GRAPHDIR}/_graph2_goodput_degradation_#{runType}_buf_#{bufSizeInPackets}_variable_block_#{gtype}.eps';"
    #out.puts "set title \"Average Goodput VS \# Servers \\n(Buffer = #{bufSizeInPackets} packets) \";"
    out.puts "set title \"Average Goodput VS \# Servers \\n(Buffer = #{bufSizeInPackets}KB) \";"
    out.puts "set xlabel \"Number of Servers\"; set ylabel \"Goodput (Mbps)\";"
    #out.puts "set xtic rotate by 90;"
    out.puts "set logscale x 2;"
    #out.puts "set logscale y;"
    out.puts "set yrange [1:1000]"
    #out.puts "set key left bottom"
    
    str = "plot "
    for blockSize in [4, 1]

        if blockSize == 1
            flow_sru_map = { 4 => 256000, 8 => 128000, 16 => 64000, 32 => 32000, 64 => 16000, 128 => 8000 }
        elsif blockSize == 4
            flow_sru_map = { 4 => 1024000, 8 => 512000, 16 => 256000, 32 => 128000, 64 => 64000, 128 => 32000 }
        end

        
        out2 = File.new("../temp/gput_cum_avg_graph2_#{blockSize}.dat", "w")
        #out2.puts "1 944"
        #out2.puts "2 971"
        for flowId in [4, 8, 16, 32, 64, 128]
            puts "----- flow #{flowId} -----"
            synchSizeInK = flow_sru_map[flowId]/1000
            prefixDir = "#{DATA_DUMP_DIR}/newreno_#{blockSize}M_block_size/#{runType}_flow_#{flowId}_s_#{synchSizeInK}K_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s"
            puts prefixDir
            tempDir = "#{prefixDir}/temp"
            gput = `cat #{tempDir}/gput_cum_avg.dat | #{BASEDIR}/column.pl -t " " 1`
            out2.puts "#{flowId} #{gput}"
        end
        out2.close
        str += " '../temp/gput_cum_avg_graph2_#{blockSize}.dat' using 1:2 with linespoint title 'block size = #{blockSize}MB'"
        
        if blockSize != 1
            str += ","
        end
        
    end

    str += ";"
    out.puts "#{str}"
    
    out.close
    system("cat ../temp/gput_vs_servers_vs_block.gp | gnuplot -")
    
    system("rm ../temp/gput_vs_servers_vs_block.gp")
    system("rm ../temp/gput_cum_avg_graph2_#{blockSize}.dat")
end
