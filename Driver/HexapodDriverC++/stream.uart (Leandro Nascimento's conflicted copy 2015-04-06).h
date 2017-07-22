/*
 * stream.uart.h
 *
 *  Created on: 22/10/2012
 *      Author: Felipe Michels Fontoura
 */

#ifndef STREAM_UART_H_
#define STREAM_UART_H_

#include "base.h"
#include "stream.h"
#include "concurrent.managed.h"

namespace stream
{
	namespace uart
	{
		/* enumeracao de possiveis tipos de stop bits. */
		enum SerialPortStopBits
		{
			SERIALPORT_STOPBITS_ONE = 0,
			SERIALPORT_STOPBITS_ONE_DOT_FIVE = 1,
			SERIALPORT_STOPBITS_TWO = 2
		};

		/* enumeracao de possiveis tipos da paridade. */
		enum SerialPortParity
		{
			SERIALPORT_PARITY_NONE = 0,
			SERIALPORT_PARITY_EVEN = 1,
			SERIALPORT_PARITY_ODD = 2
		};

		class SerialPortStream :
			public virtual stream::Stream
		{
			protected:
				char* m_port;
				int m_baudRate;
				int m_bitRate;
				SerialPortStopBits m_stopBits;
				SerialPortParity m_parity;
				int m_absoluteTimeout;
				int m_relativeTimeout;
				SerialPortStream();
				virtual ~SerialPortStream();
				virtual void initialize(char* port, int baudRate, int bitRate, SerialPortStopBits stopBits, SerialPortParity parity);
				virtual void finalize();
			public:
				static SerialPortStream* create(char* port, int baudRate, int bitRate, SerialPortStopBits stopBits, SerialPortParity parity);
		};

		class SerialPortInfo :
			public virtual base::Object
		{
			private:
				char* m_name;
			public:
				SerialPortInfo(char* name)
				{
					m_name = name;
				}
				virtual ~SerialPortInfo()
				{
					delete[] m_name;
				}
				char* getName()
				{
					return m_name;
				}
				static _strong(_array(SerialPortInfo)) generate();
		};
	}
}
#endif /* STREAM_UART_H_ */
