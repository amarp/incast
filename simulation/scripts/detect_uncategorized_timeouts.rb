#!/usr/bin/ruby

dir = ARGV[0]
#da = ARGV[1]
dup_ack_count = 2

dropped_rexmit_file = "#{dir}/temp/dropped_rextmits.dat"
#system("cat #{dropped_rexmit_file}")

tmp_filename = "#{dir}/temp/temp_tout.dat"
system("cat #{dir}/temp/dupacksAtTimeout.dat | sort -k 1 | awk '{if($1>#{dup_ack_count}){printf(\"%d %d\\n\", $4, $5)}}' > #{tmp_filename}")
#system("cat #{tmp_filename}")

num_dropped_rexmits = `cat #{dropped_rexmit_file} | wc -l`
num_timeouts_to_check = `cat #{tmp_filename} | wc -l`
num_accounted_as_dropped_rexmits = 0
num_not_accounted_as_dropped_rexmits = 0

File.open(tmp_filename) do |file|
    while line = file.gets
        a, b = line.chomp.split(/\s+/)
        wc_l = `grep " #{a.to_i} #{b.to_i}" #{dropped_rexmit_file} | wc -l`
        #puts "amar: #{wc_l.to_i}"
        if wc_l.to_i >= 1
            #puts "#{a.to_i} #{b.to_i} accounted for as a dropped rexmit"
            num_accounted_as_dropped_rexmits = num_accounted_as_dropped_rexmits + 1
        else
            puts "#{a.to_i} #{b.to_i} NOT accounted for as a dropped rexmit!"
            num_not_accounted_as_dropped_rexmits = num_not_accounted_as_dropped_rexmits + 1
        end
    end
end

remaining_dropped_rexmits = num_dropped_rexmits.to_i - num_accounted_as_dropped_rexmits

# Format: num_dropped_rexmits, num_timeouts_to_check(in dup_ack tail), num_accounted_as_dropped_rexmits, num_not_accounted_as_dropped_rexmits, remaining_dropped_rexmits
out = File.new("#{dir}/temp/account.dat", "w")
out.puts "#{num_dropped_rexmits.to_i} #{num_timeouts_to_check.to_i} #{num_accounted_as_dropped_rexmits.to_i} #{num_not_accounted_as_dropped_rexmits.to_i} #{remaining_dropped_rexmits.to_i}"
out.close

system("rm #{tmp_filename}")
