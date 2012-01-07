#!/usr/bin/ruby

runType = "reno_rto"

BASEDIR = ".."
puts BASEDIR
DATA_DUMP_DIR = "#{BASEDIR}/data_dump"
GRAPHDIR = "#{BASEDIR}/graphs"

synchSizeInK = 256
bufSizeInPackets = 64
runTimeInSec = 20

for gtype in ["monochrome", "color"]

    out = File.new("../temp/gput_vs_servers_vs_synch.gp", "w") 

    out.puts "set terminal postscript eps #{gtype};"
    out.puts "set size 0.65;"
    out.puts "set output '#{GRAPHDIR}/_graph2_goodput_degradation_#{runType}_buf_#{bufSizeInPackets}_variable_synch_#{gtype}.eps';"
    #out.puts "set title \"Comparison of Reno and Reno with reduced min RTO \\n (SRU = varying, buffer = #{bufSizeInPackets} packets)\";"
    out.puts "set title \"Comparison of Reno and Reno with reduced RTOmin \\n (SRU = varying, buffer = #{bufSizeInPackets}KB)\";"
    out.puts "set xlabel \"Number of Servers\"; set ylabel \"Goodput (Mbps)\";"
    #out.puts "set xtic rotate by 90;"
    out.puts "set logscale x 2;"
    out.puts "set logscale y;"
    out.puts "set yrange [1:1000]"
    out.puts "set key left bottom"

    i = 1
    j = 1
    str = "plot "
    for runType in ["reno", "reno_rto"]
        for synchSizeInK in [10, 256, 1000]

            if (synchSizeInK == 1000 || synchSizeInK == 8000) then
                runTimeInSec = 50
            else
                runTimeInSec = 20
            end

            if runType == "reno" || runType == "newreno" || runType == "sack"
                DATA_DUMP_DIR = "#{BASEDIR}/data_dump/sru"
            else
                DATA_DUMP_DIR = "#{BASEDIR}/data_dump/rto"
            end

            out2 = File.new("../temp/gput_cum_avg_graph2_#{synchSizeInK}_#{runType}.dat", "w")
            #out2.puts "1 944"
            #out2.puts "2 971"
            for flowId in [4, 8, 16, 32, 64, 128]
                puts "----- flow #{flowId} -----"
                prefixDir = "#{DATA_DUMP_DIR}/#{runType}_flow_#{flowId}_s_#{synchSizeInK}K_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s"
                puts prefixDir
                tempDir = "#{prefixDir}/temp"
                gput = `cat #{tempDir}/gput_cum_avg.dat | #{BASEDIR}/column.pl -t " " 1`
                out2.puts "#{flowId} #{gput}"
            end
            out2.close
            str += " '../temp/gput_cum_avg_graph2_#{synchSizeInK}_#{runType}.dat' using 1:2 with linespoint linetype #{i} lw #{i} pointtype #{j} title '#{runType} #{synchSizeInK}KB'"

            if synchSizeInK != 1000 
                str += ","
            elsif runType != "reno_rto"
                str += ","
            end

            i = i + 1
            j = j + 1
        end
        i = 1
    end

    str += ";"
    out.puts "#{str}"

    out.close
    system("cat ../temp/gput_vs_servers_vs_synch.gp | gnuplot -")

    system("rm ../temp/gput_vs_servers_vs_synch.gp")
    system("rm ../temp/gput_cum_avg_graph2_#{synchSizeInK}.dat")
end
