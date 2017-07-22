package bot.callback;

/**
 * Interface definindo método de callback que deve ser invocado assim que for feita a enumeração de portas.
 */
public interface PortsEnumeratedCallback {
	/**
	 * Define os possíveis resultados da operação.
	 */
	public static enum Result {
		/**
		 * Indica que as portas foram enumeradas com sucesso.
		 */
		Success,

		/**
		 * Indica que o cliente não está conectado ao driver.
		 */
		Offline,

		/**
		 * Indica que o cliente não recebeu resposta do driver a tempo.
		 */
		Timeout,

		/**
		 * Indica que o cliente recebeu resposta inválida do driver.
		 */
		UnexpectedResponse
	}

	/**
	 * Método invocado assim que for feita a enumeração de portas.
	 * 
	 * @param ports Vetor com as portas.
	 * @param result Valor indicando o resultado da operação.
	 */
	public void onPortsEnumerated(String[] ports, Result result);
}
