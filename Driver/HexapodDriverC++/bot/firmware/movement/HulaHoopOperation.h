/*
 * HulaHoopOperation.h
 *
 *  Created on: 05/04/2013
 */

#ifndef BOT_FIRMWARE_MOVEMENT_HULAHOOPOPERATION_H_
#define BOT_FIRMWARE_MOVEMENT_HULAHOOPOPERATION_H_

#include "../../../base/all.h"
#include "../MovementOperation.h"

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			/**
			 * Classe definindo a operação de bambolear.
			 */
			class HulaHoopOperation :
					public MovementOperation
			{
				_pool_decl(HulaHoopOperation, POOLSIZE_bot_firmware_movement_HulaHoopOperation)

				protected:
					/* construtor e destrutor. */
					HulaHoopOperation();
					~HulaHoopOperation();

					/* gerência de memória. */
					void initialize(int cycles);
					void finalize();

				public:
					/* factory. */
					static HulaHoopOperation* create(int cycles);

				protected:
					/* total de ciclos. */
					int m_totalCycles;

					/* ciclos a serem percorridos. */
					int m_cycles;

				public:
					/* implementação de MovementOperation. */
					int getLength();

					/* implementação de MovementOperation. */
					int getValue();

					/* implementação de MovementOperation. */
					void run(int id, _strong(MovementManager)& manager);
			};
		}
	}
}

#endif /* BOT_FIRMWARE_MOVEMENT_HULAHOOPOPERATION_H_ */
