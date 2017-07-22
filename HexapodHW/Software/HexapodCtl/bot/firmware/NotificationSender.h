/*
 * NotificationSender.h
 *
 *  Created on: 05/04/2013
 */

#ifndef BOT_FIRMWARE_NOTIFICATIONSENDER_H_
#define BOT_FIRMWARE_NOTIFICATIONSENDER_H_

#include "../../globaldefs.h"
#include "../../base/all.h"
#include "../../concurrent/managed/all.h"
#include "../../protocol/Message.h"
#include "../../protocol/Flow.h"
#include "../../protocol/MessageReplyCallback.h"

namespace bot
{
	namespace firmware
	{
		class NotificationSender :
			public protocol::MessageReplyCallback
		{
			_pool_decl(NotificationSender, POOLSIZE_bot_firmware_NotificationSender)

			protected:
				/* construtor e destrutor. */
				NotificationSender();
				~NotificationSender();

				/* gerência de memória. */
				void initialize(int tries, _strong(protocol::Flow)& flow, _strong(protocol::MessageReplyCallback)& callback, long timeout);
				void finalize();

			public:
				/* factory. */
				static NotificationSender* create(int tries, _strong(protocol::Flow)& flow, _strong(protocol::MessageReplyCallback)& callback, long timeout);

			private:
				_strong(protocol::Flow) m_flow;
				_strong(protocol::MessageReplyCallback) m_callback;
				int m_remaining;
				long m_timeout;

			protected:
				/* implementação de MessageReplyCallback. */
				void onReply(_strong(protocol::Message)& request, _strong(protocol::Message)& reply, int error);

			public:
				void send(_strong(protocol::Message)& message);

		};
	}
}

#endif /* BOT_FIRMWARE_NOTIFICATIONSENDER_H_ */
