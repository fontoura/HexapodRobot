/*
 * Channel.cpp
 *
 *  Created on: 03/12/2012
 */

#include "../protocol/Channel.h"
#include "../protocol/ChannelMessageCallback.h"
#include "../protocol/ChannelClosedCallback.h"
#include "../protocol/ChannelThreadBody.h"
#include "../protocol/Message.h"
#include "../global.h"

using namespace base;
using namespace concurrent::thread;
using namespace concurrent::semaphore;
using namespace stream;
using namespace global;

// formato de mensagem:
// MAGIC WORD (4 bytes)
// TIPO (2 bytes)
// ID (2 bytes)
// TAMANHO (2 bytes)
// CHECKSUM HEADER (2 bytes)
// CHECKSUM XOR (2 bytes)
// CHECKSUM CHECKSUM (2 bytes)
// CORPO (TAMANHO bytes)

/* macros para debug */
#ifdef DEBUG_procol_MessageChannel
#include <iostream>
#define DEBUG(v1) std::cout<<(v1)<<std::endl
#define DEBUG2(v1,v2) std::cout<<(v1)<<(v2)<<std::endl
#define DEBUG3(v1,v2,v3) std::cout<<(v1)<<(v2)<<(v3)<<std::endl
#define DEBUG4(v1,v2,v3,v4) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<std::endl
#define DEBUG5(v1,v2,v3,v4,v5) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<(v5)<<std::endl
#else /* ifndef DEBUG_procol_MessageChannel */
#define DEBUG(v1) {}
#define DEBUG2(v1,v2) {}
#define DEBUG3(v1,v2,v3) {}
#define DEBUG4(v1,v2,v3,v4) {}
#define DEBUG5(v1,v2,v3,v4,v5) {}
#endif /* DEBUG_procol_MessageChannel */

namespace protocol
{
#ifdef _POOLS_ENABLED
	/* pool de objetos. */
	base::ObjectPool<Channel, _POOL_SIZE_FOR_CHANNELS> Channel::m_pool;
#endif /* _POOLS_ENABLED */

	/* construtor e destrutor. */
	Channel::Channel()
	{
		m_status = NotStarted;
		m_magicWord = 0;
		m_byteTimeout = 0;
	}

	Channel::~Channel()
	{
	}

	/* gerência de memória. */
	void Channel::initialize(_strong(Stream)& stream, uint32_t magicWord, unsigned long byteTimeout)
	{
		DEBUG("Inicializando MessageChannel...");
		m_status = NotStarted;
		m_stream = stream;
		m_sendMutex = Semaphore::create(1, 1);
		m_magicWord = magicWord;
		m_byteTimeout = byteTimeout;
	}

	void Channel::finalize()
	{
		DEBUG("Finalizando MessageChannel...");
		this->stop();
		m_stream = NULL;
		m_sendMutex = NULL;
#ifdef _POOLS_ENABLED
		Object::beforeRecycle();
		m_pool.recycle(this);
#else /* ifndef _POOLS_ENABLED */
		Object::finalize();
#endif /* _POOLS_ENABLED */
	}

	/* factory. */
	Channel* Channel::create(_strong(Stream)& stream, uint32_t magicWord, unsigned long byteTimeout)
	{
		DEBUG("Criando MessageChannel...");
#ifdef _POOLS_ENABLED
		Channel* channel = m_pool.obtain();
#else /* ifndef _POOLS_ENABLED */
		Channel* channel = new Channel();
#endif /* _POOLS_ENABLED */
		if (channel != NULL)
		{
			channel->initialize(stream, magicWord, byteTimeout);
		}
		return channel;
	}

	/* realzia o envio de uma mensagem pelo canal. */
	bool Channel::send(_strong(Message)& message)
	{
		m_sendMutex->down();
		if (m_status == Running)
		{
			DEBUG("Enviando mensagem pelo MessageChannel...");
			uint8_t header[sizeof(uint32_t) + 6 * sizeof(uint16_t)];
			writeLittleEndian32(header, 0, m_magicWord);
			writeLittleEndian16(header, sizeof(uint32_t) + 0 * sizeof(uint16_t), message->getType());
			writeLittleEndian16(header, sizeof(uint32_t) + 1 * sizeof(uint16_t), message->getId());
			writeLittleEndian16(header, sizeof(uint32_t) + 2 * sizeof(uint16_t), message->getLength());
			volatile short checksumHeader = checksum16(header, 0, sizeof(uint32_t) + 3 * sizeof(uint16_t));
			volatile short checksumBody = checksum16(message->getBuffer(), 0, message->getLength());
			volatile short checksumXor = checksumHeader ^ checksumBody;
			writeLittleEndian16(header, sizeof(uint32_t) + 3 * sizeof(uint16_t), checksumHeader);
			writeLittleEndian16(header, sizeof(uint32_t) + 4 * sizeof(uint16_t), checksumXor);
			writeLittleEndian16(header, sizeof(uint32_t) + 5 * sizeof(uint16_t), checksumBody);
			volatile unsigned int written = (unsigned int) m_stream->write(header, 0, sizeof(uint32_t) + 6 * sizeof(uint16_t));
			if (written == sizeof(uint32_t) + 6 * sizeof(uint16_t))
			{
				written = (unsigned int) m_stream->write(message->getBuffer(), 0, message->getLength());
				if (written == (unsigned int) message->getLength())
				{
					DEBUG("Mensagem enviada com sucesso pelo MessageChannel...");
					m_sendMutex->up();
					return true;
				}
			}
		}
		DEBUG("Nao foi possivel enviar a mensagem pelo MessageChannel...");
		m_sendMutex->up();
		return false;
	}

	/* inicia a operação do canal, assumindo que o fluxo de dados esteja aberto. */
	void Channel::start()
	{
		m_sendMutex->down();
		if (m_status == NotStarted)
		{
			m_receiveThread = Thread::create(ChannelThreadBody::create(this));
#if __NIOS2__
			m_receiveThread->setPriority(HighThreadPriority);
#endif /* __NIOS2__ */
			m_receiveThread->start();
			m_status = Running;
		}
		m_sendMutex->up();
	}

	/* para o canal. */
	void Channel::stop()
	{
		m_sendMutex->down();
		if (m_status == Running)
		{
			m_stream->close();
			m_status = Stopped;
		}
		m_sendMutex->up();
	}

	/* verifica se o canal está em execução. */
	bool Channel::isRunning()
	{
		return m_stream->isOpen();
	}

	/* espera o término da execução da thread do canal. */
	void Channel::join()
	{
		_strong(Thread) thread;
		m_sendMutex->down();
		if (m_status != NotStarted)
		{
			thread = m_receiveThread;
		}
		m_sendMutex->up();
		if (thread != NULL)
		{
			thread->join(-1);
		}
	}

	/* getter e setter do objeto com callback de recebimento de mensagem. */
	_strong(ChannelMessageCallback)& Channel::getMessageCallback()
	{
		return m_messageCallback;
	}

	void Channel::setMessageCallback(_strong(ChannelMessageCallback)& callback)
	{
		m_messageCallback = callback;
	}

	/* getter e setter do objeto com callback de fechamento de canal. */
	_strong(ChannelClosedCallback)& Channel::getClosedCallback()
	{
		return m_closedCallback;
	}

	void Channel::setClosedCallback(_strong(ChannelClosedCallback)& callback)
	{
		m_closedCallback = callback;
	}

	/* faz o recebimento de mensagens. */
	void Channel::receive()
	{
		_strong(Stream) stream = m_stream;
		_strong(ChannelMessageCallback) handler;
		_strong(Message) message;
		while (stream->isOpen())
		{
			// espera pelo header da mensagem.
			uint8_t header[0x10];
			stream->setTimeouts(-1, m_byteTimeout);
			unsigned int read = stream->read(header, 0, 0x10);
			stream->setTimeouts(m_byteTimeout, m_byteTimeout);

			// verifica se recebeu tudo.
			if (read != 0x10)
			{
				DEBUG("Recebida mensagem com cabecalho muito curto pelo MessageChannel...");
				do
				{
					read = (unsigned int) stream->read(header, 0, 1);
				}
				while (read > 0);
				continue;
			}

			// espera pelo corpo da mensagem.
			uint32_t magicWord = readLittleEndian32(header, 0x0);
			uint16_t type = readLittleEndian16(header, 0x4);
			uint16_t id = readLittleEndian16(header, 0x6);
			uint16_t length = readLittleEndian16(header, 0x8);
			uint16_t checksumHeader = readLittleEndian16(header, 0xa);
			uint16_t checksumXor = readLittleEndian16(header, 0xc);
			uint16_t checksumBody = readLittleEndian16(header, 0xe);

			// verifica se a magic word está errada.
			if (magicWord != m_magicWord)
			{
				DEBUG("Recebida mensagem com Magic Word invalida pelo MessageChannel...");
				do
				{
					read = (unsigned int) stream->read(header, 0, 1);
				}
				while (read > 0);
				continue;
			}

			// verifica se os checksums do cabeçalho batem.
			if (checksumXor != (uint16_t)(checksumBody ^ checksumHeader))
			{
				DEBUG("Recebida mensagem com cabecalho inconsistente pelo MessageChannel...");
				do
				{
					read = (unsigned int) stream->read(header, 0, 1);
				}
				while (read > 0);
				continue;
			}
			short calculatedChecksumHeader = checksum16(header, 0, sizeof(uint32_t) + 3 * sizeof(uint16_t));
			if (checksumHeader != calculatedChecksumHeader)
			{
				DEBUG("Recebida mensagem com cabecalho corrompido pelo MessageChannel...");
				do
				{
					read = (unsigned int) stream->read(header, 0, 1);
				}
				while (read > 0);
				continue;
			}

			// corta o tamanho da mensagem, se estiver usando pool de objetos.
#ifdef _POOLS_ENABLED
			if (length > _MAX_MESSAGE_SIZE)
			{
				DEBUG("Recebida mensagem muito grande pelo MessageChannel...");
				length = _MAX_MESSAGE_SIZE;
			}
#endif /* _POOLS_ENABLED */

			// lê o corpo da mensagem.
			message = Message::create(type, length);
			message->setId(id);
			read = (unsigned int) stream->read(message->getBuffer(), 0, length);

			// verifica se leu o corpo da mensagem.
			if (read == length)
			{
				DEBUG("Recebida mensagem inteira!");
				// verifica se o checksum é válido.
				uint16_t calculatedChecksumBody = checksum16(message->getBuffer(), 0, message->getLength());
				if (calculatedChecksumBody == checksumBody)
				{
					DEBUG("Recebida mensagem com checksum correto!");
					handler = m_messageCallback;
					if (handler != NULL)
					{
						handler->onMessage(message);
						handler = NULL;
					}
				}
				else
				{
					DEBUG("Recebida mensagem com checksum incorreto!");
				}
			}
			else
			{
				DEBUG("Recebida apenas parte de mensagem!");
			}
			message = NULL;
		}
		_strong(ChannelClosedCallback) closedHandler = m_closedCallback;
		m_closedCallback = NULL;
		if (closedHandler != NULL)
		{
			_strong(Channel) _this = this;
			closedHandler->onChannelClosed(_this);
			closedHandler = NULL;
		}
		m_messageCallback = NULL;
	}
}
