/*
 * SensorsManager.cpp
 *
 *  Created on: 06/04/2013
 */

#include "./fw_defines.h"
#include "./SensorsManager.h"
#include "./SensorsManager.h"

using namespace base;
using namespace concurrent::thread;
using namespace concurrent::semaphore;

#include <string.h>
#include <math.h>
#include "../../utils.h"
#include "../../constants.h"
#include "../../i2c/interface_i2c.h"
#include "../../i2c/magnetometer_i2c.h"
#include "../../spi/adxl345_interface.h"

#define ACCELEROMETER_SPI_MG_PER_DIGI 3.9f
#define ACCELEROMETER_SPI_OFFSET_X -43.21f /* -Z => X na conversão (essa é a correção do -Z do acelerômetro antes da conversão) */
#define ACCELEROMETER_SPI_OFFSET_Y -10.61f /*  X => Y na conversão (essa é a correção do  X do acelerômetro antes da conversão) */
#define ACCELEROMETER_SPI_OFFSET_Z -1.47f  /* -Y => Z na conversão (essa é a correção do -Y do acelerômetro antes da conversão) */

/* macros para debug */
#ifdef DEBUG_bot_firmware_SensorsManager
#include <iostream>
#define DEBUG(v1) std::cout<<(v1)<<std::endl
#define DEBUG2(v1,v2) std::cout<<(v1)<<(v2)<<std::endl
#define DEBUG3(v1,v2,v3) std::cout<<(v1)<<(v2)<<(v3)<<std::endl
#define DEBUG4(v1,v2,v3,v4) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<std::endl
#define DEBUG5(v1,v2,v3,v4,v5) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<(v5)<<std::endl
#else /* ifndef DEBUG_bot_firmware_SensorsManager */
#define DEBUG(v1) {}
#define DEBUG2(v1,v2) {}
#define DEBUG3(v1,v2,v3) {}
#define DEBUG4(v1,v2,v3,v4) {}
#define DEBUG5(v1,v2,v3,v4,v5) {}
#endif /* DEBUG_bot_firmware_SensorsManager */

namespace bot
{
	namespace firmware
	{
		_pool_inst(SensorsManager, 1)

		/* construtor e destrutor. */
		SensorsManager::SensorsManager()
		{
			DEBUG("SensorsManager alocado!");
			m_adjustX = 0;
			m_adjustY = 0;
			m_adjustZ = 0;
			m_isEnabled = true;
		}

		SensorsManager::~SensorsManager()
		{
			DEBUG("SensorsManager apagado!");
		}

		/* gerência de memória. */
		void SensorsManager::initialize()
		{
			DEBUG("Inicializando SensorsManager...");
			m_adjustX = 0;
			m_adjustY = 0;
			m_adjustZ = 0;
			m_isEnabled = true;
#ifdef __NIOS2__
			m_adjustY = MAGNETOMETER_OFFSET_Y;
			m_adjustZ = MAGNETOMETER_OFFSET_Z;
			i2c_set_clock((int)100e6, (int)400e3);
			magnetometer_i2c_init(); // megnetômetro por I2C
			accelerometer_init(); // acelerômetro por SPI
#endif /* __NIOS2__ */
			m_mutex = Semaphore::create(0, 1);
		}

		void SensorsManager::finalize()
		{
			DEBUG("Finalizando SensorsManager...");
			// TODO finalizar sensores!
			m_mutex = NULL;
			_del_inst(SensorsManager);
		}

		/* factory. */
		SensorsManager* SensorsManager::create()
		{
			DEBUG("Criando SensorsManager...");
			_new_inst(SensorsManager, sensorsManager);
			sensorsManager->initialize();
			return sensorsManager;
		}

		void SensorsManager::readSensors(MagnetometerData& magnetometer, AccelerometerData& accelerometer)
		{
#ifdef __NIOS2__
			int16_t xyz[3];
			int16_t xyz2[3];
			accelerometer_read(xyz2);
			accelerometer_coordinate_conversion((uint16_t*)xyz, (uint16_t*)xyz2);
			accelerometer.xyz[0] = (ACCELEROMETER_SPI_OFFSET_X + xyz[0]) * ACCELEROMETER_SPI_MG_PER_DIGI;
			accelerometer.xyz[1] = (ACCELEROMETER_SPI_OFFSET_Y + xyz[1]) * ACCELEROMETER_SPI_MG_PER_DIGI;
			accelerometer.xyz[2] = (ACCELEROMETER_SPI_OFFSET_Z + xyz[2]) * ACCELEROMETER_SPI_MG_PER_DIGI;

			magnetometer_i2c_read(magnetometer.xyz);
#else
			magnetometer.xyz[0] = 100;
			magnetometer.xyz[1] = 100;
			magnetometer.xyz[2] = 100;
			accelerometer.xyz[0] = 980;
			accelerometer.xyz[1] = 0;
			accelerometer.xyz[2] = 0;
#endif /* __NIOS2__ */
			magnetometer.xyz[2] += m_adjustZ;
			magnetometer.xyz[1] += m_adjustY;
			magnetometer.xyz[0] += m_adjustX;
			magnetometer.heading = rad_to_deg(atan2(magnetometer.xyz[2], magnetometer.xyz[1]) + PI);
		}

		/* implementação de ThreadBody. */
		void SensorsManager::run()
		{
			this->readSensors(m_magnetometer, m_accelerometer);
			m_mutex->up();
			Thread::sleep(10);
			while (true)
			{
				if (m_isEnabled)
				{
					this->refresh();
					Thread::sleep(10);
				} else {
					Thread::sleep(1000);
				}
			}
		}

		void SensorsManager::refresh()
		{
			MagnetometerData magnetometer;
			AccelerometerData accelerometer;
			this->readSensors(magnetometer, accelerometer);

			m_mutex->down();
			m_magnetometer = magnetometer;
			m_accelerometer = accelerometer;

//			DEBUG3("LEITURA DO MAGNETOMETRO: ", m_magnetometer.heading, " GRAUS");
//			DEBUG5(m_magnetometer.xyz[0], '\t', m_magnetometer.xyz[1], '\t', m_magnetometer.xyz[2]);
//
//			DEBUG("LEITURA DO ACELEROMETRO");
//			DEBUG5(m_accelerometer.xyz[0], '\t', m_accelerometer.xyz[1], '\t', m_accelerometer.xyz[2]);

			m_mutex->up();
		}

		void SensorsManager::setEnabled(bool value)
		{
			m_isEnabled = value;
		}

		bool SensorsManager::isEnabled()
		{
			return m_isEnabled;
		}

		void SensorsManager::readMagnetometer(MagnetometerData& magnetometer)
		{
			m_mutex->down();
			magnetometer.xyz[0] = m_magnetometer.xyz[0];
			magnetometer.xyz[1] = m_magnetometer.xyz[1];
			magnetometer.xyz[2] = m_magnetometer.xyz[2];
			magnetometer.heading = m_magnetometer.heading;
			m_mutex->up();
		}

		void SensorsManager::readAccelerometer(AccelerometerData& accelerometer)
		{
			m_mutex->down();
			accelerometer.xyz[0] = m_accelerometer.xyz[0];
			accelerometer.xyz[1] = m_accelerometer.xyz[1];
			accelerometer.xyz[2] = m_accelerometer.xyz[2];
			m_mutex->up();
		}

		void SensorsManager::start()
		{
			_strong(Thread) thread = Thread::create(this);
			//thread->setPriority(LowThreadPriority);
			thread->start();
		}

		void SensorsManager::adjustMagnetometer(int offsetX, int offsetY, int offsetZ)
		{
			m_mutex->down();
			DEBUG4("Ajustando: Y=", offsetY, ", Z=", offsetZ);
			m_adjustX += offsetX;
			m_adjustY += offsetY;
			m_adjustZ += offsetZ;
			m_mutex->up();
		}
	}
}
