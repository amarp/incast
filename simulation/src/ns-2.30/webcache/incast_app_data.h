#ifndef ns_incast_app_data_h
#define ns_incast_app_data_h

#include "ns-process.h"

// Application-level data unit types
enum ControlType {
	// Illegal type
	INCAST_ILLEGAL = -1,

        // 
	INCAST_REQ = 100,
        INCAST_DATA = 200,
        INCAST_DONE = 300
};


// Interface for generic application-level data unit. It should know its 
// size and how to make itself persistent.
class IncastAppData : public AppData {
protected:
        ControlType packet_type_;
        unsigned int src_id_;
	char *buf_;
        int buf_size_;
public:

	IncastAppData(ControlType it, unsigned int sid) : AppData(TCPAPP_STRING) { 
            packet_type_ = it; 
            src_id_ = sid;
            buf_ = NULL;
            buf_size_ = 0;
        }

	IncastAppData(ControlType it, unsigned int sid, int bufSize) : AppData(TCPAPP_STRING) { 
            packet_type_ = it; 
            src_id_ = sid;
	    buf_ = (char *)malloc(sizeof(char) * (bufSize));
            buf_size_ = bufSize;
            for (int i = 0; i < (buf_size_ - 1); i++) {
                buf_[i] = 'a';
            }
            buf_[buf_size_ - 1] = '\0';
        }

	IncastAppData(IncastAppData& d) : AppData(d.type()) { 
            packet_type_ = d.packet_type_;
            buf_size_ = d.buf_size_;
            buf_ = (char *)malloc(sizeof(char) * buf_size_);
            memcpy(buf_, d.buf_, buf_size_); // we copy the \0 too
        }

	virtual ~IncastAppData() {
            delete []buf_;
        }

        //int get_buf_size() { return buf_size_; }

	ControlType get_incast_type() const { return packet_type_; }

        const unsigned int get_src_id() { return src_id_; }

	virtual int size() const {
#ifndef _INCAST_DEBUG
	printf("\t AMAR:: IncastAppData::size() called \n");
#endif //_INCAST_DEBUG
        //return sizeof(IncastAppData) + buf_size_;
            return buf_size_;
        }

	virtual IncastAppData* copy() {
#ifndef _INCAST_DEBUG
            printf("IncastAppData::copy() called !");
#endif //_INCAST_DEBUG
            return new IncastAppData(*this);
	}
};

#endif // ns_incast_app_data_h
