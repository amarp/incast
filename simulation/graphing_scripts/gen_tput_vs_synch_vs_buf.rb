#!/usr/bin/ruby

runType = "newreno"
#runType = "reno_rto"

BASEDIR = ".."
puts BASEDIR
DATA_DUMP_DIR = "#{BASEDIR}/data_dump/buf_sru_16"
GRAPHDIR = "#{BASEDIR}/graphs"

synchSizeInK = 256
bufSizeInPackets = 64
runTimeInSec = 20
for gtype in ["monochrome", "color"]

    for flowId in [16]
        out = File.new("../temp/gput_vs_synch_vs_buf.gp", "w") 
        
        out.puts "set terminal postscript eps #{gtype};"
        out.puts "set size 0.65;"
        out.puts "set output '#{GRAPHDIR}/_graph2_goodput_degradation_#{runType}_servers_#{flowId}_variable_buf_variable_synch_#{gtype}.eps';"
        out.puts "set title \"Average Goodput VS \# SRU \\n(# of servers = #{flowId}) \";"
        out.puts "set xlabel \"SRU (KB)\"; set ylabel \"Goodput (Mbps)\";"
        #out.puts "set xtic rotate by 90;"
        out.puts "set logscale x 2;"
        out.puts "set logscale y;"
        out.puts "set yrange [1:1000]"
        out.puts "set key left bottom"
        
        str = "plot "
        for bufSizeInPackets in [64, 128, 256, 512]
            out2 = File.new("../temp/gput_cum_avg_graph2_#{runType}_servers_#{flowId}_buf_#{bufSizeInPackets}.dat", "w")
            #out2.puts "1 944"
            #out2.puts "2 971"

            for synchSizeInK in [1, 2, 4, 10, 100, 1000, 10000]
                if (synchSizeInK >= 1000) then
                    runTimeInSec = 50
                else
                    runTimeInSec = 20
                end
                puts "----- SRU = #{synchSizeInK}K -----"
                prefixDir = "#{DATA_DUMP_DIR}/#{runType}_flow_#{flowId}_s_#{synchSizeInK}K_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s"
                puts prefixDir
                tempDir = "#{prefixDir}/temp"
                gput = `cat #{tempDir}/gput_cum_avg.dat | #{BASEDIR}/column.pl -t " " 1`
                out2.puts "#{synchSizeInK} #{gput}"
            end
            out2.close
            str += " '../temp/gput_cum_avg_graph2_#{runType}_servers_#{flowId}_buf_#{bufSizeInPackets}.dat' using 1:2 with linespoint title 'buf = #{bufSizeInPackets}'"
            
            if bufSizeInPackets != 512
                str += ","
            end
        end 

        str += ";"
        out.puts "#{str}"
        
        out.close
        system("cat ../temp/gput_vs_synch_vs_buf.gp | gnuplot -")
        
        system("rm ../temp/gput_vs_synch_vs_buf.gp")
        system("rm ../temp/gput_cum_avg_graph2_#{runType}_servers_#{flowId}_buf_#{bufSizeInPackets}.dat")
    end
end
