package bot.driver;


public class DriverManager {
	/**
	 * Gera uma mensagem de debug.
	 * 
	 * @param message Mensagem.
	 */
	private static final void DEBUG(String message) {
		System.out.println(message);
		System.out.flush();
	}

	private ClientManager m_client;
	private RobotManager m_robot;

	/**
	 * Construtor protegido. Deve ser utilizado o método de factory.
	 */
	protected DriverManager() {
		DEBUG("DriverManager criado!");
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	protected void finalize() throws Throwable {
		super.finalize();
		DEBUG("DriverManager apagado!");
	}

	/**
	 * Constrói um controlador de driver.
	 * 
	 * @return Controlador de driver.
	 */
	public static DriverManager create() {
		return new DriverManager();
	}

	public ClientManager getClient() {
		return m_client;
	}

	public void setClient(ClientManager value) {
		m_client = value;
	}

	public RobotManager getRobot() {
		return m_robot;
	}

	public void setRobot(RobotManager value) {
		m_robot = value;
	}
}
