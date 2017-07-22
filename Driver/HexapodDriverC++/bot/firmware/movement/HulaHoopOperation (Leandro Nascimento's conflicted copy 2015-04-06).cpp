/*
 * HulaHoopOperation.cpp
 *
 *  Created on: 05/04/2013
 */

#include "../../../bot/firmware/fw_defines.h"
#include "../../../bot/firmware/movement/fw_native.h"
#include "../../../bot/firmware/MovementManager.h"
#include "../../../bot/firmware/movement/HulaHoopOperation.h"

using namespace base;

/* macros para debug */
#ifdef DEBUG_bot_firmware_movement_HulaHoopOperation
#include <iostream>
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
			void restPosition(LegPositions& start);

			/* pool de objetos. */
			ObjectPool<HulaHoopOperation, POOLSIZE_bot_firmware_movement_HulaHoopOperation> HulaHoopOperation::m_pool;

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
				Object::beforeRecycle();
				HulaHoopOperation::m_pool.recycle(this);
			}

			/* factory. */
			HulaHoopOperation* HulaHoopOperation::create(int cycles)
			{
				DEBUG("Criando HulaHoopOperation...");
				HulaHoopOperation* hulaHoop = HulaHoopOperation::m_pool.obtain();
				if (hulaHoop != NULL)
				{
					hulaHoop->initialize(cycles);
				}
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
			void HulaHoopOperation::run(int id, LegPositions& position, _strong(MovementManager)& manager)
			{
				for (; m_cycles < m_totalCycles; m_cycles ++)
				{
					DEBUG("HulaHoopOperation esta em andamento");
					// TODO implementar sequência de movimentos.
					concurrent::thread::Thread::sleep(100);
					if (manager->shouldStop(id))
					{
						break;
					}
				}
				restPosition(position);
			}
		}
	}
}

