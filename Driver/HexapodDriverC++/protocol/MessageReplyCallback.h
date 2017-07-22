/*
 * MessageReplyCallback.h
 *
 *  Created on: 08/12/2012
 */

#ifndef PROTOCOL_MESSAGEREPLYCALLBACK_H_
#define PROTOCOL_MESSAGEREPLYCALLBACK_H_

#include "../globaldefs.h"
#include "../base/all.h"
#include "../concurrent/managed/all.h"

namespace protocol
{
	class Message;

	/**
	 * Classe que trata o recebimento de uma resposta pelo fluxo de mensagens.
	 */
	class MessageReplyCallback :
		public virtual base::Object
	{
		public:
			/* destrutor virtual para permitir herança. */
			~MessageReplyCallback();

			/* trata o recebimento de uma resposta pelo fluxo de mensagens. */
			virtual void onReply(_strong(Message)& request, _strong(Message)& reply, int error) = 0;
	};
}

#endif /* PROTOCOL_MESSAGEREPLYCALLBACK_H_ */
