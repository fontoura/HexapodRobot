package protocol;

public class ChannelThreadBody implements Runnable {
	private Channel m_channel;

	public ChannelThreadBody(Channel channel) {
		m_channel = channel;
	}

	public void run() {
		m_channel.receive();
		m_channel = null;
	}
}
