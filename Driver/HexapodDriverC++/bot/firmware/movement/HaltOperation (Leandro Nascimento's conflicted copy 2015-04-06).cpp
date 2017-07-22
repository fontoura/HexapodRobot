/*
 * HaltOperation.cpp
 *
 *  Created on: 28/03/2013
 */

#include "../../../bot/firmware/fw_defines.h"
#include "../../../bot/firmware/MovementManager.h"
#include "../../../bot/firmware/movement/HaltOperation.h"
#include "../../../bot/firmware/movement/fw_native.h"

using namespace base;

/* macros para debug */
#ifdef DEBUG_bot_firmware_movement_HaltOperation
#include <iostream>
#define DEBUG(v1) std::cout<<(v1)<<std::endl
#define DEBUG2(v1,v2) std::cout<<(v1)<<(v2)<<std::endl
#define DEBUG3(v1,v2,v3) std::cout<<(v1)<<(v2)<<(v3)<<std::endl
#define DEBUG4(v1,v2,v3,v4) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<std::endl
#define DEBUG5(v1,v2,v3,v4,v5) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<(v5)<<std::endl
#else /* ifndef DEBUG_bot_firmware_movement_HaltOperation */
#define DEBUG(v1) {}
#define DEBUG2(v1,v2) {}
#define DEBUG3(v1,v2,v3) {}
#define DEBUG4(v1,v2,v3,v4) {}
#define DEBUG5(v1,v2,v3,v4,v5) {}
#endif /* DEBUG_bot_firmware_movement_HaltOperation */

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			void restPosition(LegPositions& start);
			void initPosition(LegPositions& start);

			/* pool de objetos. */
			ObjectPool<HaltOperation, 1> HaltOperation::m_pool;

			/* construtor e destrutor. */
			HaltOperation::HaltOperation()
			{
				DEBUG("HaltOperation alocado!");
			}

			HaltOperation::~HaltOperation()
			{
				DEBUG("HaltOperation apagado!");
			}

			/* gerência de memória. */
			void HaltOperation::initialize()
			{
				DEBUG("Inicializando HaltOperation...");
			}

			void HaltOperation::finalize()
			{
				DEBUG("Finalizando HaltOperation...");
				Object::beforeRecycle();
				HaltOperation::m_pool.recycle(this);
			}

			/* factory. */
			HaltOperation* HaltOperation::create()
			{
				DEBUG("Criando HaltOperation...");
				HaltOperation* halt = HaltOperation::m_pool.obtain();
				if (halt != NULL)
				{
					halt->initialize();
				}
				return halt;
			}

			/* implementação de MovementOperation. */
			int HaltOperation::getLength()
			{
				return 1;
			}

			/* implementação de MovementOperation. */
			int HaltOperation::getValue()
			{
				return 1;
			}

			/* implementação de MovementOperation. */
			void HaltOperation::run(int id, LegPositions& position, _strong(MovementManager)& manager)
			{
			}
		}
	}
}

#include <string.h>

using namespace bot::firmware;
using namespace bot::firmware::movement;

void bot::firmware::movement::initPosition(LegPositions& start)
{
	LegPositions interpol[NUM_INTERPOL];

	int delay_movimentacao = (int)10e3; //em us

	LegPositions end;

	SET_LEG(end.xyz[0], x_base, y_base, z_base);
	SET_LEG(end.xyz[1], x_base, 0, z_base);
	SET_LEG(end.xyz[2], x_base, -y_base, z_base);
	SET_LEG(end.xyz[3], -x_base, -y_base, z_base);
	SET_LEG(end.xyz[4], -x_base, 0, z_base);
	SET_LEG(end.xyz[5], -x_base, y_base, z_base);
	COPY_ALL(start.xyz, end.xyz);
	move<NUM_INTERPOL>(delay_movimentacao/NUM_INTERPOL, interpol, start, end);
}

void bot::firmware::movement::restPosition(LegPositions& start)
{
	LegPositions interpol[NUM_INTERPOL];

	int delay_movimentacao = (int)10e3; //em us

	LegPositions end;

	SET_LEG(end.xyz[0], x_base, y_base, z_base);
	SET_LEG(end.xyz[1], x_base, 0, z_base);
	SET_LEG(end.xyz[2], x_base, -y_base, z_base);
	SET_LEG(end.xyz[3], -x_base, -y_base, z_base);
	SET_LEG(end.xyz[4], -x_base, 0, z_base);
	SET_LEG(end.xyz[5], -x_base, y_base, z_base);
	move<NUM_INTERPOL>(delay_movimentacao/NUM_INTERPOL, interpol, start, end);
	COPY_ALL(start.xyz, end.xyz);
}
