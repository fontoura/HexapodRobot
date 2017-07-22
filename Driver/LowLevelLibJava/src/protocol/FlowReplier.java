package protocol;

import java.lang.ref.WeakReference;

public class FlowReplier {
	private int m_id;
	private WeakReference<Channel> m_channel;

	public FlowReplier(int id, Channel channel) {
		m_id = id;
		m_channel = new WeakReference<Channel>(channel);
	}

	public void sendReply(Message reply) {
		Channel channel = m_channel.get();
		m_channel.clear();
		if (channel != null) {
			reply.setId(m_id);
			channel.send(reply);
			channel = null;
		}

	}
}