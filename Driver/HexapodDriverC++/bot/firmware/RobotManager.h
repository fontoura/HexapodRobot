/*
 * RobotManager.h
 *
 *  Created on: 22/03/2013
 */

#ifndef BOT_FIRMWARE_ROBOTMANAGER_H_
#define BOT_FIRMWARE_ROBOTMANAGER_H_

#include "../../globaldefs.h"
#include "../../base/all.h"
#include "../../concurrent/managed/all.h"

namespace bot
{
	namespace firmware
	{
		class MovementManager;
		class UartManager;
		class SensorsManager;

		/**
		 * Classe que gerencia o robô como um todo.
		 */
		class RobotManager :
			public base::Object
		{
			_pool_decl(RobotManager, 1)

			protected:
				/* construtor e destrutor. */
				RobotManager();
				~RobotManager();

				/* gerência de memória. */
				void initialize();
				void finalize();

			public:
				/* factory. */
				static RobotManager* create();

			protected:
				/* gerente de movimento. */
				_strong(MovementManager) m_movement;

				/* gerente de gerente de comunicação. */
				_strong(UartManager) m_uart;

				/* gerente de gerente dos sensores. */
				_strong(SensorsManager) m_sensors;

			public:
				/* getter e setter do gerente de movimento. */
				_strong(MovementManager)& getMovementManager();
				void setMovementManager(_strong(MovementManager)& value);

				/* getter e setter do gerente de comunicação. */
				_strong(UartManager)& getUartManager();
				void setUartManager(_strong(UartManager)& value);

				/* getter e setter do gerente dos sensores. */
				_strong(SensorsManager)& getSensorsManager();
				void setSensorsManager(_strong(SensorsManager)& value);
		};
	}
}

#endif /* BOT_FIRMWARE_ROBOTMANAGER_H_ */
