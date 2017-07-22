/*
 * RotateOperation.cpp
 *
 *  Created on: 28/03/2013
 */

#include "../fw_defines.h"
#include "./RotateOperation.h"
#include "./movements.h"
#include "../MovementManager.h"
#include "../SensorsManager.h"
#include "../../../drivers/InterpolationDriver.h"

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
			/* pool de objetos. */
			_pool_inst(RotateOperation, POOLSIZE_bot_firmware_movement_RotateOperation)

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
				_del_inst(RotateOperation);
			}

			/* factory. */
			RotateOperation* RotateOperation::create(int angle, bool isClock, bool isDelta, MagnetometerData& data)
			{
				DEBUG("Criando RotateOperation...");
				_new_inst(RotateOperation, rotate);
				rotate->initialize(angle, isClock, isDelta, data);
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
			void RotateOperation::run(int id, _strong(MovementManager)& manager)
			{
				MovementManager* managerPtr = manager.get();
				SensorsManager* sensorsPtr = managerPtr->getSensors().get();
				drivers::InterpolationDriver* driverPtr = managerPtr->getDriver().get();

				// desativa a captura automática dos sensores.
				sensorsPtr->setEnabled(false);
				sensorsPtr->refresh();

				// lê dados do magnetômetro.
				{
					MagnetometerData data;
					sensorsPtr->readMagnetometer(data);
					m_currentAngle = (int)data.heading;
				}

				// faz a rotação.
				rotateArroundZ(driverPtr, managerPtr, sensorsPtr, id, m_currentAngle, m_targetAngle);
				restPosition(driverPtr);

				// reativa a captura automática dos sensores.
				sensorsPtr->setEnabled(true);
			}
		}
	}
}

