/*
 * HaltOperation.h
 *
 *  Created on: 28/03/2013
 */

#ifndef BOT_FIRMWARE_MOVEMENT_HALTOPERATION_H_
#define BOT_FIRMWARE_MOVEMENT_HALTOPERATION_H_

#include "../../../base/all.h"
#include "../MovementOperation.h"


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
				_pool_decl(HaltOperation, 1);

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
					void run(int id, _strong(MovementManager)& manager);
			};
		}
	}
}

#endif /* BOT_FIRMWARE_MOVEMENT_HALTOPERATION_H_ */
