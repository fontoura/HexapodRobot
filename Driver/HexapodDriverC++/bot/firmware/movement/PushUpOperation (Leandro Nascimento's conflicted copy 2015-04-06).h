/*
 * PushUpOperation.h
 *
 *  Created on: 05/04/2013
 */

#ifndef BOT_FIRMWARE_MOVEMENT_PUSHUPOPERATION_H_
#define BOT_FIRMWARE_MOVEMENT_PUSHUPOPERATION_H_

#include "../../../base.h"
#include "../../../bot/firmware/MovementOperation.h"

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			/**
			 * Classe definindo a operação de fazer flexões.
			 */
			class PushUpOperation :
					public MovementOperation
			{
				private:
					/* pool de objetos. */
					friend class base::ObjectPool<PushUpOperation, POOLSIZE_bot_firmware_movement_PushUpOperation>;
					static base::ObjectPool<PushUpOperation, POOLSIZE_bot_firmware_movement_PushUpOperation> m_pool;

				protected:
					/* construtor e destrutor. */
					PushUpOperation();
					~PushUpOperation();

					/* gerência de memória. */
					void initialize(int pushUps);
					void finalize();

				public:
					/* factory. */
					static PushUpOperation* create(int pushUps);

				protected:
					/* distância que deve ser percorrida. */
					int m_totalPushUps;

					/* distância que deve ser percorrida. */
					int m_pushUps;

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

#endif /* BOT_FIRMWARE_MOVEMENT_PUSHUPOPERATION_H_ */
