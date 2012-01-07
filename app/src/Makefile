all: client server
	echo "hi"

client: clean
	g++ -g client/client.cc -o client/a.out

server: clean
	g++ -g server/server.cc -o server/a.out

clean:
	rm -f client/a.out
	rm -f server/a.out 

