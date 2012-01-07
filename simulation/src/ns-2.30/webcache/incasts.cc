#include "incast.h"

// IncastTcpAppServer
static class IncastServerCncClass : public TclClass {
public:
    IncastServerCncClass() : TclClass("Application/IncastTcpAppServer") {}
    TclObject* create(int argc, const char*const* argv) {
        if (argc != 6)
            return NULL;
        Agent *tcp = (Agent *)TclObject::lookup(argv[4]);
        int synch_data_size_in_bytes = atoi(argv[5]);
        if (tcp == NULL) 
            return NULL;
        return (new IncastTcpAppServer(tcp, synch_data_size_in_bytes));
    }
} class_incastservercnc_app;

IncastTcpAppServer::IncastTcpAppServer(Agent *tcp, int synch_data_size_in_bytes) : TcpApp(tcp), synch_data_size_(synch_data_size_in_bytes)
{
    srand((int)this);
    server_id_ = (unsigned int)rand();

#ifndef _INCAST_DEBUG
    printf("Creating IncastTcpAppServer %d \n", server_id_);
#endif //_INCAST_DEBUG

}

IncastTcpAppServer::~IncastTcpAppServer() {

}

// called by TcpApp::recv
void IncastTcpAppServer::process_data(int size, AppData* data) 
{
    IncastAppData *dataCast = (IncastAppData *) data;

#ifndef _INCAST_DEBUG
    printf("IncastTcpAppServer::process_data() called\n");
#endif //_INCAST_DEBUG

    if (dataCast == NULL)
        return;
    // XXX Default behavior:
    if (target()) {
        cout << "IncastTcpAppServer :: TARGET !!!! GO SHOP THERE ..." << endl;
        send_data(size, dataCast);
    }
    else if (dataCast->type() == TCPAPP_STRING) {
        if (dataCast->get_incast_type() == INCAST_REQ) {

#ifndef _INCAST_DEBUG
            printf("\t IncastTcpAppServer::process_data() -> Server got a request, sending out data packets \n");
#endif //_INCAST_DEBUG

            IncastAppData *iap = new IncastAppData(INCAST_DATA, this->server_id_, synch_data_size_);

#ifndef _INCAST_DEBUG
            printf("\t IncastTcpAppServer::process_data() -> synch_data_size_: %d, data_packet_size = %d \n", synch_data_size_, iap->size());
#endif //_INCAST_DEBUG

            send_data(iap->size(), iap);

#ifndef _INCAST_DEBUG
            printf("\t IncastTcpAppServer::process_data() ->  sent data packets \n");
#endif //_INCAST_DEBUG

            //send_done();
            //printf("\t IncastTcpAppServer:: sent done packet \n");
        }
	else if (dataCast->get_incast_type() == INCAST_DONE) {
	    IncastAppData *iap = new IncastAppData(INCAST_DONE, this->server_id_, 100);
	    send_data(iap->size(), iap);
	}
        else {
            cout << "IncastTcpAppServer :: INVALID PACKET RECEIVED ON CLIENT - Incast ControlPacket Type " << dataCast->get_incast_type() << endl;
        }
    }
    else {
        cout << "IncastTcpAppServer :: Unrecognized packet type." << endl;
    }
}

void IncastTcpAppServer::send_done()
{
    IncastAppData *iap = new IncastAppData(INCAST_DONE, this->server_id_, 10);
    // we don't care what the size of the payload is going to be
    send(iap->size(), iap);
}

int IncastTcpAppServer::command(int argc, const char*const* argv)
{
#ifndef _INCAST_DEBUG
    printf("IncastTcpAppServer::command() \n");
#endif //_INCAST_DEBUG

    return TCL_ERROR;
}

void IncastTcpAppServer::connect(IncastTcpAppServerStub *dst)
{ 
#ifndef _INCAST_DEBUG
    printf("IncastTcpAppServer::connect() \n");
#endif //_INCAST_DEBUG

    dst_ = dst; 
}
