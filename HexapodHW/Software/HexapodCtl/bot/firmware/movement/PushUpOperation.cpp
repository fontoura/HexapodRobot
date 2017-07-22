/*
 * PushUpOperation.cpp
 *
 *  Created on: 05/04/2013
 */

#include "../fw_defines.h"
#include "./PushUpOperation.h"
#include "./movements.h"
#include "../MovementManager.h"
#include "../SensorsManager.h"
#include "../../../drivers/InterpolationDriver.h"

using namespace base;

/* macros para debug */
#include <iostream>
#ifdef DEBUG_bot_firmware_movement_PushUpOperation
#define DEBUG(v1) std::cout<<(v1)<<std::endl
#define DEBUG2(v1,v2) std::cout<<(v1)<<(v2)<<std::endl
#define DEBUG3(v1,v2,v3) std::cout<<(v1)<<(v2)<<(v3)<<std::endl
#define DEBUG4(v1,v2,v3,v4) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<std::endl
#define DEBUG5(v1,v2,v3,v4,v5) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<(v5)<<std::endl
#else /* ifndef DEBUG_bot_firmware_movement_PushUpOperation */
#define DEBUG(v1) {}
#define DEBUG2(v1,v2) {}
#define DEBUG3(v1,v2,v3) {}
#define DEBUG4(v1,v2,v3,v4) {}
#define DEBUG5(v1,v2,v3,v4,v5) {}
#endif /* DEBUG_bot_firmware_movement_PushUpOperation */

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			_pool_inst(PushUpOperation, POOLSIZE_bot_firmware_movement_PushUpOperation)

			/* construtor e destrutor. */
			PushUpOperation::PushUpOperation()
			{
				m_pushUps = 0;
				m_totalPushUps = 0;
				DEBUG("PushUpOperation alocado!");
			}

			PushUpOperation::~PushUpOperation()
			{
				DEBUG("PushUpOperation apagado!");
			}

			/* gerência de memória. */
			void PushUpOperation::initialize(int pushUps)
			{
				DEBUG3("Inicializando PushUpOperation(pushUps = ", pushUps, ")...");
				m_pushUps = 0;
				m_totalPushUps = pushUps;
			}

			void PushUpOperation::finalize()
			{
				DEBUG("Finalizando PushUpOperation...");
				_del_inst(PushUpOperation);
			}

			/* factory. */
			PushUpOperation* PushUpOperation::create(int pushUps)
			{
				DEBUG("Criando PushUpOperation...");
				_new_inst(PushUpOperation, pushUp);
				pushUp->initialize(pushUps);
				return pushUp;
			}

			/* implementação de MovementOperation. */
			int PushUpOperation::getLength()
			{
				return m_totalPushUps;
			}

			/* implementação de MovementOperation. */
			int PushUpOperation::getValue()
			{
				return m_pushUps;
			}

			/* implementação de MovementOperation. */
			void PushUpOperation::run(int id, _strong(MovementManager)& manager)
			{
				MovementManager* managerPtr = manager.get();
				SensorsManager* sensorsPtr = managerPtr->getSensors().get();
				drivers::InterpolationDriver* driverPtr = managerPtr->getDriver().get();

				// desativa a captura automática dos sensores.
				sensorsPtr->setEnabled(false);
				sensorsPtr->refresh();

				// faz as flexões.
				pushUp(driverPtr, managerPtr, sensorsPtr, id, m_pushUps, m_totalPushUps);
				restPosition(driverPtr);

				// reativa a captura automática dos sensores.
				sensorsPtr->setEnabled(true);
			}
		}
	}
}
