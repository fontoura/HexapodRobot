/*
 * ChannelMessageCallback.h
 *
 *  Created on: 03/12/2012
 */

#ifndef PROTOCOL_CHANNELMESSAGECALLBACK_H_
#define PROTOCOL_CHANNELMESSAGECALLBACK_H_

#include "../globaldefs.h"
#include "../base/all.h"
#include "../concurrent/managed/all.h"

namespace protocol
{
	class Message;

	/**
	 * Classe que trata o recebimento de uma mensagem por um canal.
	 */
	class ChannelMessageCallback :
		public virtual base::Object
	{
		public:
			/* destrutor virtual para permitir herança. */
			virtual ~ChannelMessageCallback();

			/* trata o recebimento de uma mensagens pelo canal. */
			virtual void onMessage(_strong(Message)& message) = 0;
	};
}

#endif /* PROTOCOL_CHANNELMESSAGECALLBACK_H_ */
