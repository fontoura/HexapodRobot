package bot.callback;

/**
 * Interface definindo método de callback que deve ser invocado assim que a conexão com um robô tiver sido estabelecida.
 */
public interface OpenedCallback {
	/**
	 * Define os possíveis resultados da operação.
	 */
	public static enum Result {
		/**
		 * Indica que foi estabelecida uma conexão com o robô.
		 */
		Success(0x00),

		/**
		 * Indica que o cliente não recebeu resposta do driver a tempo.
		 */
		ClientTimeout(0x10),

		/**
		 * Indica que o cliente não está conectado ao driver.
		 */
		Offline(0x20),

		/**
		 * Indica que o driver recebeu resposta inválida do robô.
		 */
		UnexpectedClientResponse(0x80),

		/**
		 * Indica que o driver não recebeu resposta do robô a tempo.
		 */
		RobotTimeout(0x01),

		/**
		 * Indica que o driver já estava conectado a um robô.
		 */
		AlreadyConnected(0x02),

		/**
		 * Indica que o driver não reconheceu o nome da porta.
		 */
		InvalidPort(0x04),

		/**
		 * Indica que o driver recebeu resposta inválida do robô.
		 */
		UnexpectedRobotResponse(0x08);

		private int m_value;

		private Result(int value) {
			m_value = value;
		}

		public int getValue() {
			return m_value;
		}

		public static Result fromValue(int value) {
			for (Result result : Result.values()) {
				if (result.getValue() == value) {
					return result;
				}
			}
			return null;
		}
	}

	/**
	 * Método invocado assim que a conexão com um robô tiver sido estabelecida.
	 * 
	 * @param port Porta na qual a conexão foi estabelecida.
	 * @param result Valor indicando resultado da operação.
	 */
	public void onOpened(String port, Result result);
}
