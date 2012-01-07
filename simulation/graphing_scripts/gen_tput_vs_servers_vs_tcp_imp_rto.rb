#!/usr/bin/ruby

runType = "reno"

BASEDIR = ".."
puts BASEDIR
DATA_DUMP_DIR = "#{BASEDIR}/data_dump/rto"
GRAPHDIR = "#{BASEDIR}/graphs"

synchSizeInK = 256
bufSizeInPackets = 64
runTimeInSec = 20

for gtype in ["monochrome", "color"]
    for synchSizeInK in [10, 256, 1000]

        out = File.new("../temp/tput_vs_synchSize.gp", "w") 

        out.puts "set terminal postscript eps  #{gtype};"
        out.puts "set size 0.65;"
        out.puts "set output '#{GRAPHDIR}/_graph2_goodput_tcp_variants_rto_buf_#{bufSizeInPackets}_synch_#{synchSizeInK}K_#{gtype}.eps';"
        out.puts "set title \"TCP Implementation Comparison (with reduced RTOmin) \\n (SRU = #{synchSizeInK}K, buf = #{bufSizeInPackets}KB)\";"
        out.puts "set xlabel \"Number of Servers\"; set ylabel \"Goodput (Mbps)\";"
        #out.puts "set xtic rotate by 90;"
        out.puts "set logscale x 2;"
        out.puts "set logscale y;"
        out.puts "set yrange [1:1000]"
        out.puts "set key left bottom;"

        if (synchSizeInK == 1000 || synchSizeInK == 8000) then
            runTimeInSec = 50
        else
            runTimeInSec = 20
        end

        i = 1
        j = 1
        str = "plot "
        #for runType in ["reno", "newreno", "sack", "reno_rto", "newreno_rto", "sack_rto"]
        for runType in ["reno", "newreno", "reno_rto", "newreno_rto"]
            if runType == "reno" || runType == "newreno" || runType == "sack"
                DATA_DUMP_DIR = "#{BASEDIR}/data_dump/sru"
            else
                DATA_DUMP_DIR = "#{BASEDIR}/data_dump/rto"
            end

            out2 = File.new("../temp/gput_cum_avg_graph2_#{runType}_synch_#{synchSizeInK}.dat", "w")
            for flowId in [4, 8, 16, 32, 64, 128]
                puts "----- flow #{flowId} -----"
                prefixDir = "#{DATA_DUMP_DIR}/#{runType}_flow_#{flowId}_s_#{synchSizeInK}K_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s"
                puts prefixDir
                tempDir = "#{prefixDir}/temp"
                gput = `cat #{tempDir}/gput_cum_avg.dat | #{BASEDIR}/column.pl -t " " 1`
                out2.puts "#{flowId} #{gput}"
            end
            out2.close
            str += " '../temp/gput_cum_avg_graph2_#{runType}_synch_#{synchSizeInK}.dat' using 1:2 with linespoint linetype #{i} lw #{i} pointtype #{j} title '#{runType}'"
            i = i + 1
            j = j + 1

=begin
            if runType == "sack" 
                i = 1
            end

            if runType != "sack_rto"
                str += ","
            end
=end

            if runType == "newreno"
                i = 1
            end

            if runType != "newreno_rto"
                str += ","
            end

        end

        str += ";"
        out.puts "#{str}"

        out.close
        system("cat ../temp/tput_vs_synchSize.gp | gnuplot -")

        system("rm ../temp/tput_vs_synchSize.gp")
        system("rm ../temp/gput_cum_avg_graph2_*.dat")

        puts "-----"

=begin
             ## RED

             out = File.new("../temp/tput_vs_synchSize1.gp", "w") 

             out.puts "set terminal postscript eps monochrome;"
             out.puts "set size 0.65;"
             out.puts "set output '#{GRAPHDIR}/_graph2_red_#{synchSizeInK}.eps';"
             out.puts "set title \"Average Goodput VS \# Servers (buf = #{bufSizeInPackets} packets, synch = #{synchSizeInK}K)\";"
             out.puts "set xlabel \"Number of Servers\"; set ylabel \"Goodput (Mbps)\";"
             #out.puts "set xtic rotate by 90;"
             out.puts "set logscale x;"
             out.puts "set logscale y;"
             #out.puts "set yrange [0:1000]"

             str = "plot "
             for runType in ["reno_red", "newreno_red", "sack_red"]

                 out2 = File.new("../temp/gput_cum_avg_graph2_#{runType}_synch_#{synchSizeInK}.dat", "w")
                 for flowId in [4, 8, 16, 32, 64, 128]
                     puts "----- flow #{flowId} -----"
                     prefixDir = "#{DATA_DUMP_DIR}/#{runType}_flow_#{flowId}_s_#{synchSizeInK}K_buf_#{bufSizeInPackets}_time_#{runTimeInSec}s"
                     puts prefixDir
                     tempDir = "#{prefixDir}/temp"
                     gput = `cat #{tempDir}/gput_cum_avg.dat | #{BASEDIR}/column.pl -t " " 1`
                     out2.puts "#{flowId} #{gput}"
                 end
                 out2.close
                 str += " '../temp/gput_cum_avg_graph2_#{runType}_synch_#{synchSizeInK}.dat' using 1:2 with linespoint title '#{runType}'"

                 if runType != "sack_red"
                     str += ","
                 end
             end

             str += ";"
             out.puts "#{str}"

             out.close
             system("cat ../temp/tput_vs_synchSize1.gp | gnuplot -")

             system("rm ../temp/tput_vs_synchSize1.gp")
             system("rm ../temp/gput_cum_avg_graph2_*.dat")
=end

    end
end
