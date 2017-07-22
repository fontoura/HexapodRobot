/*
 * AdjustOperation.cpp
 *
 *  Created on: 06/04/2013
 */

#include "../../../bot/firmware/fw_defines.h"
#include "../../../bot/firmware/movement/fw_native.h"
#include "../../../bot/firmware/SensorsManager.h"
#include "../../../bot/firmware/MovementManager.h"
#include "../../../bot/firmware/movement/AdjustOperation.h"

using namespace base;

/* macros para debug */
#ifdef DEBUG_bot_firmware_movement_AdjustOperation
#include <iostream>
#define DEBUG(v1) std::cout<<(v1)<<std::endl
#define DEBUG2(v1,v2) std::cout<<(v1)<<(v2)<<std::endl
#define DEBUG3(v1,v2,v3) std::cout<<(v1)<<(v2)<<(v3)<<std::endl
#define DEBUG4(v1,v2,v3,v4) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<std::endl
#define DEBUG5(v1,v2,v3,v4,v5) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<(v5)<<std::endl
#else /* ifndef DEBUG_bot_firmware_movement_AdjustOperation */
#define DEBUG(v1) {}
#define DEBUG2(v1,v2) {}
#define DEBUG3(v1,v2,v3) {}
#define DEBUG4(v1,v2,v3,v4) {}
#define DEBUG5(v1,v2,v3,v4,v5) {}
#endif /* DEBUG_bot_firmware_movement_AdjustOperation */

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			void rotateAdjusting(LegPositions& start);
			void restPosition(LegPositions& start);

			/* pool de objetos. */
			ObjectPool<AdjustOperation, POOLSIZE_bot_firmware_movement_AdjustOperation> AdjustOperation::m_pool;

			/* construtor e destrutor. */
			AdjustOperation::AdjustOperation()
			{
				DEBUG("AdjustOperation alocado!");
				m_total = 30;
			}

			AdjustOperation::~AdjustOperation()
			{
				DEBUG("AdjustOperation apagado!");
			}

			/* gerência de memória. */
			void AdjustOperation::initialize()
			{
				DEBUG("Inicializando AdjustOperation...");
			}

			void AdjustOperation::finalize()
			{
				DEBUG("Finalizando AdjustOperation...");
				Object::beforeRecycle();
				AdjustOperation::m_pool.recycle(this);
			}

			/* factory. */
			AdjustOperation* AdjustOperation::create()
			{
				DEBUG("Criando AdjustOperation...");
				AdjustOperation* rotate = AdjustOperation::m_pool.obtain();
				if (rotate)
				{
					rotate->initialize();
				}
				return rotate;
			}

			/* implementação de MovementOperation. */
			int AdjustOperation::getLength()
			{
				return m_total;
			}

			/* implementação de MovementOperation. */
			int AdjustOperation::getValue()
			{
				return m_current;
			}

			/* implementação de MovementOperation. */
			void AdjustOperation::run(int id, LegPositions& position, _strong(MovementManager)& manager)
			{
				manager->getSensors()->setEnabled(false);
				DEBUG("AdjustOperation esta em andamento");
				for (m_current = 0; m_current < m_total; m_current ++)
				{
					// atualiza a leitura dos sensores.
					manager->getSensors()->refresh();

					if (manager->shouldStop(id))
					{
						break;
					}
					rotateAdjusting(position);
				}
				DEBUG("AdjustOperation terminou");
				restPosition(position);
				manager->getSensors()->setEnabled(true);
			}
		}
	}
}

#include <string.h>

using namespace bot::firmware;
using namespace bot::firmware::movement;

void bot::firmware::movement::rotateAdjusting(LegPositions& start)
{
	LegPositions interpol[NUM_INTERPOL];

	int delay_movimentacao = (int)10e3; //em us

	int delta_y = 50;
	int delta_z = 10;
	int y_base2 = y_base / 2;

	LegPositions end;

	SET_LEG(end.xyz[0], x_base, y_base2, z_base);
	SET_LEG(end.xyz[1], x_base, 0, z_base);
	SET_LEG(end.xyz[2], x_base, -y_base2 - delta_y, z_base);
	SET_LEG(end.xyz[3], -x_base, -y_base2, z_base);
	SET_LEG(end.xyz[4], -x_base, 0, z_base);
	SET_LEG(end.xyz[5], -x_base, y_base2 + delta_y, z_base);
	move<NUM_INTERPOL>(delay_movimentacao/NUM_INTERPOL, interpol, start, end);
	COPY_ALL(start.xyz, end.xyz);

	SET_LEG(end.xyz[0], x_base, y_base2, z_base - delta_z);
	SET_LEG(end.xyz[1], x_base, 0, z_base);
	SET_LEG(end.xyz[2], x_base, -y_base2 - delta_y, z_base - delta_z);
	SET_LEG(end.xyz[3], -x_base, -y_base2, z_base);
	SET_LEG(end.xyz[4], -x_base, 0, z_base - delta_z);
	SET_LEG(end.xyz[5], -x_base, y_base2 + delta_y, z_base);
	move<NUM_INTERPOL>(delay_movimentacao/NUM_INTERPOL, interpol, start, end);
	COPY_ALL(start.xyz, end.xyz);

	SET_LEG(end.xyz[0], x_base, y_base2 + delta_y, z_base - delta_z);
	SET_LEG(end.xyz[1], x_base, 0, z_base);
	SET_LEG(end.xyz[2], x_base, -y_base2, z_base - delta_z);
	SET_LEG(end.xyz[3], -x_base, -y_base2, z_base);
	SET_LEG(end.xyz[4], -x_base, -delta_y, z_base - delta_z);
	SET_LEG(end.xyz[5], -x_base, y_base2 + delta_y, z_base);
	move<NUM_INTERPOL>(delay_movimentacao/NUM_INTERPOL, interpol, start, end);
	COPY_ALL(start.xyz, end.xyz);

	SET_LEG(end.xyz[0], x_base, y_base2 + delta_y, z_base);
	SET_LEG(end.xyz[1], x_base, 0, z_base);
	SET_LEG(end.xyz[2], x_base, -y_base2, z_base);
	SET_LEG(end.xyz[3], -x_base, -y_base2, z_base);
	SET_LEG(end.xyz[4], -x_base, -delta_y, z_base);
	SET_LEG(end.xyz[5], -x_base, y_base2 + delta_y, z_base);
	move<NUM_INTERPOL>(delay_movimentacao/NUM_INTERPOL, interpol, start, end);
	COPY_ALL(start.xyz, end.xyz);

	SET_LEG(end.xyz[0], x_base, y_base2 + delta_y, z_base);
	SET_LEG(end.xyz[1], x_base, 0, z_base - delta_z);
	SET_LEG(end.xyz[2], x_base, -y_base2, z_base);
	SET_LEG(end.xyz[3], -x_base, -y_base2, z_base - delta_z);
	SET_LEG(end.xyz[4], -x_base, -delta_y, z_base);
	SET_LEG(end.xyz[5], -x_base, y_base2 + delta_y, z_base - delta_z);
	move<NUM_INTERPOL>(delay_movimentacao/NUM_INTERPOL, interpol, start, end);
	COPY_ALL(start.xyz, end.xyz);

	SET_LEG(end.xyz[0], x_base, y_base2 + delta_y, z_base);
	SET_LEG(end.xyz[1], x_base, delta_y, z_base - delta_z);
	SET_LEG(end.xyz[2], x_base, -y_base2, z_base);
	SET_LEG(end.xyz[3], -x_base, -y_base2 - delta_y, z_base - delta_z);
	SET_LEG(end.xyz[4], -x_base, -delta_y, z_base);
	SET_LEG(end.xyz[5], -x_base, y_base2, z_base - delta_z);
	move<NUM_INTERPOL>(delay_movimentacao/NUM_INTERPOL, interpol, start, end);
	COPY_ALL(start.xyz, end.xyz);

	SET_LEG(end.xyz[0], x_base, y_base2 + delta_y, z_base);
	SET_LEG(end.xyz[1], x_base, delta_y, z_base);
	SET_LEG(end.xyz[2], x_base, -y_base2, z_base);
	SET_LEG(end.xyz[3], -x_base, -y_base2 - delta_y, z_base);
	SET_LEG(end.xyz[4], -x_base, -delta_y, z_base);
	SET_LEG(end.xyz[5], -x_base, y_base2, z_base);
	move<NUM_INTERPOL>(delay_movimentacao/NUM_INTERPOL, interpol, start, end);
	COPY_ALL(start.xyz, end.xyz);
};
