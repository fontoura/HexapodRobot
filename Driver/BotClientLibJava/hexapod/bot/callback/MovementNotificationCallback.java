package bot.callback;

import bot.client.RobotConnection;

public interface MovementNotificationCallback {
	/**
	 * Define as possíveis causas da notificação.
	 */
	public enum Cause {
		/**
		 * Indica que a causa da notificação é o movimento ter terminado.
		 */
		Finished,

		/**
		 * Indica que a causa da notificação é o movimento ter sido abortado.
		 */
		Aborted
	}

	/**
	 * Evento disparado quando um movimento tiver parado.
	 * 
	 * @param connection Conexão referente à notificação.
	 * @param value Valor atual do movimento.
	 * @param length Valor total do movimento.
	 * @param id Identificador do movimento.
	 * @param cause Causa da notificação.
	 */
	void onMoved(RobotConnection connection, int value, int length, int id, Cause cause);
}
