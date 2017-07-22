package bot.callback;

public interface GenericSensorReadCallback extends SensorReadCallback {
	public void onSensorRead(byte[] sensor, Result result);
}
