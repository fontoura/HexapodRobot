package bot.callback;

import bot.client.RobotConnection;

public interface OfflineCallback {
	/**
	 * Define as possíveis causas da notificação.
	 */
	public enum Cause {
		/**
		 * Indica que a causa da notificação é o usuário remoto ter fechado a conexão.
		 */
		RemoteDisconnected,

		/**
		 * Indica que a causa da notificação é o usuário local ter fechado a conexão.
		 */
		LocalDisconnected
	}

	public void onOffline(RobotConnection connection, Cause cause);
}
