#!/usr/bin/ruby

runType = "newreno"
#runType = "reno_rto"

BASEDIR = ".."
puts BASEDIR
#DATA_DUMP_DIR = "#{BASEDIR}/../../app/logs"
#DATA_DUMP_DIR = "#{BASEDIR}/../../panasas/app/logs/logs_force_10_s50_64K"
DATA_DUMP_DIR = "#{BASEDIR}/../../pdl"
GRAPHDIR = "#{BASEDIR}/graphs"

synchSizeInK = 256
bufSizeInPackets = "unknown"
#bufSizeInPackets = "64KB"
for gtype in ["monochrome", "color"]

    out = File.new("../temp/gput_vs_servers_vs_synch.gp", "w") 
    
    out.puts "set terminal postscript eps #{gtype};"
    out.puts "set size 0.65;"
    out.puts "set output '#{GRAPHDIR}/_app_goodput_vs_sru_#{runType}_buf_#{bufSizeInPackets}_variable_synch_#{gtype}.eps';"
    #out.puts "set title \"Average Goodput VS \# Servers \\n(buffer size= #{bufSizeInPackets}) \";"
    out.puts "set title \"Average Goodput VS \# Servers\";"
    out.puts "set xlabel \"SRU (KB)\"; set ylabel \"Goodput (Mbps)\";"
    out.puts "set xtic rotate by 90;"
    out.puts "set xtics (\"10\" 10000, \"20\" 20000, \"40\" 40000, \"80\" 80000, \"100\" 100000, \"200\" 200000, \"256\" 256000, \"400\" 400000, \"800\" 800000, \"1000\" 1000000)"
    #out.puts "set xtics (\"128\" 128000, \"256\" 256000, \"512\" 512000, \"1000\" 1000000)"
    out.puts "set logscale x 2;"
    out.puts "set logscale y;"
    out.puts "set yrange [1:1000]"
    out.puts "set key left bottom"
    
    str = "plot "
    for flowId in 1..32
    #for flowId in 1..13
    #for flowId in [2, 4, 8, 16, 27]
        out2 = File.new("../temp/gput_cum_avg_graph2_#{flowId}.dat", "w")
        for synchSize in [10000, 20000, 40000, 80000, 100000, 200000, 256000, 400000, 800000, 1000000]
        #for synchSize in [256000, 512000]
            prefixDir = "#{DATA_DUMP_DIR}"
            puts prefixDir
            gput = `grep "Goodput" #{prefixDir}/client_#{flowId}_#{synchSize}.log | #{BASEDIR}/column.pl -t " " 1`
            out2.puts "#{synchSize} #{gput.chomp("Mbps")}"
        end
        out2.close
        str += " '../temp/gput_cum_avg_graph2_#{flowId}.dat' using 1:2 with linespoint title '#{flowId}'"
        
        if flowId != 32
        #if flowId != 13
        #if flowId != 27
            str += ","
        end
        
    end

    str += ";"
    out.puts "#{str}"
    
    out.close
    system("cat ../temp/gput_vs_servers_vs_synch.gp | gnuplot -")
    
    system("rm ../temp/gput_vs_servers_vs_synch.gp")
    system("rm ../temp/gput_cum_avg_graph2_#{flowId}.dat")
end
