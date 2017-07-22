/*
 * Message.h
 *
 *  Created on: 03/12/2012
 */

#ifndef PROTOCOL_MESSAGE_H_
#define PROTOCOL_MESSAGE_H_

#include "../globaldefs.h"
#include "../base/all.h"

#include <stdint.h>

namespace protocol
{
	/**
	 * Classe representando uma mensagem genérica.
	 */
	class Message :
		public base::Object
	{
		_pool_decl(Message, _POOL_SIZE_FOR_MESSAGES);

		protected:
			/* construtor e destrutor. */
			Message();
			~Message();

			/* gerência de memória. */
			void initialize(uint32_t type, uint32_t length);
			void finalize();

		public:
			/* factory. */
			static Message* create(uint32_t type, uint32_t length);

		private:
			/* tipo da mensagem */
			uint32_t m_type;

			/* identificador da mensagem */
			uint32_t m_id;

			/* tamanho da mensagem */
			uint32_t m_length;

			/* buffer de corpo da mensagem */
#ifdef _POOLS_ENABLED
			uint8_t m_buffer[_MAX_MESSAGE_SIZE];
#else /* ifndef _POOLS_ENABLED */
			uint8_t* m_buffer;
#endif /* _POOLS_ENABLED */

		public:

			/* obtém o tipo da mensagem */
			uint32_t getType();

			/* obtém o identificador da mensagem */
			uint32_t getId();

			/* obtém o tamanho da mensagem */
			uint32_t getLength();

			/* obtém o buffer da mensagem */
			uint8_t* getBuffer();

			/* define o identificador da mensagem */
			void setId(uint32_t id);

			/* obtém um byte da mensagem */
			int getByte(int i);

			/* define um byte da mensagem */
			void setByte(int i, int b);
	};
}

#endif /* PROTOCOL_MESSAGE_H_ */
