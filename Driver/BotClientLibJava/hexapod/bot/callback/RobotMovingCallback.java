package bot.callback;

/**
 * Interface definindo método de callback que deve ser invocado assim que o robô iniciar um movimento.
 */
public interface RobotMovingCallback extends RobotMovementCallback {
	/**
	 * Método invocado assim que o robô iniciar um movimento.
	 * 
	 * @param result Valor indicando o resultado da operação.
	 */
	public void onRobotMoving(Result result);
}
