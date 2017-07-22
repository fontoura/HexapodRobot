/*
 * WalkSidewaysOperation.cpp
 *
 *  Created on: 05/04/2013
 */

#include "../../../bot/firmware/fw_defines.h"
#include "../../../bot/firmware/movement/fw_native.h"
#include "../../../bot/firmware/MovementManager.h"
#include "../../../bot/firmware/movement/WalkSidewaysOperation.h"

using namespace base;

/* macros para debug */
#ifdef DEBUG_bot_firmware_movement_WalkSidewaysOperation
#include <iostream>
#define DEBUG(v1) std::cout<<(v1)<<std::endl
#define DEBUG2(v1,v2) std::cout<<(v1)<<(v2)<<std::endl
#define DEBUG3(v1,v2,v3) std::cout<<(v1)<<(v2)<<(v3)<<std::endl
#define DEBUG4(v1,v2,v3,v4) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<std::endl
#define DEBUG5(v1,v2,v3,v4,v5) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<(v5)<<std::endl
#else /* ifndef DEBUG_bot_firmware_movement_WalkSidewaysOperation */
#define DEBUG(v1) {}
#define DEBUG2(v1,v2) {}
#define DEBUG3(v1,v2,v3) {}
#define DEBUG4(v1,v2,v3,v4) {}
#define DEBUG5(v1,v2,v3,v4,v5) {}
#endif /* DEBUG_bot_firmware_movement_WalkSidewaysOperation */

#define DELAY_MOVIMENTACAO ((int)10e3)

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			void restPosition(LegPositions& start);
			void walkMovementSideways(_strong(MovementManager)& manager, int id, LegPositions& start, int& steps, int totalSteps, bool isLeftToRight);

			/* pool de objetos. */
			ObjectPool<WalkSidewaysOperation, POOLSIZE_bot_firmware_movement_WalkSidewaysOperation> WalkSidewaysOperation::m_pool;

			/* construtor e destrutor. */
			WalkSidewaysOperation::WalkSidewaysOperation()
			{
				m_isLeftToRight = false;
				m_walkedDistance = 0;
				m_totalDistance = 0;
				DEBUG("WalkSidewaysOperation alocado!");
			}

			WalkSidewaysOperation::~WalkSidewaysOperation()
			{
				DEBUG("WalkSidewaysOperation apagado!");
			}

			/* gerência de memória. */
			void WalkSidewaysOperation::initialize(int distance, bool isLeftToRight)
			{
				DEBUG5("Inicializando WalkSidewaysOperation(distance = ", distance, ", ", isLeftToRight ? "leftToRight" : "rightToLeft", ")...");
				m_isLeftToRight = isLeftToRight;
				m_walkedDistance = 0;
				m_totalDistance = distance;
			}

			void WalkSidewaysOperation::finalize()
			{
				DEBUG("Finalizando WalkSidewaysOperation...");
				Object::beforeRecycle();
				WalkSidewaysOperation::m_pool.recycle(this);
			}

			/* factory. */
			WalkSidewaysOperation* WalkSidewaysOperation::create(bool isLeftToRight, int distance)
			{
				DEBUG("Criando WalkSidewaysOperation...");
				WalkSidewaysOperation* walk = WalkSidewaysOperation::m_pool.obtain();
				if (walk != NULL)
				{
					walk->initialize(distance, isLeftToRight);
				}
				return walk;
			}

			/* implementação de MovementOperation. */
			int WalkSidewaysOperation::getLength()
			{
				return m_totalDistance;
			}

			/* implementação de MovementOperation. */
			int WalkSidewaysOperation::getValue()
			{
				return m_walkedDistance;
			}

			/* implementação de MovementOperation. */
			void WalkSidewaysOperation::run(int id, LegPositions& position, _strong(MovementManager)& manager)
			{
				walkMovementSideways(manager, id, position, m_walkedDistance, m_totalDistance, m_isLeftToRight);
				restPosition(position);
			}
		}
	}
}

using namespace bot::firmware;
using namespace bot::firmware::movement;

void bot::firmware::movement::walkMovementSideways(_strong(MovementManager)& manager, int id, LegPositions& start, int& steps, int totalSteps, bool isLeftToRight)
{
	LegPositions interpol[NUM_INTERPOL];
	LegPositions end;

	int delta_z = 10;
	int delta_x = 25;

	if (isLeftToRight)
	{
		SET_LEG(end.xyz[0], x_base + delta_x, y_base/2, z_base - delta_z);
		SET_LEG(end.xyz[1], x_base, 0, z_base);
		SET_LEG(end.xyz[2], x_base + delta_x, -y_base/2, z_base - delta_z);
		SET_LEG(end.xyz[3], -x_base, -y_base, z_base);
		SET_LEG(end.xyz[4], -x_base, 0, z_base);
		SET_LEG(end.xyz[5], -x_base, y_base, z_base);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);

		SET_LEG(end.xyz[0], x_base + delta_x, y_base/2, z_base);
		SET_LEG(end.xyz[1], x_base, 0, z_base);
		SET_LEG(end.xyz[2], x_base + delta_x, -y_base/2, z_base);
		SET_LEG(end.xyz[3], -x_base, -y_base, z_base);
		SET_LEG(end.xyz[4], -x_base, 0, z_base);
		SET_LEG(end.xyz[5], -x_base, y_base, z_base);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);

		SET_LEG(end.xyz[0], x_base + delta_x, y_base/2, z_base);
		SET_LEG(end.xyz[1], x_base, 0, z_base - delta_z);
		SET_LEG(end.xyz[2], x_base + delta_x, -y_base/2, z_base);
		SET_LEG(end.xyz[3], -x_base - delta_x, -y_base/2, z_base - delta_z);
		SET_LEG(end.xyz[4], -x_base, 0, z_base);
		SET_LEG(end.xyz[5], -x_base - delta_x, y_base/2, z_base - delta_z);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);
	}
	else
	{
		SET_LEG(end.xyz[0], x_base, y_base, z_base);
		SET_LEG(end.xyz[1], x_base, 0, z_base);
		SET_LEG(end.xyz[2], x_base, -y_base, z_base);
		SET_LEG(end.xyz[3], -x_base - delta_x, -y_base/2, z_base - delta_z);
		SET_LEG(end.xyz[4], -x_base, 0, z_base);
		SET_LEG(end.xyz[5], -x_base - delta_x, y_base/2, z_base - delta_z);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);

		SET_LEG(end.xyz[0], x_base, y_base, z_base);
		SET_LEG(end.xyz[1], x_base, 0, z_base);
		SET_LEG(end.xyz[2], x_base, -y_base, z_base);
		SET_LEG(end.xyz[3], -x_base - delta_x, -y_base/2, z_base);
		SET_LEG(end.xyz[4], -x_base, 0, z_base);
		SET_LEG(end.xyz[5], -x_base - delta_x, y_base/2, z_base);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);

		SET_LEG(end.xyz[0], x_base + delta_x, y_base/2, z_base - delta_z);
		SET_LEG(end.xyz[1], x_base, 0, z_base);
		SET_LEG(end.xyz[2], x_base + delta_x, -y_base/2, z_base - delta_z);
		SET_LEG(end.xyz[3], -x_base - delta_x, -y_base/2, z_base);
		SET_LEG(end.xyz[4], -x_base, 0, z_base - delta_z);
		SET_LEG(end.xyz[5], -x_base - delta_x, y_base/2, z_base);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);
	}

	for (steps = 0; steps < totalSteps; steps ++)
	{
		DEBUG("WalkSidewaysOperation esta em andamento");

		if (isLeftToRight)
		{
			//O conjunto 0/2/4 vai do chao pra esquerda e o 1/3/5 do ar pra direita
			SET_LEG(end.xyz[0], x_base, y_base/2, z_base);
			SET_LEG(end.xyz[1], x_base + delta_x, 0, z_base - delta_z);
			SET_LEG(end.xyz[2], x_base, -y_base/2, z_base);
			SET_LEG(end.xyz[3], -x_base, -y_base/2, z_base - delta_z);
			SET_LEG(end.xyz[4], -x_base - delta_x, 0, z_base);
			SET_LEG(end.xyz[5], -x_base, y_base/2, z_base  - delta_z);
			move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);

			//O conjunto 0/2/4 vai pro ar e o 1/3/5 vai pro chao
			SET_LEG(end.xyz[0], x_base, y_base/2, z_base - delta_z);
			SET_LEG(end.xyz[1], x_base + delta_x, 0, z_base);
			SET_LEG(end.xyz[2], x_base, -y_base/2, z_base - delta_z);
			SET_LEG(end.xyz[3], -x_base, -y_base/2, z_base);
			SET_LEG(end.xyz[4], -x_base - delta_x, 0, z_base - delta_z);
			SET_LEG(end.xyz[5], -x_base, y_base/2, z_base);
			move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);

			//O conjunto 0/2/4 vai do ar pra direita e o 1/3/5 vai do chao pra esquerda
			SET_LEG(end.xyz[0], x_base + delta_x, y_base/2, z_base - delta_z);
			SET_LEG(end.xyz[1], x_base, 0, z_base);
			SET_LEG(end.xyz[2], x_base + delta_x, -y_base/2, z_base - delta_z);
			SET_LEG(end.xyz[3], -x_base - delta_x, -y_base/2, z_base);
			SET_LEG(end.xyz[4], -x_base, 0, z_base - delta_z);
			SET_LEG(end.xyz[5], -x_base - delta_x, y_base/2, z_base);
			move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);

			//O conjunto 0/2/4 vai pro chao e o 1/3/5 vai pro ar
			SET_LEG(end.xyz[0], x_base + delta_x, y_base/2, z_base);
			SET_LEG(end.xyz[1], x_base, 0, z_base - delta_z);
			SET_LEG(end.xyz[2], x_base + delta_x, -y_base/2, z_base);
			SET_LEG(end.xyz[3], -x_base - delta_x, -y_base/2, z_base - delta_z);
			SET_LEG(end.xyz[4], -x_base, 0, z_base);
			SET_LEG(end.xyz[5], -x_base - delta_x, y_base/2, z_base - delta_z);
			move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);
		}
		else
		{
			//O conjunto 0/2/4 vai do ar pra esquerda e o 1/3/5 do chao pra direita
			SET_LEG(end.xyz[0], x_base, y_base/2, z_base - delta_z);
			SET_LEG(end.xyz[1], x_base + delta_x, 0, z_base);
			SET_LEG(end.xyz[2], x_base, -y_base/2, z_base - delta_z);
			SET_LEG(end.xyz[3], -x_base, -y_base/2, z_base);
			SET_LEG(end.xyz[4], -x_base - delta_x, 0, z_base - delta_z);
			SET_LEG(end.xyz[5], -x_base, y_base/2, z_base);
			move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);

			//O conjunto 0/2/4 vai pro chao e o 1/3/5 vai pro ar
			SET_LEG(end.xyz[0], x_base, y_base/2, z_base);
			SET_LEG(end.xyz[1], x_base + delta_x, 0, z_base - delta_z);
			SET_LEG(end.xyz[2], x_base, -y_base/2, z_base);
			SET_LEG(end.xyz[3], -x_base, -y_base/2, z_base - delta_z);
			SET_LEG(end.xyz[4], -x_base - delta_x, 0, z_base);
			SET_LEG(end.xyz[5], -x_base, y_base/2, z_base - delta_z);
			move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);

			//O conjunto 0/2/4 vai do chao pra direita e o 1/3/5 vai do chao pra esquerda
			SET_LEG(end.xyz[0], x_base + delta_x, y_base/2, z_base);
			SET_LEG(end.xyz[1], x_base, 0, z_base - delta_z);
			SET_LEG(end.xyz[2], x_base + delta_x, -y_base/2, z_base);
			SET_LEG(end.xyz[3], -x_base - delta_x, -y_base/2, z_base - delta_z);
			SET_LEG(end.xyz[4], -x_base, 0, z_base);
			SET_LEG(end.xyz[5], -x_base - delta_x, y_base/2, z_base - delta_z);
			move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);

			//O conjunto 0/2/4 vai pro ar e o 1/3/5 vai pro chao
			SET_LEG(end.xyz[0], x_base + delta_x, y_base/2, z_base - delta_z);
			SET_LEG(end.xyz[1], x_base, 0, z_base);
			SET_LEG(end.xyz[2], x_base + delta_x, -y_base/2, z_base - delta_z);
			SET_LEG(end.xyz[3], -x_base - delta_x, -y_base/2, z_base);
			SET_LEG(end.xyz[4], -x_base, 0, z_base - delta_z);
			SET_LEG(end.xyz[5], -x_base - delta_x, y_base/2, z_base);
			move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);
		}

		if (manager->shouldStop(id))
		{
			break;
		}
	}

	if (isLeftToRight)
	{
		SET_LEG(end.xyz[0], x_base + delta_x, y_base/2, z_base);
		SET_LEG(end.xyz[1], x_base, 0, z_base);
		SET_LEG(end.xyz[2], x_base + delta_x, -y_base/2, z_base);
		SET_LEG(end.xyz[3], -x_base, -y_base, z_base - delta_z);
		SET_LEG(end.xyz[4], -x_base, 0, z_base);
		SET_LEG(end.xyz[5], -x_base, y_base, z_base - delta_z);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);

		SET_LEG(end.xyz[0], x_base + delta_x, y_base/2, z_base);
		SET_LEG(end.xyz[1], x_base, 0, z_base);
		SET_LEG(end.xyz[2], x_base + delta_x, -y_base/2, z_base);
		SET_LEG(end.xyz[3], -x_base, -y_base, z_base);
		SET_LEG(end.xyz[4], -x_base, 0, z_base);
		SET_LEG(end.xyz[5], -x_base, y_base, z_base);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);

		SET_LEG(end.xyz[0], x_base, y_base, z_base - delta_z);
		SET_LEG(end.xyz[1], x_base, 0, z_base);
		SET_LEG(end.xyz[2], x_base, -y_base, z_base - delta_z);
		SET_LEG(end.xyz[3], -x_base, -y_base, z_base);
		SET_LEG(end.xyz[4], -x_base, 0, z_base);
		SET_LEG(end.xyz[5], -x_base, y_base, z_base);
	}
	else
	{
		SET_LEG(end.xyz[0], x_base, y_base, z_base - delta_z);
		SET_LEG(end.xyz[1], x_base, 0, z_base);
		SET_LEG(end.xyz[2], x_base, -y_base, z_base - delta_z);
		SET_LEG(end.xyz[3], -x_base - delta_x, -y_base/2, z_base);
		SET_LEG(end.xyz[4], -x_base, 0, z_base - delta_z);
		SET_LEG(end.xyz[5], -x_base - delta_x, y_base/2, z_base);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);

		SET_LEG(end.xyz[0], x_base, y_base, z_base);
		SET_LEG(end.xyz[1], x_base, 0, z_base);
		SET_LEG(end.xyz[2], x_base, -y_base, z_base);
		SET_LEG(end.xyz[3], -x_base - delta_x, -y_base/2, z_base);
		SET_LEG(end.xyz[4], -x_base, 0, z_base);
		SET_LEG(end.xyz[5], -x_base - delta_x, y_base/2, z_base);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);

		SET_LEG(end.xyz[0], x_base, y_base, z_base);
		SET_LEG(end.xyz[1], x_base, 0, z_base);
		SET_LEG(end.xyz[2], x_base, -y_base, z_base);
		SET_LEG(end.xyz[3], -x_base, -y_base, z_base - delta_z);
		SET_LEG(end.xyz[4], -x_base, 0, z_base);
		SET_LEG(end.xyz[5], -x_base, y_base, z_base - delta_z);
		move<NUM_INTERPOL>(DELAY_MOVIMENTACAO/NUM_INTERPOL, interpol, start, end);
		COPY_ALL(start.xyz, end.xyz);
	}
}
