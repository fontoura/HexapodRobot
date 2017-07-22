/*
 * RotateOperation.h
 *
 *  Created on: 28/03/2013
 */

#ifndef BOT_FIRMWARE_MOVEMENT_ROTATEOPERATION_H_
#define BOT_FIRMWARE_MOVEMENT_ROTATEOPERATION_H_

#include "../../../base.h"
#include "../../../bot/firmware/MovementOperation.h"
#include "../../../bot/firmware/MagnetometerData.h"

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			/**
			 * Classe definindo a operação de rodar.
			 */
			class RotateOperation :
					public MovementOperation
			{
				private:
					/* pool de objetos. */
					friend class base::ObjectPool<RotateOperation, POOLSIZE_bot_firmware_movement_RotateOperation>;
					static base::ObjectPool<RotateOperation, POOLSIZE_bot_firmware_movement_RotateOperation> m_pool;

				protected:
					/* construtor e destrutor. */
					RotateOperation();
					~RotateOperation();

					/* gerência de memória. */
					void initialize(int angle, bool isClock, bool isDelta, MagnetometerData& data);
					void finalize();

				public:
					/* factory. */
					static RotateOperation* create(int angle, bool isClock, bool isDelta, MagnetometerData& data);

				protected:
					/* flag indicando se o sentido do movimento é horário. */
					bool m_isClock;

					/* ângulo de destino. */
					int m_targetAngle;

					/* ângulo atual. */
					int m_currentAngle;

					/* ângulo inicial. */
					int m_startAngle;

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

#endif /* BOT_FIRMWARE_MOVEMENT_ROTATEOPERATION_H_ */
