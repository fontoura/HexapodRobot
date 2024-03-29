/*
 * WalkOperation.h
 *
 *  Created on: 28/03/2013
 */

#ifndef BOT_FIRMWARE_MOVEMENT_WALKOPERATION_H_
#define BOT_FIRMWARE_MOVEMENT_WALKOPERATION_H_

#include "../../../base.h"
#include "../../../bot/firmware/MovementOperation.h"

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			/**
			 * Classe definindo a operação de andar em frente.
			 */
			class WalkOperation :
					public MovementOperation
			{
				private:
					/* pool de objetos. */
					friend class base::ObjectPool<WalkOperation, POOLSIZE_bot_firmware_movement_WalkOperation>;
					static base::ObjectPool<WalkOperation, POOLSIZE_bot_firmware_movement_WalkOperation> m_pool;

				protected:
					/* construtor e destrutor. */
					WalkOperation();
					~WalkOperation();

					/* gerência de memória. */
					void initialize(int distance, int angle, bool isAligned, bool isBackward);
					void finalize();

				public:
					/* factory. */
					static WalkOperation* create(int distance, int angle, bool isAligned, bool isBackward);

				protected:
					/* flag que indica se o movimento é para trás. */
					bool m_isBackward;

					/* flag que indica se o movimento é alinhado.. */
					bool m_isAligned;

					/* ängulo-alvo. */
					int m_targetAngle;

					/* distância que deve ser percorrida. */
					int m_totalDistance;

					/* distância que deve ser percorrida. */
					int m_walkedDistance;

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

#endif /* BOT_FIRMWARE_MOVEMENT_WALKOPERATION_H_ */
