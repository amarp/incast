#include <netdb.h>
#include <netinet/in.h>
#include <unistd.h>
#include <iostream>
#include <fstream>
#include <pthread.h>
#include <time.h>
#include <arpa/inet.h>
#include <sys/time.h>
#include <netinet/tcp.h>

#define MAX_SERVERS 128
#define MAX_SETTINGS_LINE 100
#define MAX_MSG 32
#define LINE_ARRAY_SIZE (MAX_MSG + 1)
extern int h_errno;




using namespace std;

int main(int argc, char *argv[])
{

    char server[MAX_SERVERS][MAX_SETTINGS_LINE];
    int serverNum = 0;
    unsigned short int serverPort;
    unsigned int stripeUnit;
    unsigned short int serverRequestUnit;
    unsigned short int blocks;

    //unsigned long timeElapsed = 0;
    unsigned long timeStart;
    unsigned long long totalBytesReceived = 0;

    // Verify and Copy over command line arguments to variables
    if (argc != 7) { 
      //cout << "Usage: ./client.cc numServers [serverName ...] serverPort stripeUnit serverRequestUnit blocks" << endl;
      cout << "Usage: ./client.cc numServers serverListFileName serverPort stripeUnit serverRequestUnit blocks" << endl;
      exit(1);
    }

    serverNum = atoi(argv[1]);

    char* serverListFileName = argv[2];

    if (serverListFileName) {
        int i = 0;
        fstream fList(serverListFileName, ios::in); 
        while(!fList.eof()) {
	    string line;
            getline(fList, line);
	    strncpy(server[i], line.c_str(), strlen(line.c_str()) + 1);
            cout << server[i] << endl;
            i++;
        }
    }
    //for (int i = 0; i < serverNum; i++) {
    //  strncpy(server[i], argv[i+2], strlen(argv[i+2]));
    //}

    cout << "Number of Servers: " << serverNum << "\n";

    serverPort = atoi(argv[3]);
    stripeUnit = atoi(argv[4]);
    serverRequestUnit = atoi(argv[5]);
    blocks = atoi(argv[6]);
    
    cout << "Port: " << serverPort << endl;
    cout << "Stripe Unit: " << stripeUnit << endl;
    cout << "Server Request Unit Size Multiple: " << serverRequestUnit << endl;
    cout << "Blocks: " << blocks << endl;
    
    // Settings file has been read, so now set up TCP connections
    int socketDescriptor[MAX_SERVERS];
    struct sockaddr_in serverAddress[MAX_SERVERS];
    struct hostent *hostInfo[MAX_SERVERS];    
    char bytesReqString[MAX_MSG]; 

    // From each server we make a data request for
    // (stripe unit size) * (server request unit size multiple)
    // and copy this into a buf string to send to each server
    unsigned long long bytesRequested = stripeUnit * serverRequestUnit;    

    sprintf(bytesReqString, "%d", bytesRequested); 

    char * buf = (char*) malloc((bytesRequested+1));
    
    //printf("BytesRequested: %s, %d", bytesReqString, bytesRequested);
    // Get hostent structure information for later 
    for (int i = 0; i < serverNum; i++)
    {
        struct hostent *temp;
        hostInfo[i] = new struct hostent();
        //hostInfo[i] = (struct hostent*) malloc(sizeof(struct hostent)) ;
	//cout << "Amar:: entering gethostbyname" << endl;
        temp = gethostbyname(server[i]);
	//cout << "Amar:: gethostbyname done!" << endl;
        if (temp == NULL) {
            cout << "SERVER[i]: " << server[i] << endl;
            cout << "ERROR: " << h_errno << endl;
            exit(1);
        }
        else {

	//cout << " .. " << inet_ntoa(*((struct in_addr *)temp->h_addr)) << endl;	
 
	//cout << "Amar:: before memcpy!" << endl;
	memcpy(hostInfo[i], temp, sizeof(struct hostent));
	//cout << "Amar:: after memcpy!" << endl;
	bcopy(temp->h_addr, (struct in_addr *)&(serverAddress[i].sin_addr), temp->h_length);
	//cout << "Amar:: after bcopy!" << endl;

	//memcpy((hostInfo[i]->h_addr), (temp->h_addr), sizeof(struct in_addr));
	//memcpy((hostInfo[i]->h_addr), (temp->h_addr), sizeof(int));

	
	cout << "Host: " << server[i] << endl;
        if (hostInfo[i] == NULL) {
            cout << "problem interpreting host: " << server[i] << "\n";
            exit(1);
        }
        }
    }
    
    // Set up file descriptors for select callbacks
    int fdmax = -1;
    fd_set readset;
    fd_set master;

    FD_ZERO(&readset);
    FD_ZERO(&master);

    // Create a TCP socket and open Connection with every server
    for (int i = 0; i < serverNum; i++) {
	socketDescriptor[i] = socket(AF_INET, SOCK_STREAM, 0);
	fdmax = max(fdmax, socketDescriptor[i]);
	


	// BEGIN ADDING FOR IB
	// increasing buffer sizes for high bandwidth low latency links
	int sndsize = 512000;

	setsockopt(socketDescriptor[i], SOL_SOCKET, SO_RCVBUF, (char*)&sndsize, (int)sizeof(sndsize));
	setsockopt(socketDescriptor[i], SOL_SOCKET, SO_SNDBUF, (char*)&sndsize, (int)sizeof(sndsize));

	int sockbufsize = 0;
	socklen_t sizeb = sizeof(int);
	int err = getsockopt(socketDescriptor[i], SOL_SOCKET, SO_RCVBUF, (char*)&sockbufsize, &sizeb);
	printf("Recv socket buffer size: %d\n", sockbufsize);
	
	err = getsockopt(socketDescriptor[i], SOL_SOCKET, SO_SNDBUF, (char*)&sockbufsize, &sizeb);
        printf("Send socket buffer size: %d\n", sockbufsize);
	
	// END ADDING FOR IB


	// TCP NO DELAY
	int flag = 1;
	int result = setsockopt(socketDescriptor[i],
				IPPROTO_TCP,
				TCP_NODELAY,
				(char *) &flag,
				sizeof(int));
	
	if (result < 0) {
	  perror("Could not set TCP_NODELAY sock opt\n");
	}




	
	//cout << " ...... " << inet_ntoa(*((struct in_addr*)hostInfo[i]->h_addr)) << endl;

	if (socketDescriptor[i] < 0) {
	  cerr << "cannot create socket\n";
	  exit(1);
	}        
        
	serverAddress[i].sin_family = hostInfo[i]->h_addrtype;
	

	//serverAddress[i].sin_addr = *((struct in_addr *)hostInfo[i]->h_addr);
	
	serverAddress[i].sin_port = htons(serverPort);

	//cout << hostInfo[i] << endl;
	//cout << inet_ntoa(*((struct in_addr *)hostInfo[i]->h_addr)) << endl;
	//cout << inet_ntoa(serverAddress[i].sin_addr) << endl;
	
	//cout << &serverAddress[i] << endl;

	if (connect(socketDescriptor[i],
		    (struct sockaddr *) &serverAddress[i],
		    sizeof(serverAddress[i])) < 0) {
	  cerr << "cannot connect\n";
	  exit(1);
	}
	FD_SET(socketDescriptor[i], &master);
	
    }
    

    struct timeval *Tps, *Tpf;
    Tps = (struct timeval*) malloc(sizeof(struct timeval));
    Tpf = (struct timeval*) malloc(sizeof(struct timeval));
    gettimeofday (Tps, NULL);
         

    long last = 0;

    int numBlocksReceived = 0;
    int run = 1;

    while (run == 1) {
      
      // Make request for data from every server 
      // Also keep track of time and throughput stats
      unsigned long long totalAmountReceived = 0;
      unsigned long long totalAmountRequested = 0;
      unsigned int amountReceived = 0;    
      
      
      
      for (int i = 0; i < serverNum; i++) {
	cout << "Sending request to Server " << i << " for " << bytesRequested << " bytes for block number " << numBlocksReceived << "\n";
	unsigned int bytesSent;
	//	if ((bytesSent = send(socketDescriptor[i], bytesReqString, LINE_ARRAY_SIZE, 0)) < 0) {
	if ((bytesSent = send(socketDescriptor[i], &bytesRequested, sizeof(int), 0)) < 0) {
	  cerr << "cannot send data " << " " << bytesSent << endl;;
	  perror("Error: ");
	  close(socketDescriptor[i]);
	  exit(1);
	}
	
	totalAmountRequested += bytesRequested;      
	

      }

      memset(buf, 0x0, LINE_ARRAY_SIZE);
    

      /* BEGIN SELECT LOOP CODE */ 
      struct timeval tv;
      tv.tv_sec = 1;
      tv.tv_usec = 0;
      
      bool allDataReceived = false;
      
      while (!allDataReceived) {
	
	readset = master;
	
	if (select(fdmax+1, &readset, NULL, NULL, &tv) == -1) {
	  perror("select");
	  exit(1);
	}

        // Old code for fixed run time
	/*
	// check time!
	if (timeElapsed >= runTimeInSec) {
	  run = 0;
	  break;
	}
	*/
	
	for (int i = 0; i < serverNum; i++) {	  
	  if (FD_ISSET(socketDescriptor[i], &readset)) {
	    // We have something to receive.
	    if ((amountReceived = recv(socketDescriptor[i], buf, (bytesRequested+1), 0)) < 0) {
	      cerr << "didn't get response from server?";
	      close(socketDescriptor[i]);
	      exit(1);
	    }
	    
	    if (amountReceived == 0) {
	      // Closed connection
	      printf("closed connection.");
	      close(socketDescriptor[i]);
	      FD_CLR(socketDescriptor[i], &master);	      
	    } 
	    
	    totalAmountReceived += amountReceived;
	    	    
	    //cout << "Server " << i << " Returned: " << amountReceived << " bytes\n";   
	    //cout << "Time: " << timeElapsed << " seconds." << endl; 
	  }   
	}
	
	if (totalAmountReceived >= totalAmountRequested) {
	  
	  //this should never happen
	  if (totalAmountReceived > totalAmountRequested) {
	    cerr << "Received too much data";
	  }

	  allDataReceived = true;
	  totalBytesReceived += totalAmountReceived;

	  numBlocksReceived++;

	  gettimeofday (Tpf, NULL);
	  long ttim = (Tpf->tv_sec-Tps->tv_sec)*1000000 + Tpf->tv_usec-Tps->tv_usec;


          long temp = ttim - last;
          last = ttim;
          ttim = temp;  
                    	 
	  printf("CurrTime (usec): %ld\n", ttim);

	  if (numBlocksReceived == blocks) {
	    run = 0;
	    gettimeofday (Tpf, NULL);
	    //timeElapsed = Tpf->tv_sec - Tps->tv_sec;	    
	    break;
	  }
	}
      }
    
    }

    // Run over, clean up memory and close sockets.
    for (int i = 0; i < serverNum; i++) {
      close(socketDescriptor[i]);
      free(hostInfo[i]);
    }
    free(buf);	  

    // Print throughput statistics    
    //cout << Tps->tv_sec << endl;
    //cout << Tpf->tv_sec << endl;
    //cout << Tps->tv_usec << endl;
    //cout << Tpf -> tv_usec << endl;
    long totalTimeInMicroseconds = (Tpf->tv_sec-Tps->tv_sec)*1000000 + Tpf->tv_usec-Tps->tv_usec;
    printf("Total Time (usec): %ld\n", totalTimeInMicroseconds);
    cout << "Total Bytes Received: " << totalBytesReceived << endl;    
    float goodput = ((float)totalBytesReceived * 8 / totalTimeInMicroseconds);
    cout << "Goodput: " << goodput << "Mbps" << endl;

    return 0;
}
