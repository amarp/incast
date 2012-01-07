#include "incast.h"

// IncastTcpAppClient
static class IncastClientCncClass : public TclClass {
public:
    IncastClientCncClass() : TclClass("Application/IncastTcpAppClient") {}
    TclObject* create(int argc, const char*const* argv) {
        if (argc != 6)
            return NULL;
        Agent *tcp = (Agent *)TclObject::lookup(argv[4]);
        int synch_data_size_in_bytes = atoi(argv[5]);
        if (tcp == NULL) 
            return NULL;
        return (new IncastTcpAppClient(tcp, synch_data_size_in_bytes));
    }
} class_incastclientcnc_app;


IncastTcpAppClient::IncastTcpAppClient(Agent *tcp, int synch_data_size_in_bytes) : TcpApp(tcp), num_dones_(0), synch_data_size_(synch_data_size_in_bytes)
{
#ifndef _INCAST_DEBUG
    printf("Creating IncastTcpAppClient \n");
    printf("creating dsts_ \n");
#endif //_INCAST_DEBUG

    dsts_ = new vector<IncastTcpAppServerStub *>();
    start_ = 0;
    initCount_ = 0;
    

#ifndef _INCAST_DEBUG
    printf("\ndone creating dsts_ \n");
    printf("size of dsts_: %d \n", dsts_->size());
#endif //_INCAST_DEBUG
}

IncastTcpAppClient::~IncastTcpAppClient() {
    for(unsigned int x=0; x<dsts_->size(); x++) 
        {
            delete (*dsts_)[x];
	    
        }
    
}

void IncastTcpAppClient::process_done() 
{
    // TODO :: SYNCHRONIZATION
    num_dones_++;
    if (num_dones_ == dsts_->size()) {
        num_dones_ = 0;
        // iterate and send ask the stubs to send reqs out

#ifndef _INCAST_DEBUG
        printf("\t IncastTcpAppClient::process_done() -> got all %d dones \n", dsts_->size());
#endif //_INCAST_DEBUG

        //char c = getchar();
        send_requests();
    }
}

void IncastTcpAppClient::process_init()
{
    if (initCount_ < dsts_->size()) {
	    (*dsts_)[initCount_]->send_init();
    } else {
#ifndef _INCAST_DEBUG
    printf("done setting up all connections at %g\n", Scheduler::instance().clock());
#endif //_INCAST_DEBUG
	send_requests();
    }
    initCount_++;
 
}

void IncastTcpAppClient::send_requests()
{

#ifndef _INCAST_DEBUG
    printf("IncastTcpAppClient::send_requests() -> Sending requests to %d servers...\n", dsts_->size());
#endif //_INCAST_DEBUG

/*
    for(unsigned int x=0; x<dsts_->size(); x++) {
#ifndef _INCAST_DEBUG
        printf("\t sending request %d \n", x);
#endif //_INCAST_DEBUG
        (*dsts_)[x]->send_request();
    }
*/

/*
    for (unsigned int x=0; x<dsts_->size(); x++) {
	int y = (start_ + x) % dsts_->size();
	(*dsts_)[y]->send_request();
    }
    start_ = (start_ + 1) % dsts_->size();
*/
    

    vector<int> *l  = new vector<int>;
    for (int i = 0; i < dsts_->size(); i++) {
        l->push_back(i);
    }

    srand(time(NULL));
    int n = l->size();
    for (int i = 0; i < n; i++) {
        int r = rand() % (n-i);
        int temp;
        temp = (*l)[r];
        (*l)[r] = (*l)[n-i-1];
        (*l)[n-i-1] = temp;
    }

    for (int i = 0; i < n; i++) {
        //        printf("Sending request to server %d\n", (*l)[i]);
        (*dsts_)[(*l)[i]]->send_request();
    }

    delete l;
    
    
}

void IncastTcpAppClient::start() {

#ifndef _INCAST_DEBUG
    printf("IncastTcpAppClient::Starting...\n");
#endif //_INCAST_DEBUG

    //send_requests();
    process_init();
}

int IncastTcpAppClient::command(int argc, const char*const* argv)
{
#ifndef _INCAST_DEBUG
    printf("IncastTcpAppClient::command \n");
#endif //_INCAST_DEBUG

    if (strcmp(argv[1], "connect") == 0) {
        IncastTcpAppServer* dst = (IncastTcpAppServer *)TclObject::lookup(argv[2]);
        Agent* my_tcp_agent = (Agent *)TclObject::lookup(argv[3]);
        TcpSink* my_tcp_sink_agent = (TcpSink *)TclObject::lookup(argv[4]);
        if (dst == NULL) {
	    return (TCL_ERROR);
        }

#ifndef _INCAST_DEBUG
        printf("IncastTcpAppClient::command: %s %s\n", argv[1], argv[2]);
        printf("server = %d \n", dst);
#endif //_INCAST_DEBUG

        // hopefully we get a new tcpagent (sending agent) for each server we need to connect to;
        // use that as the agent
        IncastTcpAppServerStub *stub = new IncastTcpAppServerStub(my_tcp_agent, my_tcp_sink_agent, this, synch_data_size_);
        // set dst (incoming) as the Application we need to talk to
        stub->set_dest(dst);
        dsts_->push_back(stub);
        // ask the server to connect to us - this basically means that he sets his dst to the stub
        dst->connect(stub);
        // the tcp_sink_agent needs to know who to make an upcall to when it gets a packet.
        // the server will connect to this sink agent.
        my_tcp_sink_agent->set_parent(stub);
        return (TCL_OK);
    }
  
    return TcpApp::command(argc, argv);
}
