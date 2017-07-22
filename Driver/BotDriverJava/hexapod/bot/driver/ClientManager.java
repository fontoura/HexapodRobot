package bot.driver;

import java.nio.ByteBuffer;

import protocol.Channel;
import protocol.Flow;
import protocol.FlowClosedCallback;
import protocol.FlowReplier;
import protocol.Message;
import protocol.MessageReplyCallback;
import protocol.MessageRequestCallback;
import stream.socket.TCPServerSocket;
import stream.socket.TCPSocketStream;
import stream.uart.SerialPortInfo;
import bot.ClientMessageType;
import bot.callback.GenericSensorReadCallback;
import bot.callback.OpenedCallback;
import bot.callback.RobotHaltedCallback;
import bot.callback.RobotMovingCallback;
import bot.constants.ClientConstants;
import bot.constants.OtherConstants;

public class ClientManager implements Runnable, MessageRequestCallback, FlowClosedCallback {
	/**
	 * Gera uma mensagem de debug.
	 * 
	 * @param message Mensagem.
	 */
	private static final void DEBUG(String message) {
		System.out.println(message);
		System.out.flush();
	}

	/**
	 * Estados possíveis do gerente de conexões do driver..
	 */
	public static enum State {
		/**
		 * O gerente de conexões está parado.
		 */
		Stopped,

		/**
		 * O gerente de conexões está aceitando novas conexões.
		 */
		Accepting,

		/**
		 * O gerente de conexões está conectado a um cliente.
		 */
		Connected,
	}

	/**
	 * Controlador do driver.
	 */
	private DriverManager m_driver;

	/**
	 * Estado atual do gerente de comunicações.
	 */
	private State m_state;

	/**
	 * Fluxo de mensagens com o cliente.
	 */
	private Flow m_flow;

	/**
	 * Construtor protegido. Deve ser utilizado o método de factory.
	 */
	protected ClientManager(DriverManager driver) {
		m_driver = driver;
		m_state = State.Stopped;
		DEBUG("ClientManager criado!");
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	protected void finalize() throws Throwable {
		super.finalize();
		DEBUG("ClientManager apagado!");
	}

	/**
	 * Constrói um controlador de conexão de clientes com configuração padrão.
	 * 
	 * @param driver Controlador de driver.
	 * @return Controlador de conexão de clientes.
	 */
	public static ClientManager create(DriverManager driver) {
		return new ClientManager(driver);
	}

	/**
	 * {@inheritDoc}
	 */
	public void run() {
		this.accept();
	}

	private void accept() {
		synchronized (this) {
			if (m_state == State.Stopped) {
				m_state = State.Accepting;
			} else {
				return;
			}
		}

		// abre o socket de servidor.
		TCPServerSocket server = TCPServerSocket.create(ClientConstants.CLIENT_PORT);
		if (null == server) {
			DEBUG("ClientManager não pôde abrir o socket de servidor.");
			synchronized (this) {
				m_state = State.Stopped;
			}
			return;
		}

		// espera até um cliente se conectar.
		TCPSocketStream stream = server.accept();
		server.close();
		if (null == stream) {
			DEBUG("ClientManager não pôde aceitar uma conexão e criar stream de socket.");
			synchronized (this) {
				m_state = State.Stopped;
			}
			return;
		}
		if (!stream.open()) {
			DEBUG("ClientManager não pôde abrir a stream de socket.");
			stream.close();
			synchronized (this) {
				m_state = State.Stopped;
			}
			return;
		}
		DEBUG("ClientManager aceitou um cliente.");

		// cria o canal de mensagens com o cliente.
		Channel channel = Channel.create(stream, ClientConstants.CLIENT_MAGIC_WORD, ClientConstants.CLIENT_BYTE_TIMEOUT);
		final Flow flow = Flow.create(channel, ClientConstants.CLIENT_DEFAULT_TIMEOUT);
		synchronized (this) {
			m_state = State.Connected;
		}
		flow.setCallback(this);
		flow.setClosedHander(this);
		m_flow = flow;
		flow.start();

		// envia mensagem de ping.
		Message request = ClientMessageType.PING_REQUEST.createMessage(0);
		BotUtils.sendRequestAndRetry(ClientConstants.CLIENT_MAX_TRIES, flow, request, new MessageReplyCallback() {
			@Override
			public void onReply(Message request, Message reply, int error) {
				if (reply == null) {
					DEBUG("O ClientManager não recebeu resposta do ping");
					flow.stop();
				} else {
					DEBUG("O ClientManager recebeu resposta do ping");
				}
			}
		}, ClientConstants.CLIENT_DEFAULT_TIMEOUT);
		return;
	}

	@Override
	public void onFlowClosed(Flow flow) {
		synchronized (this) {
			m_flow = null;
			m_state = State.Stopped;
			m_driver.getRobot().close();
			new Thread(this).start();
		}
	}

	private void onEnumeratePortsRequest(Message request, FlowReplier replier) {
		DEBUG("ClientManager recebeu um request de enumerar portas!");

		// obtém a listagem de portas.
		SerialPortInfo[] ports = SerialPortInfo.generate();

		// determina o tamanho da mensagem de reply.
		int length = ports.length;
		for (int i = 0; i < ports.length; i++) {
			length += ports[i].getName().length();
		}

		// cria a mensagem de reply.
		Message reply = ClientMessageType.ENUMERATEPORTS_REPLY.createMessage(length);

		// preenche o corpo da mensagem de reply.
		ByteBuffer buffer = ByteBuffer.wrap(reply.getBuffer());
		for (int i = 0; i < ports.length; i++) {
			BotUtils.copyAsciiBytes(ports[i].getName(), buffer);
			buffer.put((byte) '\n');
		}

		// envia a mensagem de reply.
		replier.sendReply(reply);
	}

	/**
	 * Trata a mensagem de abrir conexão com porta.
	 */
	private void onOpenPortRequest(Message request, final FlowReplier replier) {
		DEBUG("ClientManager recebeu um request de abrir porta!");

		// obtém o nome da porta a partir da mensagem.
		String port = OtherConstants.getString(request.getBuffer());
		if (port.length() == 0)
			port = null;

		// tenta abrir a conexão com a porta.
		m_driver.getRobot().open(port, new OpenedCallback() {
			@Override
			public void onOpened(String port, OpenedCallback.Result result) {
				// envia reply.
				Message reply = ClientMessageType.OPENPORT_REPLY.createMessage(1);
				reply.setByte(0, result.getValue());
				replier.sendReply(reply);
			}
		});
	}

	/**
	 * Trata a mensagem de abortar movimento.
	 */
	private void onHaltMovementRequest(Message request, final FlowReplier replier) {
		DEBUG("ClientManager recebeu um request de parar!");
		m_driver.getRobot().halt(new RobotHaltedCallback() {
			@Override
			public void onRobotHalted(Result result) {
				Message reply = ClientMessageType.HALTMOVEMENT_REPLY.createMessage(1);
				reply.setByte(0, result.getValue());
				replier.sendReply(reply);
			}
		});
	}

	/**
	 * Trata a mensagem de iniciar movimento.
	 */
	private void onBeginMovementRequest(Message request, final FlowReplier replier) {
		DEBUG("ClientManager recebeu um request de iniciar movimento!");
		if (request.getLength() >= 0x6) {
			m_driver.getRobot().sendMovement(request.getBuffer(), new RobotMovingCallback() {
				@Override
				public void onRobotMoving(Result result) {
					DEBUG("UartManager tentou fazer o robô mover-se.");
					Message reply = ClientMessageType.BEGINMOVEMENT_REPLY.createMessage(1);
					reply.setByte(0, result.getValue());
					replier.sendReply(reply);
				}
			});
		} else {
			Message reply = ClientMessageType.BEGINMOVEMENT_REPLY.createMessage(1);
			reply.setByte(0, RobotMovingCallback.Result.InvalidMovement.getValue());
			replier.sendReply(reply);
		}
	}

	private void onReadSensorRequest(Message request, final FlowReplier replier) {
		DEBUG("ClientManager recebeu um request de ler sensor!");
		if (request.getLength() >= 0x02) {
			m_driver.getRobot().readSensor(request.getBuffer(), new GenericSensorReadCallback() {
				@Override
				public void onSensorRead(byte[] sensor, Result result) {
					DEBUG("UartManager tentou ler sensor.");
					Message reply = null;
					if (sensor != null) {
						reply = ClientMessageType.READSENSOR_REPLY.createMessage(1 + sensor.length);
						reply.setByte(0, result.getValue());
						System.arraycopy(sensor, 0, reply.getBuffer(), 1, sensor.length);
					} else {
						reply = ClientMessageType.READSENSOR_REPLY.createMessage(1);
						reply.setByte(0, result.getValue());
					}
					replier.sendReply(reply);
				}
			});
		} else {
			Message reply = ClientMessageType.BEGINMOVEMENT_REPLY.createMessage(1);
			reply.setByte(0, 0x0F);
			replier.sendReply(reply);
		}
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public void onRequest(Message request, FlowReplier replier) {
		DEBUG("O ClientManager recebeu um request");
		switch (ClientMessageType.get(request.getType())) {
			case ENUMERATEPORTS_REQUEST:
				this.onEnumeratePortsRequest(request, replier);
				break;
			case OPENPORT_REQUEST:
				this.onOpenPortRequest(request, replier);
				break;
			case HALTMOVEMENT_REQUEST:
				this.onHaltMovementRequest(request, replier);
				break;
			case BEGINMOVEMENT_REQUEST:
				this.onBeginMovementRequest(request, replier);
				break;
			case READSENSOR_REQUEST:
				this.onReadSensorRequest(request, replier);
				break;
			default:
				DEBUG("O ClientManager recebeu um request de tipo indefinido");
				Message errorReply = ClientMessageType.ERROR_NOTIFICATION_REPLY.createMessage(0);
				replier.sendReply(errorReply);
				return;
		}
	}

	public void sendMovementAbortedNotification(byte[] body) {
		this.sendNotification(ClientMessageType.MOVEMENT_ABORTED_NOTIFICATION_REQUEST.getType(), body);
	}

	public void sendMovementFinishedNotification(byte[] body) {
		this.sendNotification(ClientMessageType.MOVEMENT_FINISHED_NOTIFICATION_REQUEST.getType(), body);
	}

	protected void sendNotification(int type, byte[] body) {
		// verifica se está online.
		Flow flow = null;
		synchronized (this) {
			if (m_state == State.Connected) {
				flow = m_flow;
			}
		}
		if (flow != null) {
			Message message = Message.create(type, body.length);
			System.arraycopy(body, 0, message.getBuffer(), 0, body.length);
			BotUtils.sendRequestAndRetry(ClientConstants.CLIENT_MAX_TRIES, m_flow, message, new MessageReplyCallback() {
				@Override
				public void onReply(Message request, Message reply, int error) {
					// não faz nada.
				}
			}, ClientConstants.CLIENT_DEFAULT_TIMEOUT);
		}
	}
}
