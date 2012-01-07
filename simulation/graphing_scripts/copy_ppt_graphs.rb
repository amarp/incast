#!/usr/bin/ruby

system("./gen_tput_vs_servers_buf_fixed.rb")
system("./gen_tput_vs_servers_vs_buf.rb")
system("./gen_tput_vs_servers_vs_synch_size.rb")
system("./gen_tput_vs_servers_vs_tcp_imp.rb")

system("cp ../graphs/_graph2_goodput_* ../../../ppt/")
system("cp ../graphs/_graph_gput_default_flows_8_synch_1000000_buf_64_time_20_Magnified.eps ../../../ppt/")
system("cp ../graphs/_graph_gput_default_flows_8_synch_10000_buf_64_time_20_Magnified.eps ../../../ppt/")
