package bot.driver;

public interface Movement {
	public long getSleep();
	public void getSetpoint(Setpoints target);
	public void next();
	public boolean hasEnded();
}
