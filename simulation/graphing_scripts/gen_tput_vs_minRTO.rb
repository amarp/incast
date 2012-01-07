#!/usr/bin/ruby

BASEDIR = ".."
puts BASEDIR
DATA_DUMP_DIR = "#{BASEDIR}/data_dump/min_rto_var"
GRAPHDIR = "#{BASEDIR}/graphs"

synchSizeInK = 256
bufSizeInPackets = 64
runTimeInSec = 20
for gtype in ["monochrome", "color"]
        
    #for flows in [16, 64]
    for flows in [16]
        out = File.new("../temp/tput_vs_minRTO.gp", "w") 
        
        out.puts "set terminal postscript eps #{gtype};"
        out.puts "set size 0.65;"
        out.puts "set output '#{GRAPHDIR}/_minRTO_vs_goodput_#{bufSizeInPackets}_synch_#{synchSizeInK}K_#{gtype}.eps';"
        out.puts "set title \"RTOmin vs Goodput\\n (SRU = #{synchSizeInK}KB, buffer = #{bufSizeInPackets}KB)\";"
        out.puts "set xlabel \"RTOmin (seconds)\"; set ylabel \"Goodput (Mbps)\";"
        out.puts "set xtics (\"50u\" 5.0e-05, \"100u\" 0.0001, \"200u\" 0.0002, \"500u\" 0.0005, \"1m\" 0.001, \"5m\" 0.005, \"10m\" 0.01, \"50m\" 0.05, \"100m\" 0.1, \"200m\" 0.2)"
        out.puts "set xtic rotate by 90;"
        out.puts "set logscale x 2;"
        #out.puts "set logscale y;"
        out.puts "set yrange [1:1000]"
        out.puts "set key left bottom;"

        str = "plot "
        out2 = File.new("../temp/gput_cum_avg_vs_RTOmin.dat", "w")
        for runType in ["5.0e-05", "0.0001", "0.0002", "0.0005", "0.001", "0.005", "0.01", "0.05", "0.1", "0.2"]
                prefixDir = "#{DATA_DUMP_DIR}/minRTO_#{runType}_flow_#{flows}"
                puts prefixDir
                tempDir = "#{prefixDir}/temp"
                gput = `cat #{tempDir}/gput_cum_avg.dat | #{BASEDIR}/column.pl -t " " 1`
                out2.puts "#{runType} #{gput}"
        end
        out2.close
        
        str += " '../temp/gput_cum_avg_vs_RTOmin.dat' using 1:2 with linespoint title \"number of servers = #{flows}\";"
        out.puts "#{str}"
        
        out.close
        system("cat ../temp/tput_vs_minRTO.gp | gnuplot -")
        
        system("rm ../temp/tput_vs_minRTO.gp")
        system("rm ../temp/gput_cum_avg_vs_RTOmin.dat")
    end
end
