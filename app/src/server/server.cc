#include <arpa/inet.h>

#include <netdb.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <unistd.h>
#include <iostream>

#define MAX_MSG 256000
#define LINE_ARRAY_SIZE (MAX_MSG + 1)

using namespace std;

int main()
{
  int listenSocket, connectSocket, i;
  unsigned short int listenPort = 65125;
  socklen_t clientAddressLength;
  struct sockaddr_in clientAddress, serverAddress;
  //char line[LINE_ARRAY_SIZE];
  int line;
  unsigned int bytesToSend;
  char *fileToSend;

  unsigned long buffer_size = 1000;

  
  //Create socket for listening for client connection requests
  listenSocket = socket(AF_INET, SOCK_STREAM, 0);
  if (listenSocket < 0) {
    cerr << "cannot create listen socket";
    exit(1);
  }
  
  // Bind listen socket to listen port.  
  serverAddress.sin_family = AF_INET;
  serverAddress.sin_addr.s_addr = htonl(INADDR_ANY);
  serverAddress.sin_port = htons(listenPort);


  // BEGIN ADDING FOR IB
  // set socket buffer sizes
  // increasing buffer sizes for high bandwidth low latency link
  int sndsize = 512000;
  setsockopt(listenSocket, SOL_SOCKET, SO_RCVBUF, (char*)&sndsize, (int)sizeof(sndsize));
  setsockopt(listenSocket, SOL_SOCKET, SO_SNDBUF, (char*)&sndsize, (int)sizeof(sndsize));
  
  int sockbufsize = 0;
  socklen_t sizeb = sizeof(int);
  int err = getsockopt(listenSocket, SOL_SOCKET, SO_RCVBUF, (char*)&sockbufsize, &sizeb);
  printf("Recv socket buffer size: %d\n", sockbufsize);
  
  err = getsockopt(listenSocket, SOL_SOCKET, SO_SNDBUF, (char*)&sockbufsize, &sizeb);
  printf("Send socket buffer size: %d\n", sockbufsize);

  // END ADDING FOR IB


  // TCP NO DELAY
  int flag = 1;
  int result = setsockopt(listenSocket,
			  IPPROTO_TCP,
			  TCP_NODELAY,
			  (char *) &flag,
			  sizeof(int));

  if (result < 0) {
    perror("Could not set TCP_NODELAY sock opt\n");
  }



  if (bind(listenSocket,
           (struct sockaddr *) &serverAddress,
           sizeof(serverAddress)) < 0) {
    cerr << "cannot bind socket";
    exit(1);
  }

  // Wait for connections from clients.
  listen(listenSocket, 5);
 
  while (1) {
    cout << "Waiting for TCP connection on port " << listenPort << " ...\n";
    
    int count = 0;
    // Accept a connection with a client that is requesting one.
    clientAddressLength = sizeof(clientAddress);
    connectSocket = accept(listenSocket,
                           (struct sockaddr *) &clientAddress,
                           &clientAddressLength);
    if (connectSocket < 0) {
      cerr << "cannot accept connection ";
      exit(1);
    }
    
    // Show the IP address of the client.
    cout << "  connected to " << inet_ntoa(clientAddress.sin_addr);

    // Show the client's port number.
    cout << ":" << ntohs(clientAddress.sin_port) << "\n";

    // Read lines from socket
    //memset(line, 0x0, LINE_ARRAY_SIZE);

    char *test = NULL;

    while (recv(connectSocket, &line, 4, 0) > 0) {
      //bytesToSend = atoi(line);
      bytesToSend = (int) line;
      cout << "  --  Receiving request " << count++ << " to send " << bytesToSend << " bytes\n";
      
      if (test == NULL) {
          //test = (char*)malloc(bytesToSend);
          test = (char*)malloc(buffer_size);
      }

      unsigned int rounds = bytesToSend / buffer_size;

      for(unsigned int i = 0; i < rounds; i++) {
//           if (send(connectSocket, test, bytesToSend, 0) < 0)
//               cerr << "Error: cannot send data";      
           if (send(connectSocket, test, buffer_size, 0) < 0)
               cerr << "Error: cannot send data";      
      }
    }

    if (test != NULL) 
      free(test);

    close(connectSocket);

  }
}
