#!/usr/bin/ruby

storage_server = "lotsofstorage.com"

for runtype in ["newreno"]
    system("./run_one.rb 4 64 20 1024000 #{runtype}")
    system("./run_one.rb 8 64 20 512000 #{runtype}")
    system("./run_one.rb 16 64 20 256000 #{runtype}")
    system("./run_one.rb 32 64 20 128000 #{runtype}")
    system("./run_one.rb 64 64 20 64000 #{runtype}")
    system("./run_one.rb 128 64 20 32000 #{runtype}")
end
system("mkdir -p ../data_dump/newreno_4M_block_size")
system("mv ../data_dump/newreno_* ../data_dump/newreno_4M_block_size")

for runtype in ["newreno"]
    system("./run_one.rb 4 64 20 256000 #{runtype}")
    system("./run_one.rb 8 64 20 128000 #{runtype}")
    system("./run_one.rb 16 64 20 64000 #{runtype}")
    system("./run_one.rb 32 64 20 32000 #{runtype}")
    system("./run_one.rb 64 64 20 16000 #{runtype}")
    system("./run_one.rb 128 64 20 8000 #{runtype}")
end
system("mkdir -p ../data_dump/newreno_1M_block_size")
system("mv ../data_dump/newreno_* ../data_dump/newreno_1M_block_size")

=begin
for minRTO_val in [0.00005, 0.0001, 0.0002, 0.0005, 0.001, 0.005, 0.01, 0.05, 0.1, 0.2]
    num_servers = 64
    sru = 256000
    system("./run_one.rb #{num_servers} 64 20 #{sru} newreno_rto #{minRTO_val}")
    system("mv ../data_dump/newreno_* ../data_dump/minRTO_#{minRTO_val}_flow_#{num_servers}")
    system("scp -r ../data_dump/minRTO_* #{storage_server}:~/incast/data_dump/min_rto_var/")
    system("rm -rf ../data_dump/minRTO_*")
end
=end

#for num_servers in [8, 16, 32, 64, 128]
#    system("./run_one.rb #{num_servers} 64 20 256000 fack")
#    system("scp -r ../data_dump/fack_* #{storage_server}:~/incast/data_dump/tcp_256K/")
#    system("rm -rf ../data_dump/fack_*")
#end

=begin
run_time = 20
for stripe_size in [256000]
        if stripe_size == 1000000
                run_time = 50
        else
                run_time = 20
        end

        for runtype in ["sack", "sack_dup1"]
            for num_servers in [4, 8, 16, 32, 64, 128]
                system("./run_one.rb #{num_servers} 64 #{run_time} #{stripe_size} #{runtype}")
                system("scp -r ../data_dump/#{runtype}_* #{storage_server}:~/incast/data_dump/tcp_256K/")
                system("rm -rf ../data_dump/#{runtype}_*")
            end
        end
end
=end

=begin
#for runtype in ["newreno", "newreno_lt", "newreno_dup1", "newreno_dup1_noss"]
#for runtype in ["reno", "sack", "reno_red", "newreno_red", "sack_red"]
for runtype in ["reno_red", "newreno_red", "sack_red"]
    system("./run_one.rb 4 128 20 256000 #{runtype}")
    system("./run_one.rb 8 128 20 256000 #{runtype}")
    system("./run_one.rb 16 128 20 256000 #{runtype}")
    system("./run_one.rb 32 128 20 256000 #{runtype}")
    system("./run_one.rb 64 128 20 256000 #{runtype}")
    system("./run_one.rb 128 128 20 256000 #{runtype}")
end
=end

=begin
256K synch, 64K buf, 20s run

sack_red
reno_lt
newreno_lt
reno_dup1
newreno_dup1
=end


=begin
# varying buffer size, and num_servers, for different tcp impls
for bufSize in [1024]
    for runtype in ["newreno"]
        for num_servers in [4, 8, 16, 32, 64, 128]
            system("./run_one.rb #{num_servers} #{bufSize} 20 256000 #{runtype}")
            system("scp -r ../data_dump/#{runtype}_* #{storage_server}:~/incast/data_dump/")
            system("rm -rf ../data_dump/#{runtype}_*")
        end
    end
end

for runtype in ["reno", "newreno"]
    for num_servers in [4, 8, 16, 32, 64, 128]
        system("./run_one.rb #{num_servers} 64 50 8000000 #{runtype}")
        system("scp -r ../data_dump/#{runtype}_* #{storage_server}:~/incast/data_dump/new/")
        system("rm -rf ../data_dump/#{runtype}_*")
    end
end
=end

=begin
for runtype in ["newreno"]
    for num_servers in [16]
        for bufSize in [64, 128, 256, 512]
            run_time = 20
            for stripe_size in [1000, 2000, 4000, 10000, 100000, 1000000, 10000000]
                if stripe_size >= 1000000
                    run_time = 50
                else
                    run_time = 20
                end

                system("./run_one.rb #{num_servers} #{bufSize} #{run_time} #{stripe_size} #{runtype}")
                system("scp -r ../data_dump/#{runtype}_* #{storage_server}:~/incast/data_dump/buf_sru/")
                system("rm -rf ../data_dump/#{runtype}_*")
            end
        end
    end
end

run_time = 20
for stripe_size in [10000, 256000, 1000000]
        if stripe_size == 1000000
                run_time = 50
        else
                run_time = 20
        end

        for runtype in ["reno_rto", "newreno_rto", "sack_rto"]
            for num_servers in [4, 8, 16, 32, 64, 128]
                system("./run_one.rb #{num_servers} 64 #{run_time} #{stripe_size} #{runtype}")
                system("scp -r ../data_dump/#{runtype}_* #{storage_server}:~/incast/data_dump/rto/")
                system("rm -rf ../data_dump/#{runtype}_*")
            end
        end
end
=end

=begin
# tests VARYING #SERVERS,  STRIPE SIZE(10K, 100K, 1M) and TCP IMPL (RENO, NEWRENO, SACK)

#for runtype in ["reno", "newreno", "sack"]
for runtype in ["reno", "newreno"]
    #system("./run_one.rb 1 64 20 10000 #{runtype}")
    #system("./run_one.rb 2 64 20 10000 #{runtype}")
    system("./run_one.rb 4 64 20 10000 #{runtype}")
    system("./run_one.rb 8 64 20 10000 #{runtype}")
    system("./run_one.rb 16 64 20 10000 #{runtype}")
    system("./run_one.rb 32 64 20 10000 #{runtype}")
    system("./run_one.rb 64 64 20 10000 #{runtype}")
    system("./run_one.rb 128 64 20 10000 #{runtype}")

    #system("./run_one.rb 1 64 20 100000 #{runtype}")
    #system("./run_one.rb 2 64 20 100000 #{runtype}")
    system("./run_one.rb 4 64 20 100000 #{runtype}")
    system("./run_one.rb 8 64 20 100000 #{runtype}")
    system("./run_one.rb 16 64 20 100000 #{runtype}")
    system("./run_one.rb 32 64 20 100000 #{runtype}")
    system("./run_one.rb 64 64 20 100000 #{runtype}")
    system("./run_one.rb 128 64 20 100000 #{runtype}")

    #system("./run_one.rb 1 64 50 1000000 #{runtype}")
    #system("./run_one.rb 2 64 50 1000000 #{runtype}")
    system("./run_one.rb 4 64 50 1000000 #{runtype}")
    system("./run_one.rb 8 64 50 1000000 #{runtype}")
    system("./run_one.rb 16 64 50 1000000 #{runtype}")
    system("./run_one.rb 32 64 50 1000000 #{runtype}")
    system("./run_one.rb 64 64 50 1000000 #{runtype}")
    system("./run_one.rb 128 64 50 1000000 #{runtype}")
end

run_time = 20
for stripe_size in [10000, 256000, 1000000]
        if stripe_size == 1000000
                run_time = 50
        else
                run_time = 20
        end

        for runtype in ["reno_rto", "newreno_rto", "sack_rto"]

            #puts "./run_one.rb 4 64 #{run_time} #{stripe_size} #{runtype}"
            system("./run_one.rb 4 64 #{run_time} #{stripe_size} #{runtype}")
            system("./run_one.rb 8 64 #{run_time} #{stripe_size} #{runtype}")
            system("./run_one.rb 16 64 #{run_time} #{stripe_size} #{runtype}")
            system("./run_one.rb 32 64 #{run_time} #{stripe_size} #{runtype}")
            system("./run_one.rb 64 64 #{run_time} #{stripe_size} #{runtype}")
            system("./run_one.rb 128 64 #{run_time} #{stripe_size} #{runtype}")
        end
end


# varying stripe size, and tcp impl
run_time = 20
for stripe_size in [10000, 100000, 256000, 1000000]
        if stripe_size == 1000000
                run_time = 50
        else
                run_time = 20
        end

        for runtype in ["reno", "newreno", "sack"]

            #puts "./run_one.rb 4 64 #{run_time} #{stripe_size} #{runtype}"
            system("./run_one.rb 4 64 #{run_time} #{stripe_size} #{runtype}")
            system("./run_one.rb 8 64 #{run_time} #{stripe_size} #{runtype}")
            system("./run_one.rb 16 64 #{run_time} #{stripe_size} #{runtype}")
            system("./run_one.rb 32 64 #{run_time} #{stripe_size} #{runtype}")
            system("./run_one.rb 64 64 #{run_time} #{stripe_size} #{runtype}")
            system("./run_one.rb 128 64 #{run_time} #{stripe_size} #{runtype}")
        end
end

# varying buffer size, and num_servers, for different tcp impls
for bufSize in [32, 64, 128, 256, 512, 1024]
    for runtype in ["reno", "newreno"]
        for num_servers in [4, 8, 16, 32, 64, 128]
            system("./run_one.rb #{num_servers} #{bufSize} 20 256000 #{runtype}")
        end
    end
end


# varying # of servers, newreno + {lt/dup1/dup1_noss}, with 64K buffer
for runtype in ["newreno_lt", "newreno_dup1", "newreno_dup1_noss"]
    system("./run_one.rb 4 64 20 256000 #{runtype}")
    system("./run_one.rb 8 64 20 256000 #{runtype}")
    system("./run_one.rb 16 64 20 256000 #{runtype}")
    system("./run_one.rb 32 64 20 256000 #{runtype}")
    system("./run_one.rb 64 64 20 256000 #{runtype}")
    system("./run_one.rb 128 64 20 256000 #{runtype}")
end
=end
