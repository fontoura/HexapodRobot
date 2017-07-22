package protocol;

/**
 * An object which contains the fields of a message.
 */
public class Message {
	private int m_type;
	private int m_id;
	private byte[] m_buffer;

	protected Message(int type, int length) {
		m_type = 0xFFFF & type;
		m_buffer = new byte[length];
	}

	public static Message create(int type, int length) {
		return new Message(type, length);
	}

	/**
	 * Gets the type of the message.
	 * 
	 * @return Type of the message.
	 */
	public int getType() {
		return m_type;
	}

	/**
	 * Gets the identifier of the message.
	 * 
	 * @return Identifier of the message.
	 */
	public int getId() {
		return m_id;
	}

	/**
	 * Gets the length of the buffer of the message.
	 * 
	 * @return Length of the buffer of the message.
	 */
	public int getLength() {
		return m_buffer.length;
	}

	/**
	 * Gets the buffer of the message.
	 * 
	 * @return Buffer of the message.
	 */
	public byte[] getBuffer() {
		return m_buffer;
	}

	/**
	 * Sets the identifier of the message.
	 * 
	 * @param id New identifier of the message.
	 */
	public void setId(int id) {
		m_id = id;
	}

	public int getByte(int i) {
		if (0 > i || i >= m_buffer.length) {
			return -1;
		}
		return 0xFF & m_buffer[i];
	}

	public void setByte(int i, int b) {
		if (0 > i || i >= m_buffer.length) {
			return;
		}
		m_buffer[i] = (byte)b;
	}
}
