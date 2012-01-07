#!/bin/bash -x

rm ../graphs/*.eps
rm ../temp/*

./_app_gen_tput_vs_servers_buf_fixed.rb
./_app_gen_tput_vs_servers_buf_fixed_hp_switches.rb
./_app_gen_tput_vs_servers_buf_fixed_force10_switches.rb
./_app_gen_tput_vs_servers_vs_sru.rb
./_app_gen_tput_vs_servers_buf_fixed_hp_switches_llfc.rb

