/*
 * SensorsManager.h
 *
 *  Created on: 06/04/2013
 */

#ifndef BOT_FIRMWARE_SENSORSMANAGER_H_
#define BOT_FIRMWARE_SENSORSMANAGER_H_

#include "../../globaldefs.h"
#include "../../base.h"
#include "../../concurrent.managed.h"
#include "../../concurrent.thread.h"
#include "../../concurrent.semaphore.h"
#include "../../bot/firmware/MagnetometerData.h"
#include "../../bot/firmware/AccelerometerData.h"

namespace bot
{
	namespace firmware
	{
		class RobotManager;
		class MovementOperation;

		/**
		 * Classe que gerencia leituras de sensores.
		 */
		class SensorsManager :
			private concurrent::thread::ThreadBody,
			public virtual base::Object
		{
			private:
				/* pool de objetos. */
					friend class base::ObjectPool<SensorsManager, 1>;
					static base::ObjectPool<SensorsManager, 1> m_pool;

			protected:
				/* construtor e destrutor. */
				SensorsManager();
				~SensorsManager();

				/* gerência de memória. */
				void initialize();
				void finalize();

			public:
				/* factory. */
				static SensorsManager* create();

			protected:
				/* dados do magnetômetro. */
				MagnetometerData m_magnetometer;

				/* dados do acelerômetro. */
				AccelerometerData m_accelerometer;

				/* mutex de acesso à leitura dos sensores. */
				_strong(concurrent::semaphore::Semaphore) m_mutex;

				bool m_isEnabled;

				int m_adjustX;
				int m_adjustY;
				int m_adjustZ;

				/* método interno que faz a leitura dos sensores. */
				void readSensors(MagnetometerData& magnetometer, AccelerometerData& accelerometer);

				/* implementação de ThreadBody. */
				void run();

			public:
				/* força a atualização dos sensores. */
				void refresh();
				void setEnabled(bool value);
				bool isEnabled();

				/* lê a leitura atual do magnetômetro. */
				void readMagnetometer(MagnetometerData& magnetometer);

				/* lê a leitura atual do acelerômetro. */
				void readAccelerometer(AccelerometerData& accelerometer);

				/* começa a execução do sistema de leitura de sensores. */
				void start();

				/* aplica um ajuste nas leituras do magnetômetro. */
				void adjustMagnetometer(int offsetX, int offsetY, int offsetZ);
		};
	}
}

#endif /* BOT_FIRMWARE_SENSORSMANAGER_H_ */
