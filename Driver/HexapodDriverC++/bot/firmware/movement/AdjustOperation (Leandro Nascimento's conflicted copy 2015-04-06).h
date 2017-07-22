/*
 * AdjustOperation.h
 *
 *  Created on: 06/04/2013
 */

#ifndef BOT_FIRMWARE_MOVEMENT_AdjustOperation_H_
#define BOT_FIRMWARE_MOVEMENT_AdjustOperation_H_

#include "../../../base.h"
#include "../../../bot/firmware/MovementOperation.h"

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			/**
			 * Classe definindo a operação de ajustar o ângulo.
			 */
			class AdjustOperation :
					public MovementOperation
			{
				private:
					/* pool de objetos. */
					friend class base::ObjectPool<AdjustOperation, POOLSIZE_bot_firmware_movement_AdjustOperation>;
					static base::ObjectPool<AdjustOperation, POOLSIZE_bot_firmware_movement_AdjustOperation> m_pool;

				protected:
					/* construtor e destrutor. */
					AdjustOperation();
					~AdjustOperation();

					/* gerência de memória. */
					void initialize();
					void finalize();

				public:
					/* factory. */
					static AdjustOperation* create();

				protected:
					/* total de iterações. */
					int m_total;

					/* iteração atual. */
					int m_current;

				public:
					/* implementação de MovementOperation. */
					int getLength();

					/* implementação de MovementOperation. */
					int getValue();

					/* implementação de MovementOperation. */
					void run(int id, LegPositions& position, _strong(MovementManager)& manager);
			};
		}
	}
}

#endif /* BOT_FIRMWARE_MOVEMENT_AdjustOperation_H_ */
