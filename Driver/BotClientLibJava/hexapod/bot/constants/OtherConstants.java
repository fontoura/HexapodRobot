package bot.constants;

import java.io.UnsupportedEncodingException;

public class OtherConstants {

	public static byte[] getBytes(String port)
	{
		try {
			return port.getBytes("US-ASCII");
		} catch (UnsupportedEncodingException e) {
			return port.getBytes();
		}
	}

	public static String getString(byte[] buffer) {
		try {
			return new String(buffer, "US-ASCII");
		} catch (UnsupportedEncodingException e) {
			return new String(buffer);
		}
	}
}
