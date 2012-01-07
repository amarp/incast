#!/usr/bin/ruby

runType = "newreno"
#runType = "reno_rto"

BASEDIR = ".."
puts BASEDIR
#DATA_DUMP_DIR = "#{BASEDIR}/../../app/logs"
#DATA_DUMP_DIR = "#{BASEDIR}/../../panasas/app/logs/logs_force_10_s50_32K"
#DATA_DUMP_DIR = "#{BASEDIR}/../../panasas/app/logs/logs_force_10_s50_64K"
#DATA_DUMP_DIR = "#{BASEDIR}/../../pdl/hp_QOS_noLLFC"
#DATA_DUMP_DIR = "#{BASEDIR}/../../panasas/app/logs/panasas/32k"
#DATA_DUMP_DIR = "#{BASEDIR}/../../pdl"
GRAPHDIR = "#{BASEDIR}/graphs"

#for run in ["hp_noQOS_noLLFC", "force10_32k"]
for run in ["force10_32k"]

  puts "**********"
  puts run
  if run == "hp_noQOS_noLLFC"
      DATA_DUMP_DIR = "#{BASEDIR}/../../pdl/hp_QOS_noLLFC"
      num_servers = 32
  else
      DATA_DUMP_DIR = "#{BASEDIR}/../../panasas/app/logs/panasas/32k"
      num_servers = 10
  end

  synchSizeInK = 256
  #bufSizeInPackets = "unknown"
  bufSizeInPackets = "64KB"
  for gtype in ["monochrome", "color"]

      out = File.new("../temp/gput_vs_servers_vs_synch.gp", "w") 
      
      out.puts "set terminal postscript eps #{gtype};"
      out.puts "set size 0.65;"
      out.puts "set output '#{GRAPHDIR}/_app_goodput_vs_servers_#{runType}_#{run}_variable_synch_#{gtype}.eps';"
      #out.puts "set title \"Average Goodput VS \# Servers \\n(buffer size= #{bufSizeInPackets}) \";"
      out.puts "set title \"Average Goodput VS \# Servers\";"
      out.puts "set xlabel \"Number of Servers\"; set ylabel \"Goodput (Mbps)\";"
      ##out.puts "set xtic rotate by 90;"
      out.puts "set logscale x 2;"
      #out.puts "set logscale y;"
      #out.puts "set key left bottom"
      out.puts "set yrange [1:1000]"
      
      str = "plot "
      
      for synchSize in [100000, 256000, 1000000]
          out2 = File.new("../temp/gput_cum_avg_graph2_#{synchSize}.dat", "w")
          #out2.puts "1 944"
          #out2.puts "2 971"
          #for flowId in [2, 4, 8, 16, 27]
          for flowId in 1..10
              puts "----- flow #{flowId} -----"
              prefixDir = "#{DATA_DUMP_DIR}"
              puts prefixDir
              if run == "hp_noQOS_noLLFC"
                  gput =  `grep "Goodput" #{prefixDir}/client_#{flowId}_#{synchSize}.log | #{BASEDIR}/column.pl -t " " 1`
              else
                  gput = `grep "Goodput" #{prefixDir}/#{synchSize}/#{flowId}/client_#{flowId}_#{synchSize}_1.log | #{BASEDIR}/column.pl -t " " 1`
              end
              out2.puts "#{flowId} #{gput.chomp("Mbps")}"
          end
          out2.close
          str += " '../temp/gput_cum_avg_graph2_#{synchSize}.dat' using 1:2 with linespoint title 'SRU = #{synchSize/1000}KB'"
          
      if synchSize != 1000000
          str += ","
      end
          
      end

      str += ";"
      out.puts "#{str}"
      
      out.close
      system("cat ../temp/gput_vs_servers_vs_synch.gp | gnuplot -")
      
      system("rm ../temp/gput_vs_servers_vs_synch.gp")
      system("rm ../temp/gput_cum_avg_graph2_#{synchSize}.dat")
  end
end
