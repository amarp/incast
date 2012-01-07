#!/usr/bin/ruby

for runtype in ["newreno", "newreno_lt", "newreno_dup1", "newreno_dup1_noss"]
    system("./tout_analysis.rb 4 64 20 256000 #{runtype}")
    system("-----")
    system("./tout_analysis.rb 8 64 20 256000 #{runtype}")
    system("-----")
    system("./tout_analysis.rb 16 64 20 256000 #{runtype}")
    system("-----")
    system("./tout_analysis.rb 32 64 20 256000 #{runtype}")
    system("-----")
    system("./tout_analysis.rb 64 64 20 256000 #{runtype}")
    system("-----")
    system("./tout_analysis.rb 128 64 20 256000 #{runtype}")
    system("-----")
end
