/*
 * MessageRequestCallback.h
 *
 *  Created on: 08/12/2012
 */

#ifndef PROTOCOL_MESSAGEREQUESTCALLBACK_H_
#define PROTOCOL_MESSAGEREQUESTCALLBACK_H_

#include "../globaldefs.h"
#include "../base.h"
#include "../concurrent.managed.h"

namespace protocol
{
	class Message;
	class FlowReplier;

	/**
	 * Classe que trata o recebimento de uma requisição pelo fluxo de mensagens.
	 */
	class MessageRequestCallback :
		public virtual base::Object
	{
		public:
			/* destrutor virtual para permitir herança. */
			~MessageRequestCallback();

			/* trata o recebimento de uma requisição pelo fluxo de mensagens. */
			virtual void onRequest(_strong(Message)& request, _strong(FlowReplier)& replier) = 0;
	};
}

#endif /* PROTOCOL_MESSAGEREQUESTCALLBACK_H_ */
