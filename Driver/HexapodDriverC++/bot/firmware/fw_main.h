/*
 * fw_main.h
 *
 *  Created on: 22/03/2013
 */

#ifndef BOT_FIRMWARE_FW_MAIN_H_
#define BOT_FIRMWARE_FW_MAIN_H_

#ifdef __WIN32__
#define _UART_NAME (char*)"COM7"
#endif /* __WIN32__ */

#ifdef __NIOS2__
#include "system.h"
#define _UART_NAME UART_NAME
#endif /* __NIOS2__ */


namespace bot
{
	namespace firmware
	{
		/**
		 * Função principal do firmware do robô.
		 */
		void main(void* param);
	}
}

#endif /* BOT_FIRMWARE_FW_MAIN_H_ */
