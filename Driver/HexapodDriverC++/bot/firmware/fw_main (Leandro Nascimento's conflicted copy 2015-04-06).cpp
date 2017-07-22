/*
 * fw_main.cpp
 *
 *  Created on: 22/03/2013
 */

#include "../../bot/firmware/fw_defines.h"
#include "../../bot/firmware/fw_main.h"

#include "../../base.h"
#include "../../concurrent.managed.h"
#include "../../stream.h"
#include "../../stream.uart.h"
#include "../../protocol/Message.h"
#include "../../protocol/Channel.h"
#include "../../protocol/Flow.h"

#include "../../bot/firmware/RobotManager.h"
#include "../../bot/firmware/UartManager.h"
#include "../../bot/firmware/MovementManager.h"
#include "../../bot/firmware/SensorsManager.h"

using namespace base;
using namespace stream;
using namespace stream::uart;
using namespace protocol;
using namespace concurrent::thread;

#ifdef _WIN32
#include "../../stream.socket.h"
using namespace stream::socket;
#endif /* _WIN32 */

/* macros para debug */
#ifdef DEBUG_bot_firmware_fw_main
#include <iostream>
#define DEBUG(v1) std::cout<<(v1)<<std::endl
#define DEBUG2(v1,v2) std::cout<<(v1)<<(v2)<<std::endl
#define DEBUG3(v1,v2,v3) std::cout<<(v1)<<(v2)<<(v3)<<std::endl
#define DEBUG4(v1,v2,v3,v4) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<std::endl
#define DEBUG5(v1,v2,v3,v4,v5) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<(v5)<<std::endl
#else /* ifndef DEBUG_bot_firmware_fw_main */
#define DEBUG(v1) {}
#define DEBUG2(v1,v2) {}
#define DEBUG3(v1,v2,v3) {}
#define DEBUG4(v1,v2,v3,v4) {}
#define DEBUG5(v1,v2,v3,v4,v5) {}
#endif /* DEBUG_bot_firmware_fw_main */

namespace bot
{
	namespace firmware
	{
		bool createSensorsManager(_strong(RobotManager)& robot);
		bool createMovementManager(_strong(RobotManager)& robot);
		bool createUartManager(_strong(RobotManager)& robot);

		void main(void* param)
		{
			/*char teste[] = "Teste\n";
			char buffer[11];
			_strong(stream::uart::SerialPortStream) stream = stream::uart::SerialPortStream::create(_UART_NAME, _UART_BAUDRATE, 8, SERIALPORT_STOPBITS_ONE, SERIALPORT_PARITY_NONE);
			stream->open();
			while (true)
			{
				stream->write((uint8_t*)teste, 0, 6);
				stream->setTimeouts(1000, 1000);
				int length = stream->read((uint8_t*)buffer, 0, 10);
				if (length == 1)
				{
					buffer[length] = 0;
					std::cout << "RECV " << buffer << std::endl;
				}
				else
				{
					std::cout << "TIMEOUT" << std::endl;
				}
			}*/

			DEBUG("# Iniciou a Main do firmware. #");

			// primeiro constrói o robô.
			_strong(RobotManager) robot = RobotManager::create();

			if (createSensorsManager(robot))
			{
				DEBUG("# Abriu o SensorsManager. #");
				if (createMovementManager(robot))
				{
					DEBUG("# Abriu o MovementManager com sucesso. #");
					if (createUartManager(robot))
					{
						DEBUG("# Iniciando o sistema de leitura de sensores... #");
						robot->getSensorsManager()->start();

						// inicia o controle de fluxo.
						DEBUG("# Iniciando o fluxo de mensagens... #");
						robot->getUartManager()->start();

						// inicia o gerente de movimento.
						DEBUG("# Iniciando o controle de movimentos... #");
						robot->getMovementManager()->start();

						// ok.
						DEBUG("*** em execucao *** #");
					}
					else
					{
						DEBUG("# Nao abriu o UartManager. #");
						_strong(MovementManager) _null = NULL;
						robot->setMovementManager(_null);
						robot = NULL;
					}
				}
				else
				{
					DEBUG("# Nao abriu o MovementManager. #");
					robot = NULL;
				}
			}
			else
			{
				DEBUG("# Nao abriu o SensorsManager. #");
			}

			while (true)
			{
				Thread::sleep(5000);
			}
		}

		bool createSensorsManager(_strong(RobotManager)& robot)
		{
			_strong(SensorsManager) manager;

			// tenta criar o objeto de sensores.
			DEBUG("# Instanciando o SensorsManager... #");
			manager = SensorsManager::create();
			if (manager == NULL)
			{
				DEBUG("# Nao instanciou o SensorsManager. #");
				return false;
			}
			robot->setSensorsManager(manager);
			return true;
		}

		bool createMovementManager(_strong(RobotManager)& robot)
		{
			_strong(MovementManager) manager;

			// tenta criar o objeto de movimentação.
			DEBUG("# Instanciando o MovementManager... #");
			manager = MovementManager::create(robot);
			if (manager == NULL)
			{
				DEBUG("# Nao instanciou o MovementManager. #");
				return false;
			}
			robot->setMovementManager(manager);
			return true;
		}

#ifdef _WIN32
			_strong(TCPServerSocket) serverSocket;
#endif /* _WIN32 */

		bool createUartManager(_strong(RobotManager)& robot)
		{
			_strong(UartManager) uart;

			// tenta criar o objeto de porta serial.
			DEBUG("# Criando Stream serial (UART)... #");
#ifdef _WIN32
			initSocket();
			serverSocket = TCPServerSocket::create(3377);
			_strong(Stream) stream = serverSocket->accept();
#else /* ifndef _WIN32 */
			_strong(Stream) stream = SerialPortStream::create(_UART_NAME, _UART_BAUDRATE, 8, SERIALPORT_STOPBITS_ONE, SERIALPORT_PARITY_NONE);
#endif /* _WIN32 */
			if (stream == NULL)
			{
				DEBUG("# Nao criou Stream serial. #");
				return false;
			}

			// tenta abrir a conexão com a porta serial.
			DEBUG("# Abrindo Stream serial... #");
			if (!stream->open())
			{
				DEBUG("# Nao abriu Stream serial. #");
				return false;
			}

			// tenta criar o canal.
			DEBUG("# Criando canal de mensagens... #");
			_strong(Channel) channel = Channel::create(stream, _MAGIC_WORD, _BYTE_TIMEOUT);
			if (channel == NULL)
			{
				DEBUG("# Nao criou canal de mensagens. #");
				stream->close();
				return false;
			}

			// tenta criar o controle de fluxo.
			DEBUG("# Criando controle de fluxo... #");
			_strong(Flow) flow = Flow::create(channel, _MINIMAL_TIMEOUT);
			if (flow == NULL)
			{
				DEBUG("# Nao criou controle de fluxo. #");
				stream->close();
				return false;
			}

			// tenta criar o gerente da UART.
			DEBUG("# Instanciando UartManager... #");
			uart = UartManager::create(robot, flow);
			if (uart == NULL)
			{
				DEBUG("# Nao instanciou o UartManager. #");
				stream->close();
				return false;
			}
			robot->setUartManager(uart);
			uart = NULL;

			return true;
		}
	}
}
