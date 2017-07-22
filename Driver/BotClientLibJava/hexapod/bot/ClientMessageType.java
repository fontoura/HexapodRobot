package bot;

import java.util.HashMap;

import protocol.Message;

public enum ClientMessageType {
	// cliente -> driver
	ENUMERATEPORTS_REQUEST(0x8000),
	ENUMERATEPORTS_REPLY(0x8001),
	OPENPORT_REQUEST(0x8002),
	OPENPORT_REPLY(0x8003),
	BEGINMOVEMENT_REQUEST(0x8080),
	BEGINMOVEMENT_REPLY(0x8081),
	HALTMOVEMENT_REQUEST(0x8082),
	HALTMOVEMENT_REPLY(0x8083),
	READSENSOR_REQUEST(0x80C0),
	READSENSOR_REPLY(0x80C1),
	ERROR_NOTIFICATION_REQUEST(0x80FE),
	ERROR_NOTIFICATION_REPLY(0x80FF),

	// driver -> cliente
	PING_REQUEST(0xC000),
	PING_REPLY(0xC001),
	MOVEMENT_FINISHED_NOTIFICATION_REQUEST(0xC102),
	MOVEMENT_FINISHED_NOTIFICATION_REPLY(0xC103),
	MOVEMENT_ABORTED_NOTIFICATION_REQUEST(0xC104),
	MOVEMENT_ABORTED_NOTIFICATION_REPLY(0xC105),

	// mensagem desconhecida.
	UNKNOWN_REQUEST(-2),
	UNKNOWN_REPLY(-1);

	static HashMap<Integer, ClientMessageType> m_types;
	private int m_type;

	static {
		ClientMessageType[] values = ClientMessageType.values();
		m_types = new HashMap<Integer, ClientMessageType>();
		for (int i = 0; i < values.length; i++) {
			m_types.put(values[i].m_type, values[i]);
		}
	}

	private ClientMessageType(int type) {
		m_type = type;
	}

	public int getType() {
		return m_type;
	}

	public static ClientMessageType get(int type) {
		type &= 0xFFFF;
		ClientMessageType messageType = m_types.get(type);
		if (messageType == null) {
			if (0 == (type & 0x01)) {
				messageType = UNKNOWN_REQUEST;
			} else {
				messageType = UNKNOWN_REPLY;
			}
		}
		return messageType;
	}

	public static ClientMessageType get(Message message) {
		if (null == message) {
			return null;
		} else {
			return get(message.getId());
		}
	}

	public Message createMessage(int length) {
		return Message.create(getType(), length);
	}

	public boolean equals(int value) {
		return value == getType();
	}
}
