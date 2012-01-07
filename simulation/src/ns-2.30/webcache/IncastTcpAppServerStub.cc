#include "incast.h"

IncastTcpAppServerStub::IncastTcpAppServerStub(Agent *tcp, Agent *tcp_sink, IncastTcpAppClient *itac, int synch_data_size_in_bytes) : TcpApp(tcp), synch_data_size_(synch_data_size_in_bytes)
{
    sink_agent = tcp_sink;
    itac_ = itac;
    recvCallCount = 0;
}

IncastTcpAppServerStub::~IncastTcpAppServerStub() {
}

void IncastTcpAppServerStub::set_dest(TcpApp *dst) {
        dst_ = dst;
}

void IncastTcpAppServerStub::recv(int size)
{
#ifndef _INCAST_DEBUG
	printf("IncastTcpAppServerStub:: recv() starts - Got a packet! \n");
#endif //_INCAST_DEBUG

	if (recvCallCount < 1) {
	    recvCallCount++;
	}
	else if (recvCallCount == 1) {
	    curdata_ = dst_->rcvr_retrieve_data();
	    if (curdata_ != 0) {
		process_data(curdata_->size(), curdata_->data());
		delete curdata_;
		curdata_ = NULL;
	    }   
	    recvCallCount++;
	    return;
	}


        // wait for ceil(S/1040) packets before making the calback - 
        /* send() of "one way" tcp sending agents behave in a funny way.
           If you send data that is less than 1000 bytes, the agents ends-up sending 1040 bytes. If you send data more than 1000 bytes (let us say X) - the agents end-up sending ceil(X/1000) packets each 1040 bytes.
           So effectively TCP is more like UDP here (packet based, instead of stream based). Wonder why they did that.
        */

        // thresh = ceil( (S + 64) /1040 )
        // complex math! we rule!
        //int thresh = ceil( ((double)synch_data_size_) / (1040 - 24) );
        int thresh = ceil( ((double)synch_data_size_) / (1040 - 40) );
        curbytes_ += size;

#ifndef _INCAST_DEBUG
        printf("curbytes: %u, size: %u \n", curbytes_, size);
#endif //_INCAST_DEBUG

        //#ifndef _INCAST_DEBUG
        //printf("IncastTcpAppServerStub:: recv() -> thresh = %d,  curbytes_-40/1040 = %.20f. \n", thresh, (double)((curbytes_-40)/1040));
        //#endif //_INCAST_DEBUG

        //if ( ((curbytes_-40)/1040) >= thresh) {
        if ( (curbytes_/1040) >= thresh ) {
#ifndef _INCAST_DEBUG
            printf("IncastTcpAppServerStub:: recv() -> before detach\n");
#endif //_INCAST_DEBUG

            curdata_ = dst_->rcvr_retrieve_data();

#ifndef _INCAST_DEBUG
            printf("IncastTcpAppServerStub:: recv() -> after detach\n");
#endif //_INCAST_DEBUG

            if (curdata_ == 0) {
                printf("\t IncastTcpAppServerStub::recv() -> BAD_BAD !!! BAD_BAD !!! BAD_BAD !!! BAD_BAD !!!  BAD_BAD !!! \n");
		fprintf(stderr, "[%g] %s receives a packet but no callback!\n",
			Scheduler::instance().clock(), name_);
            }
            else if (curdata_ != 0) {
#ifndef _INCAST_DEBUG
                printf("IncastTcpAppServerStub:: recv() -> Got %d packets with a total of %d bytes. \n", thresh, thresh*1040);
                printf("IncastTcpAppServerStub:: recv() -> data_bytes = %d \n", curdata_->bytes());
#endif //_INCAST_DEBUG

                process_data(curdata_->size(), curdata_->data());
                // Then cleanup this data transmission
                delete curdata_;
                curdata_ = NULL;
                curbytes_ = 0;
            }
        }
        else {
#ifndef _INCAST_DEBUG
            printf("\t IncastTcpAppServerStub:: recv() -> Gather more moss !!! \n");
#endif //_INCAST_DEBUG
        }
}

void IncastTcpAppServerStub::process_data(int size, AppData* data) {

#ifndef _INCAST_DEBUG
    printf("IncastTcpAppServerStub::process_data() called \n");
#endif //_INCAST_DEBUG

    IncastAppData *dataCast = (IncastAppData *) data;
    if (dataCast == NULL)
        return;
    // XXX Default behavior:
    if (target()) {
        cout << "IncastTcpAppServerStub :: TARGET !!!! GO SHOP THERE ..." << endl;
        send_data(size, dataCast);
    }
    else if (dataCast->type() == TCPAPP_STRING) {
        if (dataCast->get_incast_type() == INCAST_DATA) {
            // who cares about the data?
#ifndef _INCAST_DEBUG
            printf("\t DATA !!! DATA !!! DATA !!! DATA !!!  DATA !!! \n");
            printf("\t Got callback for data of size (including app header) = %d. Data from %d\n", size, dataCast->get_src_id());
#endif //_INCAST_DEBUG
            itac_->process_done();
        }
        
        else if (dataCast->get_incast_type() == INCAST_DONE) {
#ifndef _INCAST_DEBUG
            printf("\t DONE !!! DONE !!! DONE !!! DONE !!!  DONE !!! \n");
            printf("\t IncastTcpAppServer :: Got done packet from %d \n", dataCast->get_src_id());
#endif //_INCAST_DEBUG
            itac_->process_init();
        }
        
        else {
            printf("\t INVALID !!! INVALID !!! INVALID !!! INVALID !!!  INVALID !!! \n");
            cout << "\t IncastTcpAppServer :: INVALID PACKET RECEIVED ON CLIENT - Incast ControlPacket Type " << dataCast->get_incast_type() << endl;
        }
    }
    else {
        printf("\t UNRECOGNIZED !!! UNRECOGNIZED !!! UNRECOGNIZED !!! UNRECOGNIZED !!!  UNRECOGNIZED !!! \n");
        cout << "\t IncastTcpAppClient :: Unrecognized packet type." << endl;
    }
}

void IncastTcpAppServerStub::send_request() {

#ifndef _INCAST_DEBUG
    printf("================================================================================ \n");
    printf("IncastTcpAppServerStub::send_requests() -> Sending request \n");
#endif //_INCAST_DEBUG

    IncastAppData *iad = new IncastAppData(INCAST_REQ, 0, 100);
    send(iad->size(), iad);

#ifndef _INCAST_DEBUG
    printf("IncastTcpAppServerStub::send_requests() -> Done sending request \n");
    printf("================================================================================ \n");
#endif //_INCAST_DEBUG
}

void IncastTcpAppServerStub::send_init() {

    IncastAppData *iad = new IncastAppData(INCAST_DONE, 0, 100);
    send(iad->size(), iad);
}
