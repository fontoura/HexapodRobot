/*
 * stream.socket.h
 *
 *  Created on: 27/10/2012
 *      Author: Felipe Michels Fontoura
 */

#ifndef STREAM_SOCKET_H_
#define STREAM_SOCKET_H_

#include "base.h"
#include "stream.h"

namespace stream
{
	namespace socket
	{
		/*
		 * Classe representante de uma stream de socket.
		 */
		class TCPSocketStream :
			public virtual stream::Stream
		{
			public:
				TCPSocketStream();
				virtual ~TCPSocketStream();
		};

		/**
		 * Classe representante de um socket de servidor.
		 */
		class TCPServerSocket :
			public virtual base::Object
		{
			protected:
				uint32_t m_port;
			public:
				TCPServerSocket(uint32_t port);
				virtual ~TCPServerSocket();
				virtual TCPSocketStream* accept() = 0;
				virtual bool close() = 0;
				static TCPServerSocket* create(uint32_t port);
		};

		void initSocket();

		void finalizeSocket();

	}
}
#endif /* STREAM_SOCKET_H_ */
