/*
 * ChannelClosedCallback.h
 *
 *  Created on: 03/12/2012
 */

#ifndef PROTOCOL_CHANNELCLOSEDCALLBACK_H_
#define PROTOCOL_CHANNELCLOSEDCALLBACK_H_

#include "../globaldefs.h"
#include "../base.h"
#include "../concurrent.managed.h"

namespace protocol
{
	class Channel;

	/**
	 * Classe que trata o fechamento de um canal.
	 */
	class ChannelClosedCallback :
		public virtual base::Object
	{
		public:
			/* destrutor virtual para permitir herança. */
			virtual ~ChannelClosedCallback();

			/* trata o fechamento do canal. */
			virtual void onChannelClosed(_strong(Channel)& channel) = 0;
	};
}

#endif /* PROTOCOL_CHANNELCLOSEDCALLBACK_H_ */
