/*
 * WalkOperation.cpp
 *
 *  Created on: 28/03/2013
 */

#include "../fw_defines.h"
#include "./WalkOperation.h"
#include "./movements.h"
#include "../MovementManager.h"
#include "../SensorsManager.h"
#include "../../../drivers/InterpolationDriver.h"

using namespace base;

/* macros para debug */
#include <iostream>
#ifdef DEBUG_bot_firmware_movement_WalkOperation
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

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			_pool_inst(WalkOperation, POOLSIZE_bot_firmware_movement_WalkOperation)

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
				_del_inst(WalkOperation);
			}

			/* factory. */
			WalkOperation* WalkOperation::create(int distance, int angle, bool isAligned, bool isBackward)
			{
				DEBUG("Criando WalkOperation...");
				_new_inst(WalkOperation, walk);
				walk->initialize(distance, angle, isAligned, isBackward);
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
			void WalkOperation::run(int id, _strong(MovementManager)& manager)
			{
				MovementManager* managerPtr = manager.get();
				SensorsManager* sensorsPtr = managerPtr->getSensors().get();
				drivers::InterpolationDriver* driverPtr = managerPtr->getDriver().get();

				// desativa a captura automática dos sensores.
				sensorsPtr->setEnabled(false);
				sensorsPtr->refresh();

				// faz o pré-alinhamento, se necessário.
				if (m_isAligned)
				{
					// lê dados do magnetômetro.
					int angle;
					{
						MagnetometerData data;
						sensorsPtr->readMagnetometer(data);
						angle = (int)data.heading;
					}

					// faz a rotação.
					rotateArroundZ(driverPtr, managerPtr, sensorsPtr, id, angle, m_targetAngle);
					restPosition(driverPtr);
				}

				// anda de fato.
				if (managerPtr->isMoving())
				{
					walkAlongY(driverPtr, managerPtr, sensorsPtr, id, m_walkedDistance, m_totalDistance, m_targetAngle, m_isBackward, m_isAligned);
					restPosition(driverPtr);
				}

				// reativa a captura automática dos sensores.
				sensorsPtr->setEnabled(true);
			}
		}
	}
}
