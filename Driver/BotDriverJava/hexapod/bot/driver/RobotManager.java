package bot.driver;

import java.lang.ref.WeakReference;

import protocol.Channel;
import protocol.Flow;
import protocol.FlowReplier;
import protocol.Message;
import protocol.MessageRequestCallback;
import stream.Stream;
import stream.socket.TCPSocketStream;
import stream.uart.SerialPortStream;
import bot.BotMessageType;
import bot.callback.GenericSensorReadCallback;
import bot.callback.OpenedCallback;
import bot.callback.RobotHaltedCallback;
import bot.callback.RobotMovementCallback;
import bot.callback.RobotMovingCallback;
import bot.callback.SensorReadCallback;
import bot.constants.DriverConstants;
import concurrent.jobs.JobQueue;
import concurrent.semaphore.Semaphore;

/**
 * Classe que gerencia o robô.
 */
public class RobotManager {
	/**
	 * Gera uma mensagem de debug.
	 * 
	 * @param message Mensagem.
	 */
	private static void DEBUG(String message) {
		System.out.println(message);
	}

	/**
	 * Enumeração de estados do controlador de robô.
	 */
	public static enum State {
		/**
		 * Não foi estabelecida a comunicação com um robô.
		 */
		Closed,

		/**
		 * A comunicação com um robô está sendo estabelecida.
		 */
		Opening,

		/**
		 * Foi estabelecida a comunicação com um robô, que está parado.
		 */
		Idle,

		/**
		 * Foi estabelecida a comunicação com um robô, que está em movimento.
		 */
		Moving
	}

	/**
	 * Controlador do driver.
	 */
	private DriverManager m_driver;

	/**
	 * Estado atual do sistema de controle.
	 */
	private State m_state;

	/**
	 * Identificador interno sequencial da conexão atual.
	 */
	@SuppressWarnings("unused")
	private int m_connectionId;

	/**
	 * Semáforo usado para fazer "join".
	 */
	private Semaphore m_join;

	/**
	 * Callback de mensagem recebida.
	 */
	private MessageCallback m_callback;

	/**
	 * Fila de tarefas.
	 */
	private JobQueue m_jobs;

	/**
	 * Controle de fluxo em uso para comunicação com o robô.
	 */
	private Flow m_flow;

	/**
	 * Constrói um controlador de robô com configuração padrão.
	 * 
	 * @param driver Controlador do driver.
	 */
	protected RobotManager(DriverManager driver) {
		m_driver = driver;
		m_state = State.Closed;
		m_join = Semaphore.create(0, 1);
		m_callback = new MessageCallback(this);
		m_jobs = JobQueue.create();
		DEBUG("RobotManager criado!");
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	protected void finalize() throws Throwable {
		super.finalize();
		DEBUG("RobotManager apagado!");
	}

	/**
	 * Constrói um controlador de robô com configuração padrão.
	 * 
	 * @param driver Controlador de driver.
	 * @return Controlador de robô.
	 */
	public static RobotManager create(DriverManager driver) {
		return new RobotManager(driver);
	}

	/**
	 * Obtém o estado atual.
	 * 
	 * @return Estado atual.
	 */
	public State getState() {
		synchronized (this) {
			return m_state;
		}
	}

	/**
	 * Método que tenta estabeler conexão com um robô.
	 * 
	 * @param port Porta na qual deve estabeler conexão.
	 * @param callback Objeto com o método de callback.
	 */
	public void open(final String port, final OpenedCallback callback) {
		m_jobs.enqueue(new Runnable() {
			@Override
			public void run() {
				RobotManager.this.internalOpen(port, callback);
			}
		});
	}

	public void close() {
		m_jobs.enqueue(new Runnable() {
			@Override
			public void run() {
				RobotManager.this.internalClose();
			}
		});
	}

	/**
	 * Método que tenta fazer a leitura de um sensor.
	 * 
	 * @param buffer Descrição do comando de leitura.
	 * @param callback Objeto com o método de callback.
	 */
	public void readSensor(final byte[] buffer, final GenericSensorReadCallback callback) {
		m_jobs.enqueue(new Runnable() {
			@Override
			public void run() {
				RobotManager.this.internalReadSensor(buffer, callback);
			}
		});
	}

	/**
	 * Método que tenta fazer o robô andar.
	 * 
	 * @param movement Descrição do movimento.
	 * @param callback Objeto com o método de callback.
	 */
	public void sendMovement(final byte[] movement, final RobotMovingCallback callback) {
		m_jobs.enqueue(new Runnable() {
			@Override
			public void run() {
				RobotManager.this.internalSendMovement(movement, callback);
			}
		});
	}

	/**
	 * Método que tenta fazer o robõ parar.
	 * 
	 * @param callback Objeto com o método de callback.
	 */
	public void halt(final RobotHaltedCallback callback) {
		m_jobs.enqueue(new Runnable() {
			@Override
			public void run() {
				callback.onRobotHalted(RobotManager.this.internalHalt());
			}
		});
	}

	/**
	 * Método interno que tenta estabeler conexão com um robô, executado na thread da fila de tarefas.
	 * 
	 * @param port Porta na qual deve estabeler conexão.
	 * @param callback Objeto com o método de callback.
	 */
	private void internalOpen(String port, OpenedCallback callback) {
		Message request, reply;

		if (port != null) {
			if (port.length() == 0) {
				port = null;
			}
		}

		// verifica se está offline atualmente.
		State state;
		synchronized (this) {
			state = m_state;
			if (State.Closed == state) {
				DEBUG("RobotManager iniciando conexao ao robô.");
				m_state = State.Opening;
			}
		}
		if (State.Closed != state) {
			DEBUG("RobotManager tentou conectar, mas já estava conectado.");
			callback.onOpened(port, OpenedCallback.Result.AlreadyConnected);
			return;
		}

		// tenta abrir a conexão com a porta serial.
		DEBUG("RobotManager criando fluxo de UART... <" + port + ">");
		Stream stream;
		if (port == null) {
			stream = TCPSocketStream.open("127.0.0.1", 3377);
		} else {
			stream = SerialPortStream.create(port, DriverConstants.BOT_BAUD_RATE, 8, DriverConstants.BOT_STOP_BITS, DriverConstants.BOT_PARITY);
		}
		if (stream != null) {
			if (!stream.open()) {
				DEBUG("RobotManager não pôde abrir fluxo de UART");
				stream = null;
			} else {
				DEBUG("RobotManager abriu fluxo de UART");
			}
		} else {
			DEBUG("RobotManager não criou fluxo de UART");
		}
		if (stream == null) {
			synchronized (this) {
				m_state = State.Closed;
			}
			callback.onOpened(port, OpenedCallback.Result.InvalidPort);
			return;
		}

		// abre os canais.
		DEBUG("RobotManager criando canal e fluxo.");
		Channel channel = Channel.create(stream, DriverConstants.BOT_MAGIC_WORD, DriverConstants.BOT_BYTE_TIMEOUT);
		Flow flow = Flow.create(channel, DriverConstants.BOT_DEFAULT_TIMEOUT);
		flow.setCallback(m_callback);
		flow.start();

		// tenta enviar mensagem de handshake.
		DEBUG("RobotManager enviando pedido de handshake.");
		request = BotMessageType.HANDSHAKE_REQUEST.createMessage(0);
		reply = BotUtils.sendRequestAndRetry(DriverConstants.BOT_MAX_TRIES, flow, request, m_join, DriverConstants.BOT_DEFAULT_TIMEOUT, DriverConstants.BOT_INTERVAL_BETWEEN_TRIES);
		if (reply == null) {
			DEBUG("RobotManager não recebeu reply");
			flow.stop();
			stream.close();
			synchronized (this) {
				m_state = State.Closed;
			}
			callback.onOpened(port, OpenedCallback.Result.RobotTimeout);
			return;
		}
		if (!BotMessageType.HANDSHAKE_REPLY.equals(reply.getType())) {
			DEBUG("RobotManager recebeu reply inválido");
			flow.stop();
			stream.close();
			synchronized (this) {
				m_state = State.Closed;
			}
			callback.onOpened(port, OpenedCallback.Result.UnexpectedRobotResponse);
			return;
		}
		DEBUG("RobotManager conectado com sucesso.");

		// tenta enviar a mensagem de obter estado.
		DEBUG("RobotManager enviando pedido de checagem de estado.");
		request = BotMessageType.CHECKSTATUS_REQUEST.createMessage(0);
		reply = BotUtils.sendRequestAndRetry(DriverConstants.BOT_MAX_TRIES, flow, request, m_join, DriverConstants.BOT_DEFAULT_TIMEOUT, DriverConstants.BOT_INTERVAL_BETWEEN_TRIES);
		if (reply == null) {
			DEBUG("RobotManager não recebeu reply.");
			flow.stop();
			stream.close();
			synchronized (this) {
				m_state = State.Closed;
			}
			callback.onOpened(port, OpenedCallback.Result.RobotTimeout);
			return;
		}

		// verifica o tipo de reply.
		boolean moving = false;
		if (!BotMessageType.CHECKSTATUS_REPLY.equals(reply.getType())) {
			DEBUG("RobotManager recebeu reply inválido");
			flow.stop();
			stream.close();
			synchronized (this) {
				m_state = State.Closed;
			}
			callback.onOpened(port, OpenedCallback.Result.UnexpectedRobotResponse);
			return;
		}
		if (reply.getByte(0) != 0x00) {
			moving = true;
		}

		// deu certo. vai para o estado online.
		DEBUG("RobotManager detectou que " + (moving ? "robô está se movendo" : "robô está se parado"));
		m_flow = flow;
		synchronized (this) {
			if (moving) {
				m_state = State.Moving;
			} else {
				m_state = State.Idle;
			}
			m_connectionId++;
		}
		callback.onOpened(port, OpenedCallback.Result.Success);
		return;
	}

	/**
	 * Método interno que desconecta o robô, executado na thread da fila de tarefas.
	 */
	private void internalClose() {
		if (this.m_flow != null) {
			m_flow.stop();
			m_flow = null;
			m_state = State.Closed;
		}
	}

	/**
	 * Método interno que tenta fazer a leitura de um sensor, executado na thread da fila de tarefas.
	 * 
	 * @param buffer Descrição do comando de leitura.
	 * @param callback Objeto com o método de callback.
	 */
	private void internalReadSensor(byte[] buffer, GenericSensorReadCallback callback) {
		// verifica se está online atualmente.
		State state;
		synchronized (this) {
			state = m_state;
		}
		if (State.Moving == state || State.Idle == state) {
			DEBUG("RobotManager vai iniciar leitura de sensor.");
		} else {
			DEBUG("RobotManager tentou iniciar leitura de sensor, mas estava desconectado.");
			callback.onSensorRead(null, SensorReadCallback.Result.Closed);
			return;
		}

		Message request = BotMessageType.FETCHSENSOR_REQUEST.createMessage(buffer.length);
		System.arraycopy(buffer, 0, request.getBuffer(), 0, buffer.length);
		Message reply = BotUtils.sendRequestAndRetry(DriverConstants.BOT_MAX_TRIES, m_flow, request, m_join, DriverConstants.BOT_DEFAULT_TIMEOUT, DriverConstants.BOT_INTERVAL_BETWEEN_TRIES);

		if (reply == null) {
			DEBUG("RobotManager não recebeu reply!");
			callback.onSensorRead(null, SensorReadCallback.Result.RobotTimeout);
			return;
		}
		callback.onSensorRead(reply.getBuffer(), SensorReadCallback.Result.Success);
	}

	/**
	 * Método interno que tenta fazer o robô executar algum movimento, executado na thread da fila de tarefas.
	 * 
	 * @param movement Vetor de bytes com o movimento codificado.
	 * @param callback Objeto com o método de callback.
	 */
	private void internalSendMovement(final byte[] movement, final RobotMovingCallback callback) {
		Message request = BotMessageType.SETMOVEMENT_REQUEST.createMessage(movement.length);
		System.arraycopy(movement, 0, request.getBuffer(), 0, movement.length);
		callback.onRobotMoving(this.internalMove(request));
	}

	/**
	 * Méotdo interno que tetnta fazer o robô parar o movimento atual, executado na thread da fila de tarefas.
	 * 
	 * @return Flag indicando se a operação ocorreu com sucesso.
	 */
	private RobotMovementCallback.Result internalHalt() {
		DEBUG("RobotManager enviando comando de parada.");

		// verifica se está online atualmente.
		State state;
		synchronized (this) {
			state = m_state;
		}
		if (State.Moving == state || State.Idle == state) {
			DEBUG("RobotManager vai iniciar movimento.");
		} else {
			DEBUG("RobotManager tentou iniciar movimento, mas estava desconectado.");
			return RobotMovementCallback.Result.Closed;
		}

		Message request = BotMessageType.HALT_REQUEST.createMessage(0);
		Message reply = BotUtils.sendRequestAndRetry(DriverConstants.BOT_MAX_TRIES, m_flow, request, m_join, DriverConstants.BOT_DEFAULT_TIMEOUT, DriverConstants.BOT_INTERVAL_BETWEEN_TRIES);
		if (reply == null) {
			DEBUG("RobotManager não recebeu reply!");
			return RobotMovementCallback.Result.RobotTimeout;
		}
		if (reply.getType() != BotMessageType.HALT_REPLY.getType()) {
			DEBUG("RobotManager recebeu reply de tipo inválido!");
			return RobotMovementCallback.Result.UnexpectedRobotResponse;
		}
		DEBUG("RobotManager detectou que robô parou");
		return RobotMovementCallback.Result.Success;
	}

	/**
	 * Método interno que tenta fazer o robô executar um movimento, executado na thread da fila de tarefas.
	 * 
	 * @param setRequest Requisição de definir movimento.
	 * @return Flag indicando se a operação ocorreu com sucesso.
	 */
	private RobotMovementCallback.Result internalMove(Message setRequest) {
		Message request, reply;

		// verifica se está online atualmente.
		State state;
		synchronized (this) {
			state = m_state;
		}
		if (State.Moving == state || State.Idle == state) {
			DEBUG("RobotManager vai iniciar movimento.");
		} else {
			DEBUG("RobotManager tentou iniciar movimento, mas estava desconectado.");
			return RobotMovementCallback.Result.Closed;
		}

		// tenta enviar requisição de halt, se for necessário.
		if (state == State.Moving) {
			DEBUG("RobotManager enviando comando de parada.");
			request = BotMessageType.HALT_REQUEST.createMessage(0);
			reply = BotUtils.sendRequestAndRetry(DriverConstants.BOT_MAX_TRIES, m_flow, request, m_join, DriverConstants.BOT_DEFAULT_TIMEOUT, DriverConstants.BOT_INTERVAL_BETWEEN_TRIES);
			if (reply == null) {
				DEBUG("RobotManager não recebeu reply!");
				return RobotMovementCallback.Result.RobotTimeout;
			}
			if (reply.getType() != BotMessageType.HALT_REPLY.getType()) {
				DEBUG("RobotManager recebeu reply de tipo inválido!");
				return RobotMovementCallback.Result.UnexpectedRobotResponse;
			}
			DEBUG("RobotManager detectou que robô parou");
		} else {
			DEBUG("RobotManager detectou que robô já está parado");
		}

		// tenta enviar requisição de definir movimento.
		DEBUG("RobotManager enviando comando de definir movimento");
		request = setRequest;
		reply = BotUtils.sendRequestAndRetry(DriverConstants.BOT_MAX_TRIES, m_flow, request, m_join, DriverConstants.BOT_DEFAULT_TIMEOUT, DriverConstants.BOT_INTERVAL_BETWEEN_TRIES);
		if (reply == null) {
			DEBUG("RobotManager não recebeu reply");
			return RobotMovementCallback.Result.RobotTimeout;
		}
		if (reply.getType() == BotMessageType.HALT_REPLY.getType()) {
			DEBUG("RobotManager recebeu reply indicando movimento inválido");
			return RobotMovementCallback.Result.InvalidMovement;
		}
		if (reply.getType() != BotMessageType.SETMOVEMENT_REPLY.getType()) {
			DEBUG("RobotManager recebeu reply de tipo inválido");
			return RobotMovementCallback.Result.UnexpectedRobotResponse;
		}

		// tenta enviar requisição de acordar.
		DEBUG("RobotManager enviando comando de iniciar movimento");
		request = BotMessageType.MOVE_REQUEST.createMessage(0);
		reply = BotUtils.sendRequestAndRetry(DriverConstants.BOT_MAX_TRIES, m_flow, request, m_join, DriverConstants.BOT_DEFAULT_TIMEOUT, DriverConstants.BOT_INTERVAL_BETWEEN_TRIES);
		if (reply == null) {
			DEBUG("RobotManager não recebeu reply.");
			return RobotMovementCallback.Result.RobotTimeout;
		}
		if (reply.getType() != BotMessageType.MOVE_REPLY.getType()) {
			DEBUG("RobotManager recebeu reply de tipo inválido!");
			return RobotMovementCallback.Result.UnexpectedRobotResponse;
		}

		// retorna indicando sucesso.
		synchronized (this) {
			m_state = State.Moving;
		}
		return RobotMovementCallback.Result.Success;
	}

	/**
	 * Método interno que trata uma notificação de keep-alive recebida, executado na thread da fila de tarefas.
	 * 
	 * @param request Mensagem de notificação recebida.
	 * @param replier Objeto utilizado para responder.
	 */
	private void onKeepAliveNotification(Message request, FlowReplier replier) {
		Message reply = BotMessageType.KEEPALIVE_NOTIFICATION_REPLY.createMessage(request.getLength());
		System.arraycopy(request.getBuffer(), 0, reply.getBuffer(), 0, request.getLength());
		replier.sendReply(reply);
	}

	/**
	 * Método interno que trata uma notificação de término de movimento recebida, executado na thread da fila de tarefas.
	 * 
	 * @param request Mensagem de notificação recebida.
	 * @param replier Objeto utilizado para responder.
	 */
	private void onMovementFinishedNotification(Message request, FlowReplier replier) {
		if (request.getLength() >= 0x8) {
			m_driver.getClient().sendMovementFinishedNotification(request.getBuffer());
		}
		Message reply = BotMessageType.MOVEMENT_FINISHED_NOTIFICATION_REPLY.createMessage(0);
		replier.sendReply(reply);
	}

	/**
	 * Método interno que trata uma notificação de movimento abortado recebida, executado na thread da fila de tarefas.
	 * 
	 * @param request Mensagem de notificação recebida.
	 * @param replier Objeto utilizado para responder.
	 */
	private void onMovementAbortedNotification(Message request, FlowReplier replier) {
		if (request.getLength() >= 0xc) {
			m_driver.getClient().sendMovementAbortedNotification(request.getBuffer());
		}
		Message reply = BotMessageType.MOVEMENT_ABORTED_NOTIFICATION_REPLY.createMessage(0);
		replier.sendReply(reply);
	}

	/**
	 * Método interno que trata uma requisição recebida, executado na thread da fila de tarefas.
	 * 
	 * @param request Reqisição recebida.
	 * @param replier Objeto utilizado para responder.
	 */
	protected void onRequest(Message request, FlowReplier replier) {
		// verifica se está conectando.
		synchronized (this) {
			if (m_state == State.Opening) {
				Message errorReply = BotMessageType.ERROR_NOTIFICATION_REPLY.createMessage(0);
				replier.sendReply(errorReply);
				return;
			}
		}

		// verifica o tipo de mensagem recebida.
		switch (BotMessageType.get(request.getType())) {
			case KEEPALIVE_NOTIFICATION_REQUEST:
				this.onKeepAliveNotification(request, replier);
				return;
			case MOVEMENT_FINISHED_NOTIFICATION_REQUEST:
				this.onMovementFinishedNotification(request, replier);
				return;
			case MOVEMENT_ABORTED_NOTIFICATION_REQUEST:
				this.onMovementAbortedNotification(request, replier);
				return;
			default:
				Message errorReply = BotMessageType.ERROR_NOTIFICATION_REPLY.createMessage(0);
				replier.sendReply(errorReply);
				return;
		}
	}

	/**
	 * Classe com o callback de mensangens do controlador do robô.
	 */
	private static class MessageCallback implements MessageRequestCallback {
		private WeakReference<RobotManager> m_parent;

		public MessageCallback(RobotManager parent) {
			m_parent = new WeakReference<RobotManager>(parent);
		}

		/**
		 * {@inheritDoc}
		 */
		@Override
		public void onRequest(final Message request, final FlowReplier replier) {
			final RobotManager parent = m_parent.get();
			if (null != parent) {
				parent.m_jobs.enqueue(new Runnable() {
					@Override
					public void run() {
						parent.onRequest(request, replier);
					}
				});
			}
		}
	}
}
