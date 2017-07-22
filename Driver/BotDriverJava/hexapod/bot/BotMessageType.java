package bot;

import java.util.HashMap;

import protocol.Message;

public enum BotMessageType {
	// base -> hexápode
	HANDSHAKE_REQUEST(0x0000),
	HANDSHAKE_REPLY(0x0001),
	CHECKSTATUS_REQUEST(0x0002),
	CHECKSTATUS_REPLY(0x0003),
	HALT_REQUEST(0x0020),
	HALT_REPLY(0x0021),
	SETMOVEMENT_REQUEST(0x0022),
	SETMOVEMENT_REPLY(0x0023),
	MOVE_REQUEST(0x0024),
	MOVE_REPLY(0x0025),
	FETCHSENSOR_REQUEST(0x0040),
	FETCHSENSOR_REPLY(0x0041),
	ERROR_NOTIFICATION_REQUEST(0x00FE),
	ERROR_NOTIFICATION_REPLY(0x00FF),

	// hexápode -> base
	KEEPALIVE_NOTIFICATION_REQUEST(0x0100),
	KEEPALIVE_NOTIFICATION_REPLY(0x0101),
	MOVEMENT_FINISHED_NOTIFICATION_REQUEST(0x0102),
	MOVEMENT_FINISHED_NOTIFICATION_REPLY(0x0103),
	MOVEMENT_ABORTED_NOTIFICATION_REQUEST(0x0104),
	MOVEMENT_ABORTED_NOTIFICATION_REPLY(0x0105),

	// mensagem desconhecida.
	UNKNOWN_REQUEST(-2),
	UNKNOWN_REPLY(-1);

	static HashMap<Integer, BotMessageType> m_types;
	private int m_type;

	static {
		BotMessageType[] values = BotMessageType.values();
		m_types = new HashMap<Integer, BotMessageType>();
		for (int i = 0; i < values.length; i++) {
			m_types.put(values[i].m_type, values[i]);
		}
	}

	private BotMessageType(int type) {
		m_type = type;
	}

	public int getType() {
		return m_type;
	}

	public static BotMessageType get(int type) {
		type &= 0xFFFF;
		BotMessageType messageType = m_types.get(type);
		if (messageType == null) {
			if (0 == (type & 0x01)) {
				messageType = UNKNOWN_REQUEST;
			} else {
				messageType = UNKNOWN_REPLY;
			}
		}
		return messageType;
	}

	public Message createMessage(int length) {
		return Message.create(getType(), length);
	}

	public boolean equals(int value) {
		return value == getType();
	}
}
