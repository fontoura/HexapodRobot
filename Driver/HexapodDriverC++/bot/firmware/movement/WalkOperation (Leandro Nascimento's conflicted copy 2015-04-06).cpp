/*
 * WalkOperation.cpp
 *
 *  Created on: 28/03/2013
 */

#include "../../../bot/firmware/movement/fw_native.h"
#include "../../../bot/firmware/MagnetometerData.h"
#include "../../../bot/firmware/SensorsManager.h"
#include "../../../bot/firmware/MovementManager.h"
#include "../../../bot/firmware/movement/WalkOperation.h"
#include "../../../bot/firmware/fw_defines.h"


int x_base = 70;//60;//75;
int y_base = 30;
int z_base = 60;

using namespace base;

/* macros para debug */
#ifdef DEBUG_bot_firmware_movement_WalkOperation
#include <iostream>
#define DEBUG(v1) std::cout<<(v1)<<std::endl
#define DEBUG2(v1,v2) std::cout<<(v1)<<(v2)<<std::endl
#define DEBUG3(v1,v2,v3) std::cout<<(v1)<<(v2)<<(v3)<<std::endl
#define DEBUG4(v1,v2,v3,v4) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<std::endl
#define DEBUG5(v1,v2,v3,v4,v5) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<(v5)<<std::endl
#else /* ifndef DEBUG_bot_firmware_movement_WalkOperation */
#define DEBUG(v1) {}
#define DEBUG2(v1,v2) {}
#define DEBUG3(v1,v2,v3) {}
#define DEBUG4(v1,v2,v3,v4) {}
#define DEBUG5(v1,v2,v3,v4,v5) {}
#endif /* DEBUG_bot_firmware_movement_WalkOperation */

#define DELAY_MOVIMENTACAO ((int)10e3)

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			void restPosition(LegPositions& start);
			void walkMovement(_strong(MovementManager)& manager, int id, LegPositions& start, bool isBackward, bool isAligned, int& steps, int totalSteps);

			/* pool de objetos. */
			ObjectPool<WalkOperation, POOLSIZE_bot_firmware_movement_WalkOperation> WalkOperation::m_pool;

			/* construtor e destrutor. */
			WalkOperation::WalkOperation()
			{
				m_isBackward = false;
				m_isAligned = false;
				m_targetAngle = 0;
				m_walkedDistance = 0;
				m_totalDistance = 0;
				DEBUG("WalkOperation alocado!");
			}

			WalkOperation::~WalkOperation()
			{
				DEBUG("WalkOperation apagado!");
			}

			/* gerência de memória. */
			void WalkOperation::initialize(int distance, int angle, bool isAligned, bool isBackward)
			{
				DEBUG3("Inicializando WalkOperation(distance = ", distance, ")...");
				m_targetAngle = angle;
				m_walkedDistance = 0;
				m_isAligned = isAligned;
				m_isBackward = isBackward;
				if (distance > 0)
				{
					m_totalDistance = distance;
				}
				else
				{
					m_totalDistance = -distance;
				}
			}

			void WalkOperation::finalize()
			{
				DEBUG("Finalizando WalkOperation...");
				Object::beforeRecycle();
				WalkOperation::m_pool.recycle(this);
			}

			/* factory. */
			WalkOperation* WalkOperation::create(int distance, int angle, bool isAligned, bool isBackward)
			{
				DEBUG("Criando WalkOperation...");
				WalkOperation* walk = WalkOperation::m_pool.obtain();
				if (walk != NULL)
				{
					walk->initialize(distance, angle, isAligned, isBackward);
				}
				return walk;
			}

			/* implementação de MovementOperation. */
			int WalkOperation::getLength()
			{
				return m_totalDistance;
			}

			/* implementação de MovementOperation. */
			int WalkOperation::getValue()
			{
				return m_walkedDistance;
			}

			/* implementação de MovementOperation. */
			void WalkOperation::run(int id, LegPositions& position, _strong(MovementManager)& manager)
			{
				manager->getSensors()->setEnabled(false);
				manager->getSensors()->refresh();
				if (m_isAligned)
				{
					MagnetometerData data;
					manager->getSensors()->readMagnetometer(data);
					// TODO alinhar antes de começar a andar.
				}
				walkMovement(manager, id, position, m_isBackward, m_isAligned, m_walkedDistance, m_totalDistance);
				restPosition(position);
				manager->getSensors()->setEnabled(true);
			}
		}
	}
}

using namespace bot::firmware;
using namespace bot::firmware::movement;

void bot::firmware::movement::walkMovement(_strong(MovementManager)& manager, int id, LegPositions& start, bool isBackward, bool isAligned, int& steps, int totalSteps)
{
	LegPositions interpol[NUM_INTERPOL];
	LegPositions end;

	int delta_y = 25;
	int delta_z = 10;

	int offset_l = 0;
	int offset_r = 0;

	if (!isBackward)
	{
		SET_LEG(end.xyz[0], x_base, y_base, z_base);
		SET_LEG(end.xyz[1], x_base, delta_y, z_base - delta_z);
		SET_LEG(end.xyz[2], x_base, -y_base, z_base);
		SET_LEG(end.xyz[3], -x_base, -y_base, z_base);
		SET_LEG(end.xyz[4], -x_base, 0, z_base);
		SET_LEG(end.xyz[5], -x_base, y_base + delta_y, z_base - delta_z);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);

		SET_LEG(end.xyz[0], x_base, y_base, z_base);
		SET_LEG(end.xyz[1], x_base, delta_y, z_base);
		SET_LEG(end.xyz[2], x_base, -y_base, z_base);
		SET_LEG(end.xyz[3], -x_base, -y_base, z_base);
		SET_LEG(end.xyz[4], -x_base, 0, z_base);
		SET_LEG(end.xyz[5], -x_base, y_base + delta_y, z_base);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);

		SET_LEG(end.xyz[0], x_base, y_base, z_base - delta_z);
		SET_LEG(end.xyz[1], x_base, delta_y, z_base);
		SET_LEG(end.xyz[2], x_base, -y_base - delta_y, z_base - delta_z);
		SET_LEG(end.xyz[3], -x_base, -y_base, z_base);
		SET_LEG(end.xyz[4], -x_base, -delta_y, z_base - delta_z);
		SET_LEG(end.xyz[5], -x_base, y_base + delta_y, z_base);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);
	}
	else
	{
//		SET_LEG(end.xyz[0], x_base, y_base, z_base);
//		SET_LEG(end.xyz[1], x_base, 0, z_base);
//		SET_LEG(end.xyz[2], x_base, -y_base, z_base);
//		SET_LEG(end.xyz[3], -x_base, -y_base, z_base);
//		SET_LEG(end.xyz[4], -x_base, 0, z_base);
//		SET_LEG(end.xyz[5], -x_base, y_base, z_base);

		SET_LEG(end.xyz[0], x_base, y_base, z_base);
		SET_LEG(end.xyz[1], x_base, 0, z_base);
		SET_LEG(end.xyz[2], x_base, -y_base - delta_y, z_base - delta_z);
		SET_LEG(end.xyz[3], -x_base, -y_base, z_base);
		SET_LEG(end.xyz[4], -x_base, -delta_y, z_base - delta_z);
		SET_LEG(end.xyz[5], -x_base, y_base, z_base);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);

		SET_LEG(end.xyz[0], x_base, y_base, z_base);
		SET_LEG(end.xyz[1], x_base, 0, z_base);
		SET_LEG(end.xyz[2], x_base, -y_base - delta_y, z_base);
		SET_LEG(end.xyz[3], -x_base, -y_base, z_base);
		SET_LEG(end.xyz[4], -x_base, -delta_y, z_base);
		SET_LEG(end.xyz[5], -x_base, y_base, z_base);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);

		SET_LEG(end.xyz[0], x_base, y_base, z_base);
		SET_LEG(end.xyz[1], x_base, delta_y, z_base - delta_z);
		SET_LEG(end.xyz[2], x_base, -y_base - delta_y, z_base);
		SET_LEG(end.xyz[3], -x_base, -y_base, z_base - delta_z);
		SET_LEG(end.xyz[4], -x_base, -delta_y, z_base);
		SET_LEG(end.xyz[5], -x_base, y_base + delta_y, z_base - delta_z);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);
	}

	for (steps = 0; steps < totalSteps; steps ++)
	{
		DEBUG("WalkOperation esta em andamento");

		// atualiza a leitura dos sensores.
		manager->getSensors()->refresh();

		if (isAligned)
		{
			MagnetometerData data;
			manager->getSensors()->readMagnetometer(data);

			// TODO ajustar os offsets com base na leitura do magnetômetro.
		}


		if (!isBackward)
		{
			SET_LEG(end.xyz[0], x_base, y_base + delta_y - offset_r, z_base - delta_z);
			SET_LEG(end.xyz[1], x_base, -delta_y, z_base);
			SET_LEG(end.xyz[2], x_base, -y_base, z_base - delta_z);
			SET_LEG(end.xyz[3], -x_base, -y_base - delta_y + offset_l, z_base);
			SET_LEG(end.xyz[4], -x_base, delta_y, z_base - delta_z);
			SET_LEG(end.xyz[5], -x_base, y_base, z_base);
			move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);

			SET_LEG(end.xyz[0], x_base, y_base + delta_y - offset_r, z_base);
			SET_LEG(end.xyz[1], x_base, -delta_y, z_base - delta_z);
			SET_LEG(end.xyz[2], x_base, -y_base, z_base);
			SET_LEG(end.xyz[3], -x_base, -y_base - delta_y + offset_l, z_base - delta_z);
			SET_LEG(end.xyz[4], -x_base, delta_y, z_base);
			SET_LEG(end.xyz[5], -x_base, y_base, z_base - delta_z);
			move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);

			SET_LEG(end.xyz[0], x_base, y_base, z_base);
			SET_LEG(end.xyz[1], x_base, delta_y, z_base - delta_z);
			SET_LEG(end.xyz[2], x_base, -y_base - delta_y + offset_r, z_base);
			SET_LEG(end.xyz[3], -x_base, -y_base, z_base - delta_z);
			SET_LEG(end.xyz[4], -x_base, -delta_y, z_base);
			SET_LEG(end.xyz[5], -x_base, y_base + delta_y - offset_l, z_base - delta_z);
			move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);

			SET_LEG(end.xyz[0], x_base, y_base, z_base - delta_z);
			SET_LEG(end.xyz[1], x_base, delta_y, z_base);
			SET_LEG(end.xyz[2], x_base, -y_base - delta_y + offset_r, z_base - delta_z);
			SET_LEG(end.xyz[3], -x_base, -y_base, z_base);
			SET_LEG(end.xyz[4], -x_base, -delta_y, z_base - delta_z);
			SET_LEG(end.xyz[5], -x_base, y_base + delta_y - offset_l, z_base);
			move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);
		}
		else
		{
			SET_LEG(end.xyz[0], x_base, y_base + delta_y - offset_r, z_base);
			SET_LEG(end.xyz[1], x_base, -delta_y, z_base - delta_z);
			SET_LEG(end.xyz[2], x_base, -y_base, z_base);
			SET_LEG(end.xyz[3], -x_base, -y_base - delta_y + offset_l, z_base - delta_z);
			SET_LEG(end.xyz[4], -x_base, delta_y, z_base);
			SET_LEG(end.xyz[5], -x_base, y_base, z_base - delta_z);
			move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);

			SET_LEG(end.xyz[0], x_base, y_base + delta_y - offset_r, z_base - delta_z);
			SET_LEG(end.xyz[1], x_base, -delta_y, z_base);
			SET_LEG(end.xyz[2], x_base, -y_base, z_base - delta_z);
			SET_LEG(end.xyz[3], -x_base, -y_base - delta_y + offset_l, z_base);
			SET_LEG(end.xyz[4], -x_base, delta_y, z_base - delta_z);
			SET_LEG(end.xyz[5], -x_base, y_base, z_base);
			move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);

			SET_LEG(end.xyz[0], x_base, y_base, z_base - delta_z);
			SET_LEG(end.xyz[1], x_base, delta_y, z_base);
			SET_LEG(end.xyz[2], x_base, -y_base - delta_y + offset_r, z_base - delta_z);
			SET_LEG(end.xyz[3], -x_base, -y_base, z_base);
			SET_LEG(end.xyz[4], -x_base, -delta_y, z_base - delta_z);
			SET_LEG(end.xyz[5], -x_base, y_base + delta_y - offset_l, z_base);
			move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);

			SET_LEG(end.xyz[0], x_base, y_base, z_base);
			SET_LEG(end.xyz[1], x_base, delta_y, z_base - delta_z);
			SET_LEG(end.xyz[2], x_base, -y_base - delta_y + offset_r, z_base);
			SET_LEG(end.xyz[3], -x_base, -y_base, z_base - delta_z);
			SET_LEG(end.xyz[4], -x_base, -delta_y, z_base);
			SET_LEG(end.xyz[5], -x_base, y_base + delta_y - offset_l, z_base - delta_z);
			move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);
		}

		if (manager->shouldStop(id))
		{
			break;
		}
	}

	if (!isBackward)
	{
		SET_LEG(end.xyz[0], x_base, y_base, z_base - delta_z);
		SET_LEG(end.xyz[1], x_base, delta_y, z_base);
		SET_LEG(end.xyz[2], x_base, -y_base, z_base - delta_z);
		SET_LEG(end.xyz[3], -x_base, -y_base, z_base);
		SET_LEG(end.xyz[4], -x_base, 0, z_base - delta_z);
		SET_LEG(end.xyz[5], -x_base, y_base + delta_y - offset_l, z_base);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);

		SET_LEG(end.xyz[0], x_base, y_base, z_base);
		SET_LEG(end.xyz[1], x_base, delta_y, z_base);
		SET_LEG(end.xyz[2], x_base, -y_base, z_base);
		SET_LEG(end.xyz[3], -x_base, -y_base, z_base);
		SET_LEG(end.xyz[4], -x_base, 0, z_base);
		SET_LEG(end.xyz[5], -x_base, y_base + delta_y - offset_l, z_base);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);

		SET_LEG(end.xyz[0], x_base, y_base, z_base);
		SET_LEG(end.xyz[1], x_base, 0, z_base - delta_z);
		SET_LEG(end.xyz[2], x_base, -y_base, z_base);
		SET_LEG(end.xyz[3], -x_base, -y_base, z_base - delta_z);
		SET_LEG(end.xyz[4], -x_base, 0, z_base);
		SET_LEG(end.xyz[5], -x_base, y_base, z_base - delta_z);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);
	}
	else
	{
		SET_LEG(end.xyz[0], x_base, y_base, z_base);
		SET_LEG(end.xyz[1], x_base, 0, z_base - delta_z);
		SET_LEG(end.xyz[2], x_base, -y_base - delta_y + offset_r, z_base);
		SET_LEG(end.xyz[3], -x_base, -y_base, z_base - delta_z);
		SET_LEG(end.xyz[4], -x_base, -delta_y, z_base);
		SET_LEG(end.xyz[5], -x_base, y_base, z_base - delta_z);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);

		SET_LEG(end.xyz[0], x_base, y_base, z_base);
		SET_LEG(end.xyz[1], x_base, 0, z_base);
		SET_LEG(end.xyz[2], x_base, -y_base - delta_y + offset_r, z_base);
		SET_LEG(end.xyz[3], -x_base, -y_base, z_base);
		SET_LEG(end.xyz[4], -x_base, -delta_y, z_base);
		SET_LEG(end.xyz[5], -x_base, y_base, z_base);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);

		SET_LEG(end.xyz[0], x_base, y_base, z_base - delta_z);
		SET_LEG(end.xyz[1], x_base, 0, z_base);
		SET_LEG(end.xyz[2], x_base, -y_base, z_base - delta_z);
		SET_LEG(end.xyz[3], -x_base, -y_base, z_base);
		SET_LEG(end.xyz[4], -x_base, 0, z_base - delta_z);
		SET_LEG(end.xyz[5], -x_base, y_base, z_base);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);
	}
}
