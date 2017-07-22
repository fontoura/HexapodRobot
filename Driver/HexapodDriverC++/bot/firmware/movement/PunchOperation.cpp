/*
 * PunchOperation.cpp
 *
 *  Created on: 04/05/2013
 */

#include "../fw_defines.h"
#include "./PunchOperation.h"
#include "./movements.h"
#include "../MovementManager.h"
#include "../SensorsManager.h"
#include "../../../drivers/InterpolationDriver.h"

using namespace base;

/* macros para debug */
#ifdef DEBUG_bot_firmware_movement_PunchOperation
#include <iostream>
#define DEBUG(v1) std::cout<<(v1)<<std::endl
#define DEBUG2(v1,v2) std::cout<<(v1)<<(v2)<<std::endl
#define DEBUG3(v1,v2,v3) std::cout<<(v1)<<(v2)<<(v3)<<std::endl
#define DEBUG4(v1,v2,v3,v4) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<std::endl
#define DEBUG5(v1,v2,v3,v4,v5) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<(v5)<<std::endl
#else /* ifndef DEBUG_bot_firmware_movement_PunchOperation */
#define DEBUG(v1) {}
#define DEBUG2(v1,v2) {}
#define DEBUG3(v1,v2,v3) {}
#define DEBUG4(v1,v2,v3,v4) {}
#define DEBUG5(v1,v2,v3,v4,v5) {}
#endif /* DEBUG_bot_firmware_movement_PunchOperation */

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			_pool_inst(PunchOperation, POOLSIZE_bot_firmware_movement_PunchOperation)

			/* construtor e destrutor. */
			PunchOperation::PunchOperation()
			{
				m_punches = 0;
				m_totalPunches = 0;
				DEBUG("PunchOperation alocado!");
			}

			PunchOperation::~PunchOperation()
			{
				DEBUG("PunchOperation apagado!");
			}

			/* gerência de memória. */
			void PunchOperation::initialize(int punches)
			{
				DEBUG3("Inicializando PunchOperation(punches = ", punches, ")...");
				m_punches = 0;
				m_totalPunches = punches;
			}

			void PunchOperation::finalize()
			{
				DEBUG("Finalizando PunchOperation...");
				_del_inst(PunchOperation);
			}

			/* factory. */
			PunchOperation* PunchOperation::create(int punches)
			{
				DEBUG("Criando PunchOperation...");
				_new_inst(PunchOperation, punch);
				punch->initialize(punches);
				return punch;
			}

			/* implementacão de MovementOperation. */
			int PunchOperation::getLength()
			{
				return m_totalPunches;
			}

			/* implementa��o de MovementOperation. */
			int PunchOperation::getValue()
			{
				return m_punches;
			}

			/* implementcão de MovementOperation. */
			void PunchOperation::run(int id, _strong(MovementManager)& manager)
			{
				for (; m_punches < m_totalPunches; m_punches ++)
				{
					DEBUG("PunchOperation esta em andamento");
					// TODO implementar sequência de movimentos.
					concurrent::thread::Thread::sleep(100);
					if (manager->shouldStop(id))
					{
						break;
					}
				}
			}
		}
	}
}
