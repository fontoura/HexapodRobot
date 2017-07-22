/*
 * MagnetometerAdjuster.h
 *
 *  Created on: 06/04/2013
 */

#ifndef BOT_FIRMWARE_MAGNETOMETERADJUSTER_H_
#define BOT_FIRMWARE_MAGNETOMETERADJUSTER_H_

#include "../../globaldefs.h"
#include "../../base.h"
#include "../../concurrent.managed.h"
#include "../../concurrent.thread.h"
#include "../../bot/firmware/MagnetometerData.h"

#define ADJUSTER_SLEEP 100

namespace bot
{
	namespace firmware
	{
		class SensorsManager;

		class MagnetometerAdjuster :
			private concurrent::thread::ThreadBody,
			public virtual base::Object
		{
			private:
				/* pool de objetos. */
				friend class base::ObjectPool<MagnetometerAdjuster, 2>;
				static base::ObjectPool<MagnetometerAdjuster, 2> m_pool;

			private:
				MagnetometerData m_max;
				MagnetometerData m_min;
				_strong(SensorsManager) m_sensors;
				bool m_shouldStop;

			protected:
				/* construtor e destrutor. */
				MagnetometerAdjuster();
				~MagnetometerAdjuster();

				/* gerência de memória. */
				void initialize(_strong(SensorsManager)& sensors);
				void finalize();

			public:
				/* factory. */
				static MagnetometerAdjuster* create(_strong(SensorsManager)& sensors);

			protected:
				/* implementação de ThreadBody. */
				void run();

			public:
				/* comanda o ajustador a parar. */
				void stop();

				/* inicia a execução do ajustador do magnetômetro. */
				concurrent::thread::Thread* start();
		};
	}
}

#endif /* BOT_FIRMWARE_MAGNETOMETERADJUSTER_H_ */
