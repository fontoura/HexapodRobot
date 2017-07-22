package bot.callback;

/**
 * Interface definindo método de callback que deve ser invocado assim que a conexão com um driver tiver sido finalizada.
 */
public interface DisconnectedCallback {
	/**
	 * Define os possíveis resultados da operação.
	 */
	public static enum Result {
		/**
		 * Indica que foi terminada uma conexão com o driver.
		 */
		Success,

		/**
		 * Indica que já estava previamente desconectado.
		 */
		AlreadyDisconnected,

		/**
		 * Indica que não pôde fechar a conexão.
		 */
		Failed
	}

	/**
	 * Método invocado assim que a conexão com um driver tiver sido finalizada.
	 * 
	 * @param result Valor indicando resultado da operação.
	 */
	public void onDisconnected(Result result);
}
