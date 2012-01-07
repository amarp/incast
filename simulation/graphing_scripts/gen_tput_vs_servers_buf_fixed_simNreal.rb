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
GRAPHDIR = "#{BASEDIR}/graphs"

synchSizeInK = 256
#synchSizeInK = 8000
bufSizeInPackets = 64
runTimeInSec = 20
#runTimeInSec = 50


for gtype in ["monochrome", "color"]

    DATA_DUMP_DIR = "#{BASEDIR}/data_dump/tcp_newreno_256K"
    out = File.new("../temp/gput_vs_servers.gp", "w") 
    
    out.puts "set terminal postscript eps #{gtype};"
    out.puts "set size 0.65;"
    out.puts "set output '#{GRAPHDIR}/_comparison_goodput_degradation_#{runType}_synch_#{synchSizeInK}K_#{gtype}.eps';"
    out.puts "set title \"Average Goodput VS \# Servers \\n (SRU = #{synchSizeInK}KB)\";"
    out.puts "set xlabel \"Number of Servers\"; set ylabel \"Goodput (Mbps)\";"
    #out.puts "set xtic rotate by 90;"
    #out.puts "set logscale x 2;"
    #out.puts "set logscale y;"
    out.puts "set yrange [1:1000]"
    
    str = "plot "
    
=begin
    bufSizeInPackets = 64
    out2 = File.new("../temp/gput_cum_avg_graph2_#{bufSizeInPackets}.dat", "w")
    out2.puts "1 944"
    out2.puts "2 971"
    for flowId in 1..32
        puts "----- flow #{flowId} -----"
        prefixDir = "#{DATA_DUMP_DIR}/#{runType}_flow_#{flowId}_s_#{synchSizeInK}K_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s"
        puts prefixDir
        tempDir = "#{prefixDir}/temp"
        gput = `cat #{tempDir}/gput_cum_avg.dat | #{BASEDIR}/column.pl -t " " 1`
        out2.puts "#{flowId} #{gput}"
    end
    out2.close
    str += " '../temp/gput_cum_avg_graph2_#{bufSizeInPackets}.dat' using 1:2 with linespoint title 'Simulation with #{bufSizeInPackets}KB buffer', "
=end

    bufSizeInPackets = 32
    DATA_DUMP_DIR = "#{BASEDIR}/data_dump/tcp_newreno_256K"
    out2 = File.new("../temp/gput_cum_avg_graph2_#{bufSizeInPackets}.dat", "w")
    out2.puts "1 944"
    out2.puts "2 971"
    for flowId in 1..32
        puts "----- flow #{flowId} -----"
        prefixDir = "#{DATA_DUMP_DIR}/#{runType}_flow_#{flowId}_s_#{synchSizeInK}K_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s"
        puts prefixDir
        tempDir = "#{prefixDir}/temp"
        gput = `cat #{tempDir}/gput_cum_avg.dat | #{BASEDIR}/column.pl -t " " 1`
        out2.puts "#{flowId} #{gput}"
    end
    out2.close
    str += " '../temp/gput_cum_avg_graph2_#{bufSizeInPackets}.dat' using 1:2 with linespoint title 'Simulation with #{bufSizeInPackets}KB buffer', "
    
    DATA_DUMP_DIR = "#{BASEDIR}/../../pdl/hp_noQOS_noLLFC"
    out2 = File.new("../temp/gput_cum_avg_graph2_#{synchSizeInK}K_real.dat", "w")
    for flowId in 1..32
        puts "----- flow #{flowId} -----"
        prefixDir = "#{DATA_DUMP_DIR}"
        puts prefixDir
        gput = `grep "Goodput" #{prefixDir}/client_#{flowId}_#{synchSizeInK * 1000}.log | #{BASEDIR}/column.pl -t " " 1`
        out2.puts "#{flowId} #{gput.chomp("Mbps")}"
    end
    out2.close

    #run = "HP Procurve 2848 (No QOS, No EFC)" 
    run = "HP Procurve 2848 (No QoS)" 
    str += " '../temp/gput_cum_avg_graph2_#{synchSizeInK}K_real.dat' using 1:2 with linespoint title '#{run}'"
            
    str += ";"
    out.puts "#{str}"
    
    out.close
    system("cat ../temp/gput_vs_servers.gp | gnuplot -")
    
    system("rm ../temp/gput_vs_servers.gp")
    system("rm ../temp/gput_cum_avg_graph2_#{bufSizeInPackets}.dat")
    system("rm ../temp/gput_cum_avg_graph2_#{synchSizeInK}K_real.dat")
    
end
