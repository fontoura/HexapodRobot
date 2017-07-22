package protocol;

import concurrent.semaphore.Semaphore;
import concurrent.time.Stoptimer;

public class Flow implements ChannelMessageCallback, ChannelClosedCallback {
	private Semaphore m_mutex;
	private MessageNode m_waitingReply;
	private Thread m_timeoutThread;
	private Channel m_channel;
	private Stoptimer m_timer;
	private MessageRequestCallback m_requestCallback;
	private FlowClosedCallback m_closedHandler;
	private int m_lastId;
	private long m_minimalTimeout;

	protected Flow(Channel channel, long minimalTimeout) {
		m_channel = channel;
		channel.setMessageCallback(this);
		channel.setClosedCallback(this);
		m_minimalTimeout = minimalTimeout;
		m_mutex = Semaphore.create(1, 1);
		m_timer = new Stoptimer();
		m_lastId = 0;
	}

	@Override
	protected void finalize() throws Throwable {
		m_channel.stop();
		super.finalize();
	}

	public static Flow create(Channel channel, long minimalTimeout) {
		return new Flow(channel, minimalTimeout);
	}

	@Override
	public void onMessage(Message message) {
		if (0 != (message.getType() & 0x01)) {
			// mensagens com ID ímpar são reply.
			m_mutex.down();
			MessageNode previous = null;
			MessageNode request = m_waitingReply;
			while (request != null) {
				if (request.message.getId() == message.getId()) {
					break;
				}
				previous = request;
				request = request.next;
			}
			if (request != null) {
				if (previous == null) {
					m_waitingReply = request.next;
				} else {
					previous.next = request.next;
				}
				request.next = null;
			}
			previous = null;
			m_mutex.up();
			if (request != null) {
				request.callback.onReply(request.message, message, 0);
			} else {
				// o que fazer quando recebe reply sem request?
			}
		} else {
			MessageRequestCallback requestCallback = m_requestCallback;
			if (requestCallback != null) {
				FlowReplier replier = new FlowReplier(message.getId(), m_channel);
				requestCallback.onRequest(message, replier);
			}

		}
	}

	@Override
	public void onMessageChannelClosed(Channel msgChannel) {
		m_mutex.down();
		FlowClosedCallback closedHandler = m_closedHandler;
		MessageNode node = m_waitingReply;
		m_closedHandler = null;
		m_waitingReply = null;
		m_mutex.up();
		if (closedHandler != null) {
			closedHandler.onFlowClosed(this);
			closedHandler = null;
		}
		if (node != null) {
			do {
				node.callback.onReply(node.message, null, 1);
				node = node.next;
			} while (node != null);
		}
	}

	public void send(Message message, MessageReplyCallback callback, long timeout) {
		if (timeout < m_minimalTimeout) {
			timeout = m_minimalTimeout;
		}
		m_mutex.down();

		// cria os nós para navegar na lista encadeada de mensagens.
		MessageNode previous = null;
		MessageNode node = m_waitingReply;

		// obtém um identificador único para a mensagem.
		m_lastId++;
		message.setId(m_lastId);
		boolean sent = m_channel.send(message);

		// verifica se enviou.
		if (sent) {
			// cria o nó com a mensagem por enviar.
			MessageNode newNode = new MessageNode();
			timeout += m_timer.getMilliseconds();
			newNode.message = message;
			newNode.callback = callback;
			newNode.absoluteTimeout = timeout;

			// procura a posição adequada e insere o nó.
			while (node != null) {
				if (node.absoluteTimeout > timeout) {
					break;
				}
				previous = node;
				node = node.next;
			}
			if (previous == null) {
				newNode.next = m_waitingReply;
				m_waitingReply = newNode;
			} else {
				newNode.next = node;
				previous.next = newNode;
			}

			// cria a thread de timeout, se não existir.
			if (m_timeoutThread == null) {
				m_timeoutThread = new Thread(new FlowThreadBody(this));
				m_timeoutThread.start();
			}

			m_mutex.up();
		} else {
			// não enviou, então dispara callback.
			callback.onReply(message, null, 1);
		}
	}

	public void setCallback(MessageRequestCallback callback) {
		m_requestCallback = callback;
	}

	public MessageRequestCallback getCallback() {
		return m_requestCallback;
	}

	public void setClosedHander(FlowClosedCallback handler) {
		m_closedHandler = handler;
	}

	public FlowClosedCallback getClosedHander() {
		return m_closedHandler;
	}

	public boolean isOpen() {
		return m_channel.isRunning();
	}

	public void start() {
		m_channel.start();
	}

	public void stop() {
		m_channel.stop();
	}

	void receive() {
		while (true) {
			m_mutex.down();
			long now = m_timer.getMilliseconds();
			long timeout = 0;
			MessageNode nextMessage = m_waitingReply;
			MessageNode timedOut = nextMessage;
			while (nextMessage != null) {
				if (nextMessage.absoluteTimeout <= now) {
					nextMessage = nextMessage.next;
					m_waitingReply = nextMessage;
				} else {
					nextMessage = null;
				}
			}
			nextMessage = m_waitingReply;
			if (nextMessage == null) {
				m_timeoutThread = null;
			} else {
				timeout = nextMessage.absoluteTimeout;
			}
			m_mutex.up();
			while (timedOut != null) {
				if (timedOut == nextMessage) {
					break;
				} else {
					timedOut.callback.onReply(timedOut.message, null, 1);
					timedOut = timedOut.next;
				}
			}
			if (nextMessage != null) {
				try {
					Thread.sleep(timeout - now);
				} catch (InterruptedException e) {}
			} else {
				break;
			}
		}
	}
}
