package bot.constants;

/**
 * Interface dummy com constantes referentes à conexão driver-cliente do hexápode.
 */
public interface ClientConstants {
	/**
	 * Número da porta padrão de conexão ao driver.
	 */
	public final int CLIENT_PORT = 0xEDDA;

	/**
	 * Magic word utilizada no protocolo de alto nível entre o driver e o cliente.
	 */
	public final int CLIENT_MAGIC_WORD = 0x00BA0BAA;

	/**
	 * Máximo de tentativas de transmissão de cada mensagem entre o driver e o cliente.
	 */
	public final int CLIENT_MAX_TRIES = 2;

	/**
	 * Constante indicando o intervalo máximo entre dois bytes recebidos na comunicação entre o driver e o cliente.
	 */
	public final long CLIENT_BYTE_TIMEOUT = 500 /* ms */;

	/**
	 * Timeout de mensagens em geral entre o driver o e cliente.
	 */
	public final long CLIENT_DEFAULT_TIMEOUT = 1500 /* ms */;

	/**
	 * Timeout das mensagens de abertura de porta entre o driver e o cliente.
	 */
	public final long CLIENT_OPENPORT_TIMEOUT = 5000 /* ms */;

	/**
	 * Timeout das mensagens de iniciar movimento entre o driver e o cliente.
	 */
	public final long CLIENT_STARTMOVING_TIMEOUT = 4000 /* ms */;
}
