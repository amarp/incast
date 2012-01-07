#ifndef ns_incasts_h
#define ns_incasts_h

#include <vector>
#include <iostream>
#include <math.h>
#include <stdio.h>
#include <time.h>

#include "agent.h"
#include "tcpapp.h"
#include "incast_app_data.h"
#include "../tcp/tcp-sink.h"

using namespace std;

class IncastTcpAppServer;

class IncastTcpAppServer;
class IncastTcpAppServerStub;

class IncastTcpAppClient : public TcpApp {
 public:
    IncastTcpAppClient(Agent *tcp, int synch_data_size_in_bytes);
    ~IncastTcpAppClient();

    virtual void send_requests();
    virtual void process_done();
    virtual void process_init();
    virtual void start();
    float startTime_;

 protected:
    virtual int command(int argc, const char*const* argv);
    unsigned int num_dones_;
    vector<IncastTcpAppServerStub *> *dsts_;
    Agent *mytcp;
    int synch_data_size_;
    unsigned int initCount_;
    unsigned int start_;
    
};

class IncastTcpAppServer : public TcpApp {
 protected:
    virtual int command(int argc, const char*const* argv);
    virtual void start() {}
    virtual void stop() {}
    int synch_data_size_;
    unsigned int server_id_;

 public:
    IncastTcpAppServer(Agent *tcp, int synch_data_size_in_bytes);
    ~IncastTcpAppServer();

    // Send data to the next application in the chain
    virtual void send_data(int size, IncastAppData* data) {
        send(size, data);
    }

    virtual void send_done();

    virtual void connect(IncastTcpAppServerStub *dst);

    virtual void process_data(int size, AppData* data);

    virtual void recv(int nbytes) {
        TcpApp::recv(nbytes);
    }

    virtual void send(int nbytes, AppData *data) {
        TcpApp::send(nbytes, data);
    }

    virtual AppData* get_data(int& i, AppData* ad) { 
        return TcpApp::get_data(i, ad);
    }

    virtual void resume() {}

};

class IncastTcpAppServerStub : public TcpApp {
 public:
    IncastTcpAppServerStub(Agent *tcp, Agent *tcp_sink, IncastTcpAppClient *, int synch_data_size_in_bytes);
    ~IncastTcpAppServerStub();
    void set_dest(TcpApp *);
    virtual void process_data(int size, AppData* data);
    virtual void send_init();
    virtual void send_request();
    virtual void recv(int nbytes);

 protected:
    IncastTcpAppClient *itac_;
    Agent *sink_agent;
    int synch_data_size_;
    int recvCallCount;
};

#endif // ns_incasts_h
