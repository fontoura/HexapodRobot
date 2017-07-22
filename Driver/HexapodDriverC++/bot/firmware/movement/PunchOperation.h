/*
 * PunchOperation.h
 *
 *  Created on: 04/05/2013
 */

#ifndef BOT_FIRMWARE_MOVEMENT_PUNCHOPERATION_H_
#define BOT_FIRMWARE_MOVEMENT_PUNCHOPERATION_H_

#include "../../../base/all.h"
#include "../MovementOperation.h"

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			/**
			 * Classe definindo a operação de socar.
			 */
			class PunchOperation :
				public MovementOperation
			{
				_pool_decl(PunchOperation, POOLSIZE_bot_firmware_movement_PunchOperation)

				protected:
					/* construtor e destrutor. */
					PunchOperation();
					~PunchOperation();

					/* ger�ncia de memória. */
					void initialize(int punches);
					void finalize();

				public:
					/* factory. */
					static PunchOperation* create(int punches);

				protected:
					/* distância que deve ser percorrida. */
					int m_totalPunches;

					/* distância que deve ser percorrida. */
					int m_punches;

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

#endif /* BOT_FIRMWARE_MOVEMENT_PUNCHOPERATION_H_ */
