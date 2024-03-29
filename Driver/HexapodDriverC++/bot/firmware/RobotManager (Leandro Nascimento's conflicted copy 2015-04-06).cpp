/*
 * RobotManager.cpp
 *
 *  Created on: 22/03/2013
 */

#include "../../bot/firmware/fw_defines.h"
#include "../../bot/firmware/RobotManager.h"

using namespace base;

/* macros para debug */
#ifdef DEBUG_bot_firmware_RobotManager
#include <iostream>
#define DEBUG(v1) std::cout<<(v1)<<std::endl
#define DEBUG2(v1,v2) std::cout<<(v1)<<(v2)<<std::endl
#define DEBUG3(v1,v2,v3) std::cout<<(v1)<<(v2)<<(v3)<<std::endl
#define DEBUG4(v1,v2,v3,v4) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<std::endl
#define DEBUG5(v1,v2,v3,v4,v5) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<(v5)<<std::endl
#else /* ifndef DEBUG_bot_firmware_RobotManager */
#define DEBUG(v1) {}
#define DEBUG2(v1,v2) {}
#define DEBUG3(v1,v2,v3) {}
#define DEBUG4(v1,v2,v3,v4) {}
#define DEBUG5(v1,v2,v3,v4,v5) {}
#endif /* DEBUG_bot_firmware_RobotManager */

namespace bot
{
	namespace firmware
	{
		/* pool de objetos. */
		ObjectPool<RobotManager, 1> RobotManager::m_pool;

		/* construtor e destrutor. */
		RobotManager::RobotManager()
		{
			DEBUG("RobotManager alocado!");
		}

		RobotManager::~RobotManager()
		{
			DEBUG("RobotManager apagado!");
		}

		/* gerência de memória. */
		void RobotManager::initialize()
		{
			DEBUG("Inicializando RobotManager...");
		}

		void RobotManager::finalize()
		{
			DEBUG("Finalizando RobotManager...");
			Object::beforeRecycle();
			RobotManager::m_pool.recycle(this);
		}

		/* factory. */
		RobotManager* RobotManager::create()
		{
			DEBUG("Criando RobotManager...");
			RobotManager* robotManager = RobotManager::m_pool.obtain();
			if (robotManager != NULL)
			{
				robotManager->initialize();
			}
			return robotManager;
		}

		/* getter e setter do gerente de movimento. */
		_strong(MovementManager)& RobotManager::getMovementManager()
		{
			return m_movement;
		}

		void RobotManager::setMovementManager(_strong(MovementManager)& value)
		{
			m_movement = value;
		}

		/* getter e setter do gerente de comunicação. */
		_strong(UartManager)& RobotManager::getUartManager()
		{
			return m_uart;
		}

		void RobotManager::setUartManager(_strong(UartManager)& value)
		{
			m_uart = value;
		}

		/* getter e setter do gerente dos sensores. */
		_strong(SensorsManager)& RobotManager::getSensorsManager()
		{
			return m_sensors;
		}

		void RobotManager::setSensorsManager(_strong(SensorsManager)& value)
		{
			m_sensors = value;
		}
	}
}

