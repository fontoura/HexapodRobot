/*
 * MagnetometerAdjuster.cpp
 *
 *  Created on: 06/04/2013
 */

#include "../../bot/firmware/fw_defines.h"
#include "../../bot/firmware/MagnetometerAdjuster.h"
#include "../../bot/firmware/SensorsManager.h"

using namespace base;
using namespace concurrent::thread;
using namespace concurrent::semaphore;

/* macros para debug */
#ifdef DEBUG_bot_firmware_MovementAdjuster
#include <iostream>
#define DEBUG(v1) std::cout<<(v1)<<std::endl
#define DEBUG2(v1,v2) std::cout<<(v1)<<(v2)<<std::endl
#define DEBUG3(v1,v2,v3) std::cout<<(v1)<<(v2)<<(v3)<<std::endl
#define DEBUG4(v1,v2,v3,v4) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<std::endl
#define DEBUG5(v1,v2,v3,v4,v5) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<(v5)<<std::endl
#else /* ifndef DEBUG_bot_firmware_MovementAdjuster */
#define DEBUG(v1) {}
#define DEBUG2(v1,v2) {}
#define DEBUG3(v1,v2,v3) {}
#define DEBUG4(v1,v2,v3,v4) {}
#define DEBUG5(v1,v2,v3,v4,v5) {}
#endif /* DEBUG_bot_firmware_MovementAdjuster */

namespace bot
{
	namespace firmware
	{
		/* pool de objetos. */
		ObjectPool<MagnetometerAdjuster, 2> MagnetometerAdjuster::m_pool;

		/* construtor e destrutor. */
		MagnetometerAdjuster::MagnetometerAdjuster()
		{
			DEBUG("MagnetometerAdjuster alocado!");
			m_shouldStop = false;
		}

		MagnetometerAdjuster::~MagnetometerAdjuster()
		{
			DEBUG("MagnetometerAdjuster apagado!");
			m_sensors = NULL;
		}

		void MagnetometerAdjuster::initialize(_strong(SensorsManager)& sensors)
		{
			DEBUG("Inicializando MagnetometerAdjuster...");
			m_sensors = sensors;
			m_shouldStop = false;
		}

		void MagnetometerAdjuster::finalize()
		{
			DEBUG("Finalizando MagnetometerAdjuster...");
			m_sensors = NULL;
			Object::beforeRecycle();
			MagnetometerAdjuster::m_pool.recycle(this);
		}

		/* factory. */
		MagnetometerAdjuster* MagnetometerAdjuster::create(_strong(SensorsManager)& sensors)
		{
			DEBUG("Criando MagnetometerAdjuster...");
			MagnetometerAdjuster* magnetometerAdjuster = MagnetometerAdjuster::m_pool.obtain();
			if (magnetometerAdjuster != NULL)
			{
				magnetometerAdjuster->initialize(sensors);
			}
			return magnetometerAdjuster;
		}


		/* implementação de ThreadBody. */
		void MagnetometerAdjuster::run()
		{
			MagnetometerData buffer;
			m_sensors->readMagnetometer(buffer);
			m_min = buffer;
			m_max = buffer;
			DEBUG("MagnetometerAdjuster fez nova leitura...");
			while (true)
			{
				Thread::sleep(ADJUSTER_SLEEP);
				if (m_shouldStop)
				{
					break;
				}
				m_sensors->readMagnetometer(buffer);
				//DEBUG("MagnetometerAdjuster fez nova leitura...");
				for (int i = 0; i < 3; i ++)
				{
					if (m_min.xyz[i] > buffer.xyz[i])
					{
						m_min.xyz[i] = buffer.xyz[i];
					}
					if (m_max.xyz[i] < buffer.xyz[i])
					{
						m_max.xyz[i] = buffer.xyz[i];
					}
				}
			}
			//TODO atualiza os dados dos sensores.
			DEBUG("MAX");
			DEBUG5(m_max.xyz[0], "\t", m_max.xyz[1], "\t", m_max.xyz[2]);
			DEBUG("MIN");
			DEBUG5(m_min.xyz[0], "\t", m_min.xyz[1], "\t", m_min.xyz[2]);
			m_sensors->adjustMagnetometer(0, -(m_min.xyz[1] + m_max.xyz[1])/2, -(m_min.xyz[2] + m_max.xyz[2])/2);
		}

		void MagnetometerAdjuster::stop()
		{
			m_shouldStop = true;
		}

		Thread* MagnetometerAdjuster::start()
		{
			_strong(Thread) thread = Thread::create(this);
			thread->start();
			return thread.get();
		}
	}
}
