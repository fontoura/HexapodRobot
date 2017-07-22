package bot.callback;

public interface RobotMovementCallback {
	/**
	 * Define os possíveis resultados da operação.
	 */
	public static enum Result {
		/**
		 * Indica que o movimento foi iniciado.
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
		 * Indica que o driver não está conectado ao robô.
		 */
		Closed(0x02),

		/**
		 * Indica que o robô não reconheceu o movimento.
		 */
		InvalidMovement(0x04),

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
}
