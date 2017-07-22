package bot.callback;

public interface RobotHaltedCallback extends RobotMovementCallback  {
	public void onRobotHalted(Result result);
}
