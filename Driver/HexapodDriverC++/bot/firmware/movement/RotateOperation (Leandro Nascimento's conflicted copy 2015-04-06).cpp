/*
 * RotateOperation.cpp
 *
 *  Created on: 28/03/2013
 */

#include "../../../bot/firmware/fw_defines.h"
#include "../../../bot/firmware/movement/fw_native.h"
#include "../../../bot/firmware/MovementManager.h"
#include "../../../bot/firmware/movement/RotateOperation.h"
#include "../../../bot/firmware/SensorsManager.h"
#include <math.h>

using namespace base;

/* macros para debug */
#ifdef DEBUG_bot_firmware_movement_RotateOperation
#include <iostream>
#define DEBUG(v1) std::cout<<(v1)<<std::endl
#define DEBUG2(v1,v2) std::cout<<(v1)<<(v2)<<std::endl
#define DEBUG3(v1,v2,v3) std::cout<<(v1)<<(v2)<<(v3)<<std::endl
#define DEBUG4(v1,v2,v3,v4) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<std::endl
#define DEBUG5(v1,v2,v3,v4,v5) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<(v5)<<std::endl
#else /* ifndef DEBUG_bot_firmware_movement_RotateOperation */
#define DEBUG(v1) {}
#define DEBUG2(v1,v2) {}
#define DEBUG3(v1,v2,v3) {}
#define DEBUG4(v1,v2,v3,v4) {}
#define DEBUG5(v1,v2,v3,v4,v5) {}
#endif /* DEBUG_bot_firmware_movement_RotateOperation */

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			void rotateMovement(_strong(MovementManager)& manager, int id, LegPositions& start, int &current_angle, int target_angle);
			void restPosition(LegPositions& start);

			/* pool de objetos. */
			ObjectPool<RotateOperation, POOLSIZE_bot_firmware_movement_RotateOperation> RotateOperation::m_pool;

			/* construtor e destrutor. */
			RotateOperation::RotateOperation()
			{
				m_isClock = false;
				m_startAngle = 0;
				m_currentAngle = 0;
				m_targetAngle = 0;
				DEBUG("RotateOperation alocado!");
			}

			RotateOperation::~RotateOperation()
			{
				DEBUG("RotateOperation apagado!");
			}

			/* gerência de memória. */
			void RotateOperation::initialize(int angle, bool isClock, bool isDelta, MagnetometerData& data)
			{
				DEBUG5("Inicializando RotateOperation(angle = ", angle, ", ", isClock ? "clockwise" : "counterclockwise", ")...");
				m_startAngle = (int)data.heading;
				m_currentAngle = m_startAngle;
				if (isDelta)
				{
					if (isClock)
					{
						m_targetAngle = m_startAngle - angle;
					}
					else
					{
						m_targetAngle = m_startAngle + angle;
					}

					if(m_targetAngle < 0)
					{
						m_targetAngle += 360;
					} else if (m_targetAngle > 360)
					{
						m_targetAngle -= 360;
					}
				}
				else
				{
					// nesse caso o isClock não faz sentido... ignora.
					m_targetAngle = angle;
				}

			}

			void RotateOperation::finalize()
			{
				DEBUG("Finalizando RotateOperation...");
				Object::beforeRecycle();
				RotateOperation::m_pool.recycle(this);
			}

			/* factory. */
			RotateOperation* RotateOperation::create(int angle, bool isClock, bool isDelta, MagnetometerData& data)
			{
				DEBUG("Criando RotateOperation...");
				RotateOperation* rotate = RotateOperation::m_pool.obtain();
				if (rotate)
				{
					rotate->initialize(angle, isClock, isDelta, data);
				}
				return rotate;
			}

			/* implementação de MovementOperation. */
			int RotateOperation::getLength()
			{
				return abs(m_targetAngle - m_startAngle);
			}

			/* implementação de MovementOperation. */
			int RotateOperation::getValue()
			{
				return abs(m_currentAngle - m_startAngle);
			}

			/* implementação de MovementOperation. */
			void RotateOperation::run(int id, LegPositions& position, _strong(MovementManager)& manager)
			{
				manager->getSensors()->setEnabled(false);
				manager->getSensors()->refresh();
				MagnetometerData data;
				manager->getSensors()->readMagnetometer(data);
				m_currentAngle = data.heading;
				rotateMovement(manager, id, position, m_currentAngle, m_targetAngle);
				manager->getSensors()->setEnabled(true);
			}
		}
	}
}

#include <string.h>

using namespace bot::firmware;
using namespace bot::firmware::movement;

void bot::firmware::movement::rotateMovement(_strong(MovementManager)& manager, int id, LegPositions& start, int &current_angle, int target_angle)
{
	MagnetometerData data;
	LegPositions interpol[NUM_INTERPOL];
	LegPositions end;

	int delay_movimentacao = (int)10e3; //em us

	int delta_y = 50;
	int delta_z = 10;
	int y_base2 = y_base;
	int min_error = 2;
	int P = 277;



	int error = target_angle - current_angle;
	bool isClock;

	while(abs(error) > min_error)
	{
		if(error > 180)
		{
			error -= 360;
		} else if (error < -180)
		{
			error += 360;
		}

		if (error > 0)
		{
			isClock = false;
		}
		else
		{
			isClock = true;
		}

		delta_y = (int)P*abs(error)/100;

		if (delta_y > 50)
		{
			delta_y = 50;
		}

		if (isClock)
		{
			SET_LEG(end.xyz[0], x_base, y_base2 + delta_y, z_base);
			SET_LEG(end.xyz[1], x_base, 0, z_base);
			SET_LEG(end.xyz[2], x_base, -y_base2, z_base);
			SET_LEG(end.xyz[3], -x_base, -y_base2 - delta_y, z_base);
			SET_LEG(end.xyz[4], -x_base, 0, z_base);
			SET_LEG(end.xyz[5], -x_base, y_base2, z_base);
			move<NUM_INTERPOL>(delay_movimentacao/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);

			SET_LEG(end.xyz[0], x_base, y_base2 + delta_y, z_base - delta_z);
			SET_LEG(end.xyz[1], x_base, 0, z_base);
			SET_LEG(end.xyz[2], x_base, -y_base2, z_base - delta_z);
			SET_LEG(end.xyz[3], -x_base, -y_base2 - delta_y, z_base);
			SET_LEG(end.xyz[4], -x_base, 0, z_base - delta_z);
			SET_LEG(end.xyz[5], -x_base, y_base2, z_base);
			move<NUM_INTERPOL>(delay_movimentacao/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);

			SET_LEG(end.xyz[0], x_base, y_base2, z_base - delta_z);
			SET_LEG(end.xyz[1], x_base, 0, z_base);
			SET_LEG(end.xyz[2], x_base, -y_base2 - delta_y, z_base - delta_z);
			SET_LEG(end.xyz[3], -x_base, -y_base2 - delta_y, z_base);
			SET_LEG(end.xyz[4], -x_base, delta_y, z_base - delta_z);
			SET_LEG(end.xyz[5], -x_base, y_base2, z_base);
			move<NUM_INTERPOL>(delay_movimentacao/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);

			SET_LEG(end.xyz[0], x_base, y_base2, z_base);
			SET_LEG(end.xyz[1], x_base, 0, z_base);
			SET_LEG(end.xyz[2], x_base, -y_base2 - delta_y, z_base);
			SET_LEG(end.xyz[3], -x_base, -y_base2 - delta_y, z_base);
			SET_LEG(end.xyz[4], -x_base, delta_y, z_base);
			SET_LEG(end.xyz[5], -x_base, y_base2, z_base);
			move<NUM_INTERPOL>(delay_movimentacao/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);

			SET_LEG(end.xyz[0], x_base, y_base2, z_base);
			SET_LEG(end.xyz[1], x_base, 0, z_base - delta_z);
			SET_LEG(end.xyz[2], x_base, -y_base2 - delta_y, z_base);
			SET_LEG(end.xyz[3], -x_base, -y_base2 - delta_y, z_base - delta_z);
			SET_LEG(end.xyz[4], -x_base, delta_y, z_base);
			SET_LEG(end.xyz[5], -x_base, y_base2, z_base - delta_z);
			move<NUM_INTERPOL>(delay_movimentacao/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);

			SET_LEG(end.xyz[0], x_base, y_base2, z_base);
			SET_LEG(end.xyz[1], x_base, -delta_y, z_base - delta_z);
			SET_LEG(end.xyz[2], x_base, -y_base2 - delta_y, z_base);
			SET_LEG(end.xyz[3], -x_base, -y_base2, z_base - delta_z);
			SET_LEG(end.xyz[4], -x_base, delta_y, z_base);
			SET_LEG(end.xyz[5], -x_base, y_base2 + delta_y, z_base - delta_z);
			move<NUM_INTERPOL>(delay_movimentacao/NUM_INTERPOL, interpol, start, end);
			COPY_ALL(start.xyz, end.xyz);

			SET_LEG(end.xyz[0], x_base, y_base2, z_base);
			SET_LEG(end.xyz[1], x_base, -delta_y, z_base);
			SET_LEG(end.xyz[2], x_base, -y_base2 - delta_y, z_base);
			SET_LEG(end.xyz[3], -x_base, -y_base2, z_base);
			SET_LEG(end.xyz[4], -x_base, delta_y, z_base);
			SET_LEG(end.xyz[5], -x_base, y_base2 + delta_y, z_base);
			move<NUM_INTERPOL>(delay_movimentacao/NUM_INTERPOL, interpol, start, end);
		}
		else
		{
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
		}
		if (manager->shouldStop(id))
		{
			break;
		}
		manager->getSensors()->refresh();
		manager->getSensors()->readMagnetometer(data);
		current_angle = (int)data.heading;
		error = target_angle - current_angle;

	}

};

