/*
 * HaltOperation.h
 *
 *  Created on: 28/03/2013
 */

#ifndef BOT_FIRMWARE_MOVEMENT_HALTOPERATION_H_
#define BOT_FIRMWARE_MOVEMENT_HALTOPERATION_H_

#include "../../../base.h"
#include "../../../bot/firmware/MovementOperation.h"

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			/**
			 * Classe definindo a operação de parar.
			 */
			class HaltOperation :
					public MovementOperation
			{
				private:
					/* pool de objetos. */
					friend class base::ObjectPool<HaltOperation, 1>;
					static base::ObjectPool<HaltOperation, 1> m_pool;

				protected:
					/* construtor e destrutor. */
					HaltOperation();
					~HaltOperation();

					/* gerência de memória. */
					void initialize();
					void finalize();

				public:
					/* factory. */
					static HaltOperation* create();

				public:
					/* implementação de MovementOperation. */
					virtual int getLength();

					/* implementação de MovementOperation. */
					virtual int getValue();

					/* implementação de MovementOperation. */
					void run(int id, LegPositions& position, _strong(MovementManager)& manager);
			};
		}
	}
}

#endif /* BOT_FIRMWARE_MOVEMENT_HALTOPERATION_H_ */
