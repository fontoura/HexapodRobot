/*
 * ChannelThreadBody.h
 *
 *  Created on: 03/12/2012
 */

#ifndef PROTOCOL_CHANNELTHREADBODY_H_
#define PROTOCOL_CHANNELTHREADBODY_H_

#include "../globaldefs.h"
#include "../base/all.h"
#include "../concurrent/managed/all.h"
#include "../concurrent.thread.h"

namespace protocol
{
	class Channel;

	/**
	 * Classe com o corpo de thread de recebimento de um canal de mensagens.
	 */
	class ChannelThreadBody :
		public concurrent::thread::ThreadBody
	{
		_pool_decl(ChannelThreadBody, _POOL_SIZE_FOR_CHANNELS)

		protected:
			/* construtor e destrutor. */
			ChannelThreadBody();
			~ChannelThreadBody();

			/* gerência de memória. */
			void initialize(Channel* channel);
			void finalize();

		public:
			/* factory. */
			static ChannelThreadBody* create(Channel* channel);

		protected:
			/* canal de mensagens à qual esta thread se refere. */
			_strong(Channel) m_channel;

		public:
			/* implementação de ThreadBody. */
			void run();
	};
}

#endif /* PROTOCOL_CHANNELTHREADBODY_H_ */
