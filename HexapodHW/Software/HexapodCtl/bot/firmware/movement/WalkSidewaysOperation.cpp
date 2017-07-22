/*
 * WalkSidewaysOperation.cpp
 *
 *  Created on: 05/04/2013
 */

#include "../fw_defines.h"
#include "./WalkSidewaysOperation.h"
#include "./movements.h"
#include "../MovementManager.h"
#include "../SensorsManager.h"
#include "../../../drivers/InterpolationDriver.h"

using namespace base;

/* macros para debug */
#include <iostream>

#ifdef DEBUG_bot_firmware_movement_WalkSidewaysOperation
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

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			/* pool de objetos. */
			_pool_inst(WalkSidewaysOperation, POOLSIZE_bot_firmware_movement_WalkSidewaysOperation)

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
				_del_inst(WalkSidewaysOperation);
			}

			/* factory. */
			WalkSidewaysOperation* WalkSidewaysOperation::create(bool isLeftToRight, int distance)
			{
				DEBUG("Criando WalkSidewaysOperation...");
				_new_inst(WalkSidewaysOperation, walk);
				walk->initialize(distance, isLeftToRight);
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
			void WalkSidewaysOperation::run(int id, _strong(MovementManager)& manager)
			{
				MovementManager* managerPtr = manager.get();
				SensorsManager* sensorsPtr = managerPtr->getSensors().get();
				drivers::InterpolationDriver* driverPtr = managerPtr->getDriver().get();

				// desativa a captura automática dos sensores.
				sensorsPtr->setEnabled(false);
				sensorsPtr->refresh();

				// anda para o lado.
				walkAlongX(driverPtr, managerPtr, sensorsPtr, id, m_walkedDistance, m_totalDistance, m_isLeftToRight);
				restPosition(driverPtr);

				// reativa a captura automática dos sensores.
				sensorsPtr->setEnabled(true);
			}
		}
	}
}
