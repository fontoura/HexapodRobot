package bot.callback;

import bot.MagnetometerData;

public interface MagnetometerReadCallback extends SensorReadCallback {
	public void onMagnetometerRead(MagnetometerData data, SensorReadCallback.Result result);
}
