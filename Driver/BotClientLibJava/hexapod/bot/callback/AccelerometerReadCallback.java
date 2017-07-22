package bot.callback;

import bot.AccelerometerData;

public interface AccelerometerReadCallback extends SensorReadCallback {
	public void onAccelerometerRead(AccelerometerData data, SensorReadCallback.Result result);
}
