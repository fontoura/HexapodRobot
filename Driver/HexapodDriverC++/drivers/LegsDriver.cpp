/*
 * LegsDriver.cpp
 *
 *  Created on: 09/09/2013
 */

#include "LegsDriver.h"
#include "../globaldefs.h"
#include "../base/all.h"

#ifdef __NIOS2__
#include <system.h>
#include <altera_avalon_pio_regs.h>
#endif

namespace drivers
{
	/**
	 * Implementação do driver das patas.
	 */
	class LegsDriverImpl :
		public LegsDriver
	{
		friend class LegsDriver;
		_pool_decl(LegsDriverImpl, 1)

		protected:
			LegsDriverImpl();
			~LegsDriverImpl();
			void initialize();
			void finalize();

		public:
			bool flush();
	};

	_pool_inst(LegsDriverImpl, 1)

	LegsDriver* LegsDriver::create()
	{
		_new_inst(LegsDriverImpl, driver);
		driver->initialize();
		return driver;
	}

	LegsDriverImpl::LegsDriverImpl()
	{
	}

	LegsDriverImpl::~LegsDriverImpl()
	{
	}

	void LegsDriverImpl::initialize()
	{
		LegsDriver::initialize();
	}

	void LegsDriverImpl::finalize()
	{
		_del_inst(LegsDriverImpl);
	}

	bool LegsDriverImpl::flush()
	{
#ifdef __NIOS2__
		// sinais de saída:
		// - update_flag: quando é 1, borda de subida no clock faz com que todos os ângulos armazenados sejam enviados para os motores.
		// - wrcoord: quando é 1, borda de subida no clock faz com que os ângulos calculados para a pata atual sejam armazenados.
		// - reset: quando é 1, borda de subida no clock reinicia a máquina de estados de cálculo de ângulo.
		// - legselect: número da pata usado como parâmetro de entrada da máquina de estados de cálculo de ângulo.
		// - x, y, z: coordenadas cartesianas da pata usadas como parâmetro de entrada da máquina de estados de cálculo de ângulo.
		// sinais de entrada:
		// - endcalc: quando é 1, indica que a máquina de estados de cálculo de ângulo chegou ao estado final, então os ângulos para a pata atual foram calculados.

		// limpa os sinais "update_flag" e "wrcoord".
		IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_UPDATEFLAG_BASE, 0);
		IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_WRCOORD_BASE, 0);

		for (int i = 0; i < 6; i++)
		{
			if (m_legs[i].changed)
			{
				int x = m_legs[i].x;
				int y = m_legs[i].y;
				int z = m_legs[i].z;
				m_legs[i].changed = false;

				// se a pata for da esquerda, inverte a direção dos valores.
				if (i >= 3)
				{
					x = -x;
					y = -y;
				}

				// desliga a máquina de estados de cálculo de ângulo.
				IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_RESET_BASE, 1);

				// define os parâmetros para cálculo de ângulo.
				IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_LEGSELECT_BASE, i);
				IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_X_BASE, x);
				IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_Y_BASE, y);
				IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_Z_BASE, z);

				// liga novamente a máquina de estados de cálculo de ângulo.
				IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_RESET_BASE, 0);

				// espera até terminar o cálculo dos ângulos para a pata atual.
				while (IORD_ALTERA_AVALON_PIO_DATA(PIO_BOT_ENDCALC_BASE) & 0x01 != 1);

				// armazena os ângulos calculados para a pata atual.
				IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_WRCOORD_BASE, 1);
				IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_WRCOORD_BASE, 0);
			}
		}

		// envia todos os ângulos armazenados para os motores.
		IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_UPDATEFLAG_BASE, 1);
		IOWR_ALTERA_AVALON_PIO_DATA(PIO_BOT_UPDATEFLAG_BASE, 0);
#endif
		return true;
	}
}
