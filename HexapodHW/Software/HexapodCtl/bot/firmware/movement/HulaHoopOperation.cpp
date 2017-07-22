/*
 * HulaHoopOperation.cpp
 *
 *  Created on: 05/04/2013
 */

#include "../fw_defines.h"
#include "./HulaHoopOperation.h"
#include "./movements.h"
#include "../MovementManager.h"
#include "../SensorsManager.h"
#include "../../../drivers/InterpolationDriver.h"

using namespace base;

/* macros para debug */

#include <iostream>
#ifdef DEBUG_bot_firmware_movement_HulaHoopOperation
#define DEBUG(v1) std::cout<<(v1)<<std::endl
#define DEBUG2(v1,v2) std::cout<<(v1)<<(v2)<<std::endl
#define DEBUG3(v1,v2,v3) std::cout<<(v1)<<(v2)<<(v3)<<std::endl
#define DEBUG4(v1,v2,v3,v4) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<std::endl
#define DEBUG5(v1,v2,v3,v4,v5) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<(v5)<<std::endl
#else /* ifndef DEBUG_bot_firmware_movement_HulaHoopOperation */
#define DEBUG(v1) {}
#define DEBUG2(v1,v2) {}
#define DEBUG3(v1,v2,v3) {}
#define DEBUG4(v1,v2,v3,v4) {}
#define DEBUG5(v1,v2,v3,v4,v5) {}
#endif /* DEBUG_bot_firmware_movement_HulaHoopOperation */

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			_pool_inst(HulaHoopOperation, POOLSIZE_bot_firmware_movement_HulaHoopOperation)

			/* construtor e destrutor. */
			HulaHoopOperation::HulaHoopOperation()
			{
				m_cycles = 0;
				m_totalCycles = 0;
				DEBUG("HulaHoopOperation alocado!");
			}

			HulaHoopOperation::~HulaHoopOperation()
			{
				DEBUG("HulaHoopOperation apagado!");
			}

			/* gerência de memória. */
			void HulaHoopOperation::initialize(int cycles)
			{
				DEBUG3("Inicializando HulaHoopOperation(cycles = ", cycles, ")...");
				m_cycles = 0;
				m_totalCycles = cycles;
			}

			void HulaHoopOperation::finalize()
			{
				DEBUG("Finalizando HulaHoopOperation...");
				_del_inst(HulaHoopOperation);
			}

			/* factory. */
			HulaHoopOperation* HulaHoopOperation::create(int cycles)
			{
				DEBUG("Criando HulaHoopOperation...");
				_new_inst(HulaHoopOperation, hulaHoop);
				hulaHoop->initialize(cycles);
				return hulaHoop;
			}

			/* implementação de MovementOperation. */
			int HulaHoopOperation::getLength()
			{
				return m_totalCycles;
			}

			/* implementação de MovementOperation. */
			int HulaHoopOperation::getValue()
			{
				return m_cycles;
			}

			/* implementação de MovementOperation. */
			void HulaHoopOperation::run(int id, _strong(MovementManager)& manager)
			{
				MovementManager* managerPtr = manager.get();
				SensorsManager* sensorsPtr = managerPtr->getSensors().get();
				drivers::InterpolationDriver* driverPtr = managerPtr->getDriver().get();

				// desativa a captura automática dos sensores.
				sensorsPtr->setEnabled(false);
				sensorsPtr->refresh();

				// faz as bamboleadas.
				hulaHoop(driverPtr, managerPtr, sensorsPtr, id, m_cycles, m_totalCycles);
				restPosition(driverPtr);

				// reativa a captura automática dos sensores.
				sensorsPtr->setEnabled(true);
			}
		}
	}
}
