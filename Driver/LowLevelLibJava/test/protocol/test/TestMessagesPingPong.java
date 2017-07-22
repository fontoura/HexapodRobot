package protocol.test;

import protocol.Channel;
import protocol.Flow;
import protocol.FlowReplier;
import protocol.Message;
import protocol.MessageReplyCallback;
import protocol.MessageRequestCallback;
import stream.Stream;
import stream.socket.TCPSocketStream;

public class TestMessagesPingPong {
	private static int PORT = (int) 0x7070; /* pp */
	private static int MAGIC_WORD = (int) 0x7069706F; /* pipo */
	private static int PING_TYPE = (int) 0x7069 - 1; /* pi */
	private static int PONG_TYPE = (int) 0x706F; /* po */

	public static void main(String[] args) {
		Stream stream = TCPSocketStream.open("localhost", PORT);
		Channel channel = Channel.create(stream, MAGIC_WORD, 10l);
		Flow flow = Flow.create(channel, 100l);
		PingPongThreadBody pingPong = new PingPongThreadBody(flow);
		flow.setCallback(pingPong);
		flow.start();
		pingPong.run();
	}

	private static class PingPongThreadBody implements Runnable, MessageRequestCallback, MessageReplyCallback {
		private Flow m_flow;

		public PingPongThreadBody(Flow flow) {
			m_flow = flow;
		}

		@Override
		public void run() {
			try {
				Thread.sleep(100);
			} catch (InterruptedException e) {}
			for (int i = 0; i < 3; i++) {
				Message request = Message.create(PING_TYPE, 1);
				request.setByte(0, (byte) i);
				m_flow.send(request, this, 1000);
				System.out.println("Enviado request #" + request.getByte(0));
				System.out.flush();
				try {
					Thread.sleep(100);
				} catch (InterruptedException e) {}
			}
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) { }
			m_flow.stop();
		}

		@Override
		public void onRequest(Message request, FlowReplier replier) {
			if (request.getType() == PING_TYPE) {
				System.out.println("Recebido request #" + request.getByte(0));
				System.out.flush();
				Message reply = Message.create(PONG_TYPE, 0);
				replier.sendReply(reply);
				System.out.println("Enviado reply #" + request.getByte(0));
				System.out.flush();
			}
		}

		@Override
		public void onReply(Message request, Message reply, int error) {
			if (reply != null) {
				System.out.println("Recebido reply #" + request.getByte(0));
				System.out.flush();
			} else {
				System.err.println("Não recebido reply #" + request.getByte(0));
				System.err.flush();
			}
		}
	}
}
