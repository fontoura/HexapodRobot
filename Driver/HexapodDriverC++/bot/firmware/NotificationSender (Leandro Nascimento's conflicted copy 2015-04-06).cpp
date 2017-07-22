/*
 * NotificationSender.cpp
 *
 *  Created on: 05/04/2013
 */

#include "../../bot/firmware/fw_defines.h"
#include "../../bot/firmware/NotificationSender.h"

using namespace base;

/* macros para debug */
#ifdef DEBUG_bot_firmware_NotificationSender
#include <iostream>
#define DEBUG(v1) std::cout<<(v1)<<std::endl
#define DEBUG2(v1,v2) std::cout<<(v1)<<(v2)<<std::endl
#define DEBUG3(v1,v2,v3) std::cout<<(v1)<<(v2)<<(v3)<<std::endl
#define DEBUG4(v1,v2,v3,v4) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<std::endl
#define DEBUG5(v1,v2,v3,v4,v5) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<(v5)<<std::endl
#else /* ifndef DEBUG_bot_firmware_NotificationSender */
#define DEBUG(v1) {}
#define DEBUG2(v1,v2) {}
#define DEBUG3(v1,v2,v3) {}
#define DEBUG4(v1,v2,v3,v4) {}
#define DEBUG5(v1,v2,v3,v4,v5) {}
#endif /* DEBUG_bot_firmware_NotificationSender */

namespace bot
{
	namespace firmware
	{
		/* pool de objetos. */
		ObjectPool<NotificationSender, POOLSIZE_bot_firmware_NotificationSender> NotificationSender::m_pool;

		/* construtor e destrutor. */
		NotificationSender::NotificationSender()
		{
			m_remaining = 0;
			m_timeout = 0;
			DEBUG("NotificationSender alocado!");
		}

		NotificationSender::~NotificationSender()
		{
			m_flow = NULL;
			m_callback = NULL;
			DEBUG("UartManager apagado!");
		}

		/* gerência de memória. */
		void NotificationSender::initialize(int tries, _strong(protocol::Flow)& flow, _strong(protocol::MessageReplyCallback)& callback, long timeout)
		{
			DEBUG("Inicializando NotificationSender...");
			m_flow = flow;
			m_callback = callback;
			m_remaining = tries;
			m_timeout = timeout;
		}

		void NotificationSender::finalize()
		{
			DEBUG("Finalizando NotificationSender...");
			m_flow = NULL;
			m_callback = NULL;
			Object::beforeRecycle();
			NotificationSender::m_pool.recycle(this);
		}

		/* factory. */
		NotificationSender* NotificationSender::create(int tries, _strong(protocol::Flow)& flow, _strong(protocol::MessageReplyCallback)& callback, long timeout)
		{
			DEBUG("Criando NotificationSender...");
			NotificationSender* notificationSender = NotificationSender::m_pool.obtain();
			if (notificationSender != NULL)
			{
				notificationSender->initialize(tries, flow, callback, timeout);
			}
			return notificationSender;
		}

		/* implementação de MessageReplyCallback. */
		void NotificationSender::onReply(_strong(protocol::Message)& request, _strong(protocol::Message)& reply, int error)
		{
			if (reply != NULL)
			{
				m_callback->onReply(request, reply, error);
				m_callback = NULL;
				m_flow = NULL;
			}
			else
			{
				if (m_remaining > 0)
				{
					m_remaining --;
					if (m_remaining > 0)
					{
						this->send(request);
					}
				}
			}
		}

		void NotificationSender::send(_strong(protocol::Message)& message)
		{
			_strong(protocol::MessageReplyCallback) _this = this;
			m_flow->send(message, _this, m_timeout);
		}
	}
}
