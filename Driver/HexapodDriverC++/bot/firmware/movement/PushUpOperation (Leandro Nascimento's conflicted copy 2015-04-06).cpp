/*
 * PushUpOperation.cpp
 *
 *  Created on: 05/04/2013
 */

#include "../../../bot/firmware/fw_defines.h"
#include "../../../bot/firmware/movement/fw_native.h"
#include "../../../bot/firmware/MovementManager.h"
#include "../../../bot/firmware/movement/PushUpOperation.h"

using namespace base;

/* macros para debug */
#ifdef DEBUG_bot_firmware_movement_PushUpOperation
#include <iostream>
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
			/* pool de objetos. */
			ObjectPool<PushUpOperation, POOLSIZE_bot_firmware_movement_PushUpOperation> PushUpOperation::m_pool;

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
				Object::beforeRecycle();
				PushUpOperation::m_pool.recycle(this);
			}

			/* factory. */
			PushUpOperation* PushUpOperation::create(int pushUps)
			{
				DEBUG("Criando PushUpOperation...");
				PushUpOperation* pushUp = PushUpOperation::m_pool.obtain();
				if (pushUp != NULL)
				{
					pushUp->initialize(pushUps);
				}
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
			void PushUpOperation::run(int id, LegPositions& position, _strong(MovementManager)& manager)
			{
				for (; m_pushUps < m_totalPushUps; m_pushUps ++)
				{
					DEBUG("PushUpOperation esta em andamento");
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
