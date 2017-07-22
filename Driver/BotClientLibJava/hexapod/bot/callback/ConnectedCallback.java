package bot.callback;

/**
 * Interface definindo método de callback que deve ser invocado assim que a conexão com um driver tiver sido estabelecida.
 */
public interface ConnectedCallback {
	/**
	 * Define os possíveis resultados da operação.
	 */
	public static enum Result {
		/**
		 * Indica que foi estabelecida uma conexão com o driver.
		 */
		Success,

		/**
		 * Indica que a conexão não foi aceita.
		 */
		NotAccepted,

		/**
		 * Indica que já estava previamente conectado.
		 */
		AlreadyConnected;
	}

	/**
	 * Método invocado assim que a conexão com um driver tiver sido estabelecida.
	 * 
	 * @param host Host do driver.
	 * @param port Porta do driver.
	 * @param result Valor indicando resultado da operação.
	 */
	public void onConnected(String host, int port, Result result);
}
