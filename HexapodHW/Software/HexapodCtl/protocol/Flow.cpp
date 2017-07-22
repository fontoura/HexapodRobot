/*
 * Flow.cpp
 *
 *  Created on: 08/12/2012
 */

#include "../protocol/Message.h"
#include "../protocol/Channel.h"
#include "../protocol/ChannelMessageCallback.h"
#include "../protocol/ChannelClosedCallback.h"
#include "../protocol/Flow.h"
#include "../protocol/FlowReplier.h"
#include "../protocol/FlowClosedCallback.h"
#include "../protocol/FlowThreadBody.h"
#include "../protocol/MessageReplyCallback.h"
#include "../protocol/MessageRequestCallback.h"
#include "../protocol/MessageNode.h"

using namespace concurrent::thread;
using namespace concurrent::semaphore;
using namespace concurrent::managed;
using namespace concurrent::time;

namespace protocol
{
	_pool_inst(Flow, _POOL_SIZE_FOR_FLOWS)

	/* construtor e destrutor. */
	Flow::Flow()
	{
		m_lastId = 0;
		m_minimalTimeout = 0;
	}

	Flow::~Flow()
	{
	}

	/* gerência de memória. */
	void Flow::initialize(_strong(Channel)& channel, unsigned long minimalTimeout)
	{
		_strong(ChannelMessageCallback) handler = this;
		_strong(ChannelClosedCallback) closedHandler = this;
		m_channel = channel;
		channel->setMessageCallback(handler);
		channel->setClosedCallback(closedHandler);
		m_minimalTimeout = minimalTimeout;
		m_mutex = Semaphore::create(1, 1);
		m_timer = Stoptimer::create();
		m_lastId = 0;
	}

	void Flow::finalize()
	{
		m_mutex = NULL;
		m_waitingReply = NULL;
		m_timeoutThread = NULL;
		m_channel = NULL;
		m_timer = NULL;
		m_requestCallback = NULL;
		m_closedHandler = NULL;
		_del_inst(Flow);
	}

	/* factory. */
	Flow* Flow::create(_strong(Channel)& channel, unsigned long minimalTimeout)
	{
		_new_inst(Flow, flow);
		flow->initialize(channel, minimalTimeout);
		return flow;
	}

	/* realiza o envio de uma requisição pelo fluxo. */
	void Flow::send(_strong(Message)& message, _strong(MessageReplyCallback)& callback, unsigned long timeout)
	{
		if (timeout < m_minimalTimeout)
		{
			timeout = m_minimalTimeout;
		}
		m_mutex->down();

		// cria os nós para navegar na lista encadeada de mensagens.
		_strong(MessageNode) previous = NULL;
		_strong(MessageNode) node = m_waitingReply;

		// obtém um identificador único para a mensagem.
		m_lastId++;
		message->setId(m_lastId);
		bool sent = m_channel->send(message);

		// verifica se enviou.
		if (sent)
		{
			// cria o nó com a mensagem por enviar.
			_strong(MessageNode) newNode = MessageNode::create();
			timeout += m_timer->getMilliseconds();
			newNode->message = message;
			newNode->callback = callback;
			newNode->absoluteTimeout = timeout;

			// procura a posição adequada e insere o nó.
			while (node != NULL)
			{
				if (node->absoluteTimeout > timeout)
				{
					break;
				}
				previous = node;
				node = node->next;
			}
			if (previous == NULL)
			{
				newNode->next = m_waitingReply;
				m_waitingReply = newNode;
			}
			else
			{
				newNode->next = node;
				previous->next = newNode;
			}

			// cria a thread de timeout, se não existir.
			if (m_timeoutThread == NULL)
			{
				m_timeoutThread = Thread::create(FlowThreadBody::create(this));
#if __NIOS2__
				m_timeoutThread->setPriority(HighThreadPriority);
#endif /* __NIOS2__ */
				m_timeoutThread->start();
			}
		}
		else
		{
			// não enviou, então dispara callback.
			_strong(Message) nullMessage;
			callback->onReply(message, nullMessage, 1);
		}

		m_mutex->up();
	}

	/* inicia a operação do fluxo, assumindo que o canal esteja em funcionamento. */
	void Flow::start()
	{
		m_channel->start();
	}

	/* para o fluxo. */
	void Flow::stop()
	{
		m_channel->stop();
	}

	/* verifica se o fluxo está em execução. */
	bool Flow::isOpen()
	{
		return m_channel->isRunning();
	}

	/* getter e setter do objeto com callback de recebimento de requisição. */
	void Flow::setRequestCallback(_strong(MessageRequestCallback)& callback)
	{
		m_requestCallback = callback;
	}

	_strong(MessageRequestCallback)& Flow::getRequestCallback()
	{
		return m_requestCallback;
	}

	/* getter e setter do objeto com callback de fechamento de fluxo. */
	void Flow::setClosedCallback(_strong(FlowClosedCallback)& callback)
	{
		m_closedHandler = callback;
	}

	_strong(FlowClosedCallback)& Flow::getClosedCallback()
	{
		return m_closedHandler;
	}

	/* implementação de ChannelMessageCallback. */
	void Flow::onMessage(_strong(Message)& message)
	{
		if (0 != (message->getType() & 0x01))
		{
			// mensagens com ID ímpar são reply.
			m_mutex->down();
			_strong(MessageNode) previous = NULL;
			_strong(MessageNode) request = m_waitingReply;
			while (request != NULL)
			{
				if (request->message->getId() == message->getId())
				{
					break;
				}
				previous = request;
				request = request->next;
			}
			if (request != NULL)
			{
				if (previous == NULL)
				{
					m_waitingReply = request->next;
				}
				else
				{
					previous->next = request->next;
				}
				request->next = NULL;
			}
			previous = NULL;
			m_mutex->up();
			if (request != NULL)
			{
				request->callback->onReply(request->message, message, 0);
			}
			else
			{
				// o que fazer quando recebe reply sem request?
			}
		}
		else
		{
			_strong(MessageRequestCallback) requestCallback = m_requestCallback;
			if (requestCallback != NULL)
			{
				_strong(FlowReplier) replier = FlowReplier::create(message->getId(), m_channel);
				requestCallback->onRequest(message, replier);
			}
		}
	}

	/* implementação de ChannelClosedCallback. */
	void Flow::onChannelClosed(_strong(Channel)& channel)
	{
		m_mutex->down();
		_strong(FlowClosedCallback) closedHandler = m_closedHandler;
		_strong(MessageNode) node = m_waitingReply;
		m_closedHandler = NULL;
		m_waitingReply = NULL;
		m_mutex->up();
		if (closedHandler != NULL)
		{
			_strong(Flow) _this = this;
			closedHandler->onFlowClosed(_this);
			closedHandler = NULL;
		}
		if (node != NULL)
		{
			_strong(Message) nullMessage;
			do
			{
				node->callback->onReply(node->message, nullMessage, 1);
				node = node->next;
			}
			while (node != NULL);
		}
	}

	/* faz a verificação de timeouts. */
	void Flow::receive()
	{
		while (true)
		{
			m_mutex->down();
			unsigned long now = m_timer->getMilliseconds();
			unsigned long timeout = 0;
			_strong(MessageNode) nextMessage = m_waitingReply;
			_strong(MessageNode) timedOut = nextMessage;
			while (nextMessage != NULL)
			{
				if (nextMessage->absoluteTimeout <= now)
				{
					nextMessage = nextMessage->next;
					m_waitingReply = nextMessage;
				}
				else
				{
					nextMessage = NULL;
				}
			}
			nextMessage = m_waitingReply;
			if (nextMessage == NULL)
			{
				m_timeoutThread = NULL;
			}
			else
			{
				timeout = nextMessage->absoluteTimeout;
			}
			m_mutex->up();
			_strong(Message) _null = NULL;
			while (timedOut != NULL)
			{
				if (timedOut == nextMessage)
				{
					break;
				}
				else
				{
					timedOut->callback->onReply(timedOut->message, _null, 1);
					timedOut = timedOut->next;
				}
			}
			if (nextMessage != NULL)
			{
				Thread::sleep(timeout - now);
			}
			else
			{
				break;
			}
		}
	}
}
