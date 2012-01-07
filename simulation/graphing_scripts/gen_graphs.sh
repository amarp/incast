#!/bin/bash -x

rm ../graphs/*.eps
rm ../temp/*

#
./gen_tput_vs_servers_buf_fixed.rb reno
./gen_tput_vs_servers_buf_fixed.rb newreno

#
./gen_tput_vs_servers_vs_synch_size.rb reno
./gen_tput_vs_servers_vs_synch_size.rb newreno

#
./gen_tput_vs_servers_vs_buf.rb reno
./gen_tput_vs_servers_vs_buf.rb newreno

./gen_tput_vs_servers_vs_tcp_imp.rb

./gen_tput_vs_servers_vs_newreno_dupack_lt_noss.rb

./gen_tput_vs_servers_vs_synch_size_rto.rb

./gen_tput_vs_servers_vs_tcp_imp_rto.rb

./gen_tput_vs_servers_vs_tcp_imp_red.rb

./gen_tput_vs_synch_vs_buf.rb


# for the neat spiky graph with goodput, timeout and sru_request events
# ./gen_spike_graph.rb


# for the simulation vs real world comparison graph
# ./gen_tput_vs_servers_buf_fixed_simNreal.rb
