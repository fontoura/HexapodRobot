/*
 * Flow.h
 *
 *  Created on: 08/12/2012
 */

#ifndef PROTOCOL_FLOW_H_
#define PROTOCOL_FLOW_H_

#include "../globaldefs.h"
#include "../base.h"
#include "../concurrent.managed.h"
#include "../concurrent.semaphore.h"
#include "../concurrent.thread.h"
#include "../concurrent.time.h"
#include "../protocol/ChannelMessageCallback.h"
#include "../protocol/ChannelClosedCallback.h"

namespace protocol
{
	class Channel;
	class MessageRequestCallback;
	class MessageReplyCallback;
	class FlowClosedCallback;
	class MessageNode;
	class FlowThreadBody;

	/**
	 * Classe definindo um fluxo de mensagens.
	 */
	class Flow :
		public virtual base::Object,
		private virtual ChannelMessageCallback,
		private virtual ChannelClosedCallback
	{
			friend class FlowThreadBody;
		private:
#ifdef _POOLS_ENABLED
			/* pool de objetos. */
			friend class base::ObjectPool<Flow, _POOL_SIZE_FOR_FLOWS>;
			static base::ObjectPool<Flow, _POOL_SIZE_FOR_FLOWS> m_pool;
#endif /* _POOLS_ENABLED */

		protected:
			/* construtor e destrutor. */
			Flow();
			~Flow();

			/* gerência de memória. */
			void initialize(_strong(Channel)& channel, unsigned long minimalTimeout);
			void finalize();

		public:
			/* factory. */
			static Flow* create(_strong(Channel)& channel, unsigned long minimalTimeout);

		protected:
			/* mutex para controle de concorrência. */
			_strong(concurrent::semaphore::Semaphore) m_mutex;

			/* lista encadeada de mensagens esperando reply. */
			_strong(MessageNode) m_waitingReply;

			/* thread de verificação de timeout de mensagens. */
			_strong(concurrent::thread::Thread) m_timeoutThread;

			/* canal de mensagens. */
			_strong(Channel) m_channel;

			/* temporizador de referência para as medições de tempo. */
			_strong(concurrent::time::Stoptimer) m_timer;

			/* objeto com callback de mensagem é recebida. */
			_strong(MessageRequestCallback) m_requestCallback;

			/* objeto com callback de fechamento de fluxo. */
			_strong(FlowClosedCallback) m_closedHandler;

			/* identificador da última mensagem enviada. */
			unsigned int m_lastId;

			/* timeout mínimo das mensagens. */
			unsigned long m_minimalTimeout;

		public:
			/* realiza o envio de uma requisição pelo fluxo. */
			void send(_strong(Message)& message, _strong(MessageReplyCallback)& callback, unsigned long timeout);

			/* inicia a operação do fluxo, assumindo que o canal esteja em funcionamento. */
			void start();

			/* para o fluxo. */
			void stop();

			/* verifica se o fluxo está em execução. */
			bool isOpen();

			/* getter e setter do objeto com callback de recebimento de requisição. */
			void setRequestCallback(_strong(MessageRequestCallback)& callback);
			_strong(MessageRequestCallback)& getRequestCallback();

			/* getter e setter do objeto com callback de fechamento de fluxo. */
			void setClosedCallback(_strong(FlowClosedCallback)& callback);
			_strong(FlowClosedCallback)& getClosedCallback();

		protected:
			/* implementação de ChannelMessageCallback. */
			void onMessage(_strong(Message)& message);

			/* implementação de ChannelClosedCallback. */
			void onChannelClosed(_strong(Channel)& message);

			/* faz a verificação de timeouts. */
			void receive();
	};
}

#endif /* PROTOCOL_FLOW_H_ */
