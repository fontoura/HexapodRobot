/*
 * Channel.h
 *
 *  Created on: 03/12/2012
 */

#ifndef PROTOCOL_CHANNEL_H_
#define PROTOCOL_CHANNEL_H_

#include "../globaldefs.h"
#include "../base/all.h"
#include "../concurrent/managed/all.h"
#include "../concurrent.semaphore.h"
#include "../concurrent.thread.h"
#include "../stream.h"

namespace protocol
{
	class Message;
	class ChannelMessageCallback;
	class ChannelClosedCallback;

	/**
	 * Enumeração de estados do canal.
	 */
	enum ChannelStatus
	{
		/* indica canal ainda não aberto. */
		NotStarted,

		/* indica canal aberto. */
		Running,

		/* indica canal fechado. */
		Stopped
	};

	/**
	 * Classe definindo um canal de troca da mensagens.
	 */
	class Channel :
		public virtual base::Object
	{
		private:
			friend class ChannelThreadBody;
			_pool_decl(Channel, _POOL_SIZE_FOR_CHANNELS)

		protected:
			/* construtor e destrutor. */
			Channel();
			~Channel();

			/* gerência de memória. */
			void initialize(_strong(stream::Stream)& stream, uint32_t magicWord, unsigned long byteTimeout);
			void finalize();

		public:
			/* factory. */
			static Channel* create(_strong(stream::Stream)& stream, uint32_t magicWord, unsigned long byteTimeout);

		private:
			/* estado atual do canal. */
			ChannelStatus m_status;

			/* fluxo de dados sobre o qual o canal é construído. */
			_strong(stream::Stream) m_stream;

			/* thread de recebimento de mensagens. */
			_strong(concurrent::thread::Thread) m_receiveThread;

			/* mutex para controlar operações de envio. */
			_strong(concurrent::semaphore::Semaphore) m_sendMutex;

			/* objeto com callback de recebimento de mensagem. */
			_strong(ChannelMessageCallback) m_messageCallback;

			/* objeto com callback de fechamento de canal. */
			_strong(ChannelClosedCallback) m_closedCallback;

			/* magic word do protocolo em uso. */
			uint32_t m_magicWord;

			/* timeout (em milissegundos) do recebimento de cada byte de uma mensagem. */
			unsigned long m_byteTimeout;

		public:

			/* realiza o envio de uma mensagem pelo canal. */
			bool send(_strong(Message)& message);

			/* inicia a operação do canal, assumindo que o fluxo de dados esteja aberto. */
			void start();

			/* para o canal. */
			void stop();

			/* verifica se o canal está em execução. */
			bool isRunning();

			/* espera o término da execução da thread do canal. */
			void join();

			/* getter e setter do objeto com callback de recebimento de mensagem. */
			_strong(ChannelMessageCallback)& getMessageCallback();
			void setMessageCallback(_strong(ChannelMessageCallback)& callback);

			/* getter e setter do objeto com callback de fechamento de canal. */
			_strong(ChannelClosedCallback)& getClosedCallback();
			void setClosedCallback(_strong(ChannelClosedCallback)& callback);

		protected:
			/* faz o recebimento de mensagens. */
			void receive();
	};
}

#endif /* PROTOCOL_CHANNEL_H_ */
