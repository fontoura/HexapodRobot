/*
 * FlowReplier.h
 *
 *  Created on: 08/12/2012
 */

#ifndef PROTOCOL_FLOWREPLIER_H_
#define PROTOCOL_FLOWREPLIER_H_

#include "../globaldefs.h"
#include "../base/all.h"
#include "../concurrent/managed/all.h"

namespace protocol
{
	class Channel;
	class Message;

	/**
	 * Classe que envia através de um fluxo a resposta a uma certa mensagem.
	 */
	class FlowReplier :
		public base::Object
	{
		_pool_decl(FlowReplier, _POOL_SIZE_FOR_REPLIERS)

		protected:
			/* construtor e destrutor. */
			FlowReplier();
			~FlowReplier();

			/* gerência de memória. */
			void initialize(int id, _strong(Channel)& channel);
			void finalize();

		public:
			/* factory. */
			static FlowReplier* create(int id, _strong(Channel)& channel);

		protected:
			int m_id;
			_weak(Channel) m_channel;

		public:
			/* envia a resposta pelo fluxo de mensagens. */
			void sendReply(_strong(Message)& reply);
	};
}

#endif /* PROTOCOL_FLOWREPLIER_H_ */
