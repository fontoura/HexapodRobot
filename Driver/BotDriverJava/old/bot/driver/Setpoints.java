package bot.driver;

import global.Global;

public class Setpoints {
	public int legNE_x;
	public int legNE_y;
	public int legNE_z;

	public int legE_x;
	public int legE_y;
	public int legE_z;

	public int legSE_x;
	public int legSE_y;
	public int legSE_z;

	public int legSW_x;
	public int legSW_y;
	public int legSW_z;

	public int legW_x;
	public int legW_y;
	public int legW_z;

	public int legNW_x;
	public int legNW_y;
	public int legNW_z;

	public void write(byte[] bytes, int offset) {
		Global.writeLittleEndian32(bytes, offset + 0x00, legNE_x);
		Global.writeLittleEndian32(bytes, offset + 0x04, legNE_y);
		Global.writeLittleEndian32(bytes, offset + 0x08, legNE_z);

		Global.writeLittleEndian32(bytes, offset + 0x0c, legE_x);
		Global.writeLittleEndian32(bytes, offset + 0x10, legE_y);
		Global.writeLittleEndian32(bytes, offset + 0x14, legE_z);

		Global.writeLittleEndian32(bytes, offset + 0x18, legSE_x);
		Global.writeLittleEndian32(bytes, offset + 0x1c, legSE_y);
		Global.writeLittleEndian32(bytes, offset + 0x20, legSE_z);

		Global.writeLittleEndian32(bytes, offset + 0x24, legSW_x);
		Global.writeLittleEndian32(bytes, offset + 0x28, legSW_y);
		Global.writeLittleEndian32(bytes, offset + 0x2c, legSW_z);

		Global.writeLittleEndian32(bytes, offset + 0x30, legW_x);
		Global.writeLittleEndian32(bytes, offset + 0x34, legW_y);
		Global.writeLittleEndian32(bytes, offset + 0x38, legW_z);

		Global.writeLittleEndian32(bytes, offset + 0x3c, legNW_x);
		Global.writeLittleEndian32(bytes, offset + 0x40, legNW_y);
		Global.writeLittleEndian32(bytes, offset + 0x44, legNW_z);
	}
}
