/*
 * AdjustOperation.cpp
 *
 *  Created on: 06/04/2013
 */

#include "../fw_defines.h"
#include "./AdjustOperation.h"
#include "./movements.h"
#include "../SensorsManager.h"
#include "../MovementManager.h"
#include "../../../drivers/InterpolationDriver.h"

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

#define N_ADJUST_CYCLES 22


namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			_pool_inst(AdjustOperation, POOLSIZE_bot_firmware_movement_AdjustOperation)

			/* construtor e destrutor. */
			AdjustOperation::AdjustOperation()
			{
				DEBUG("AdjustOperation alocado!");
				m_total = N_ADJUST_CYCLES;
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
				_del_inst(AdjustOperation);
			}

			/* factory. */
			AdjustOperation* AdjustOperation::create()
			{
				DEBUG("Criando AdjustOperation...");
				_new_inst(AdjustOperation, rotate);
				rotate->initialize();
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
			void AdjustOperation::run(int id, _strong(MovementManager)& manager)
			{
				MovementManager* managerPtr = manager.get();
				SensorsManager* sensorsPtr = managerPtr->getSensors().get();
				drivers::InterpolationDriver* driverPtr = managerPtr->getDriver().get();

				// desativa a captura automática dos sensores.
				sensorsPtr->setEnabled(false);
				sensorsPtr->refresh();

				// faz o ajuste de fato.
				if (managerPtr->isMoving())
				{
					rotateToAdjust(driverPtr, managerPtr, sensorsPtr, id, m_current, m_total);
					restPosition(driverPtr);
				}

				// reativa a captura automática dos sensores.
				sensorsPtr->setEnabled(true);
			}
		}
	}
}
