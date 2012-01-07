#!/usr/bin/ruby

runType = "newreno"
#runType = "reno_rto"

BASEDIR = ".."
puts BASEDIR
GRAPHDIR = "#{BASEDIR}/graphs"

synchSize = 256000
#bufSizeInPackets = "unknown"
bufSizeInPackets = "64KB"
for gtype in ["monochrome", "color"]

    out = File.new("../temp/gput_vs_servers_vs_synch.gp", "w") 
    
    out.puts "set terminal postscript eps #{gtype};"
    out.puts "set size 0.65;"
    out.puts "set output '#{GRAPHDIR}/_app_goodput_vs_servers_force10_#{runType}_synch_#{synchSize/1000}K_#{gtype}.eps';"
    out.puts "set title \"Average Goodput VS \# Servers\\n SRU = #{synchSize/1000}KB\";"
    out.puts "set xlabel \"Number of Servers\"; set ylabel \"Goodput (Mbps)\";"
    ##out.puts "set xtic rotate by 90;"
    #out.puts "set logscale x 2;"
    #out.puts "set logscale y;"
    #out.puts "set key left bottom"
    out.puts "set yrange [1:1000]"

    str = "plot "


    runNumber = 1

    for DATA_DUMP_DIR in ["#{BASEDIR}/../../panasas/app/logs/panasas/32k/run_1/256000"]
        out2 = File.new("../temp/gput_cum_avg_graph2_#{synchSize}_#{runNumber}.dat", "w")
        for flowId in 1..23
            puts "----- flow #{flowId} -----"
            prefixDir = "#{DATA_DUMP_DIR}"
            puts prefixDir
            gput = `grep "Goodput" #{prefixDir}/#{flowId}/client_#{flowId}_#{synchSize}.log | #{BASEDIR}/column.pl -t " " 1`
            out2.puts "#{flowId} #{gput.chomp("Mbps")}"
        end
        out2.close

        #run = "Force 10 S50 (32KB buffer)" 
        run = "Force 10 S50 (QoS)" 
        str += " '../temp/gput_cum_avg_graph2_#{synchSize}_#{runNumber}.dat' using 1:2 with linespoint title '#{run}'"
            
         str += ","
        runNumber = runNumber + 1
    end

    for DATA_DUMP_DIR in ["#{BASEDIR}/../../panasas/app/logs/panasas/64K/256000"]
        out2 = File.new("../temp/gput_cum_avg_graph2_#{synchSize}_#{runNumber}.dat", "w")
        for flowId in 1..47
            puts "----- flow #{flowId} -----"
            prefixDir = "#{DATA_DUMP_DIR}"
            puts prefixDir
            gput = `grep "Goodput" #{prefixDir}/#{flowId}/client_#{flowId}_#{synchSize}.log | #{BASEDIR}/column.pl -t " " 1`
            out2.puts "#{flowId} #{gput.chomp("Mbps")}"
        end
        out2.close

        #run = "Force 10 S50 (64KB buffer)" 
        run = "Force 10 S50 (No QoS)" 
        str += " '../temp/gput_cum_avg_graph2_#{synchSize}_#{runNumber}.dat' using 1:2 with linespoint title '#{run}'"
            
        #str += ","
        runNumber = runNumber + 1
    end

    str += ";"
    out.puts "#{str}"
    
    out.close
    system("cat ../temp/gput_vs_servers_vs_synch.gp | gnuplot -")
    
    system("rm ../temp/gput_vs_servers_vs_synch.gp")
    for run in 1..(runNumber-1)
        system("rm ../temp/gput_cum_avg_graph2_#{synchSize}_#{run}.dat")
    end
end
