package bot.constants;

import stream.uart.SerialPortParity;
import stream.uart.SerialPortStopBits;

public interface DriverConstants {
	/**
	 * Constante indicando a taxa de bauds utilizada na comunicação com o robô.
	 */
	public static final int BOT_BAUD_RATE = 57600;

	/**
	 * Constante indicando o número de stop bits utilizados na comunicação com o robô.
	 */
	public static final SerialPortStopBits BOT_STOP_BITS = SerialPortStopBits.STOPBITS_ONE;

	/**
	 * Constante indicando a paridade utilziada na comunicação com o robô.
	 */
	public static final SerialPortParity BOT_PARITY = SerialPortParity.PARITY_NONE;

	/**
	 * Constante indicando a magic word utilizada na comunicação entre o driver e o robô.
	 */
	public static final int BOT_MAGIC_WORD = 0x000FF0FF;

	/**
	 * Máximo de tentativas de transmissão de cada mensagem entre o driver e o robô.
	 */
	public static final int BOT_MAX_TRIES = 8;

	/**
	 * Tempo que o driver deve dormir quando uma mensagem falhar.
	 */
	public static final long BOT_INTERVAL_BETWEEN_TRIES = 128 /* ms */;

	/**
	 * Constante indicando o intervalo máximo entre dois bytes recebidos na comunicação entre o driver e o robô.
	 */
	public static final long BOT_BYTE_TIMEOUT = 4 /* ms */;

	/**
	 * Timeout de mensagens em geral entre o driver o e robô.
	 */
	public static final long BOT_DEFAULT_TIMEOUT = 128 /* ms */;
}
