package bot.driver;

import java.nio.ByteBuffer;
import java.util.concurrent.atomic.AtomicReference;

import protocol.Flow;
import protocol.Message;
import protocol.MessageReplyCallback;
import concurrent.semaphore.Semaphore;

public class BotUtils {
	/**
	 * Construtor privado para impedir instanciação.
	 */
	private BotUtils() { }

	/**
	 * Método bloqueante que envia uma requisição e espera pela resposta.
	 * 
	 * @param flow Controle de fluxo a ser utilizado.
	 * @param request Mensagem a enviar.
	 * @param join Semáforo usado para coordenar o recebimento.
	 * @param timeout Tempo limite a esperar por uma resposta.
	 * @return Mensagem recebida, ou {@code null}.
	 */
	public static Message sendRequest(Flow flow, Message request, final Semaphore join, long timeout) {
		final AtomicReference<Message> reference = new AtomicReference<Message>(null);
		flow.send(request, new MessageReplyCallback() {
			public void onReply(Message request, Message _reply, int error) {
				if (null != _reply) {
					reference.set(_reply);
				}
				join.up();
			}
		}, timeout);
		join.down();
		return reference.get();
	}

	/**
	 * Método bloqueante que envia uma requisição e espera pela resposta, tentando repetir o envio em caso de falha.
	 * 
	 * @param tries Tentativas a realizar.
	 * @param flow Controle de fluxo a ser utilizado.
	 * @param request Mensagem a enviar.
	 * @param join Semáforo usado para coordenar o recebimento.
	 * @param timeout Tempo limite a esperar por uma resposta.
	 * @param sleepWhenFail Tempo de espera entre tentativas de envio.
	 * @return Mensagem recebida, ou {@code null}.
	 */
	public static Message sendRequestAndRetry(int tries, Flow flow, Message request, Semaphore join, long timeout, long sleepWhenFail) {
		for (int i = 0; i < tries; i++) {
			Message reply = sendRequest(flow, request, join, timeout);
			if (reply != null) {
				return reply;
			} else {
				try {
					Thread.sleep(sleepWhenFail);
				} catch (InterruptedException e) { }
			}
		}
		return null;
	}
	
	public static void sendRequestAndRetry(int tries, Flow flow, Message request, MessageReplyCallback callback, long timeout) {
		RequestRepeater repeater = new RequestRepeater(tries, flow, callback, timeout);
		flow.send(request, repeater, timeout);
	}

	private static class RequestRepeater implements MessageReplyCallback {
		private int m_remaining;
		private Flow m_flow;
		private MessageReplyCallback m_callback;
		private long m_timeout;

		public RequestRepeater(int tries, Flow flow, MessageReplyCallback callback, long timeout) {
			m_remaining = tries;
			m_flow = flow;
			m_callback = callback;
			m_timeout = timeout;
		}

		@Override
		public void onReply(Message request, Message reply, int error) {
			if (reply != null) {
				m_flow = null;
				m_callback.onReply(request, reply, error);
				m_callback = null;
			} else {
				m_remaining --;
				if (m_remaining > 0) {
					m_flow.send(request, this, m_timeout);
				} else {
					m_flow = null;
					m_callback.onReply(request, reply, error);
					m_callback = null;
				}
			}
		}
	}

	public static void copyAsciiBytes(String string, ByteBuffer buffer) {
		for (int i = 0; i < string.length(); i++) {
			buffer.put((byte) string.charAt(i));
		}
	}
}
