package br.edu.utfpr.hexapod2013;

import java.awt.CardLayout;
import java.awt.Color;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.GridLayout;
import java.awt.Insets;
import java.awt.SystemColor;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.lang.ref.WeakReference;

import javax.imageio.ImageIO;
import javax.swing.ButtonGroup;
import javax.swing.DefaultComboBoxModel;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JLayeredPane;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JSeparator;
import javax.swing.JSpinner;
import javax.swing.JTabbedPane;
import javax.swing.JTextField;
import javax.swing.SpinnerNumberModel;
import javax.swing.UIManager;
import javax.swing.border.CompoundBorder;
import javax.swing.border.EmptyBorder;
import javax.swing.border.LineBorder;
import javax.swing.border.TitledBorder;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import bot.AccelerometerData;
import bot.MagnetometerData;
import bot.callback.AccelerometerReadCallback;
import bot.callback.ConnectedCallback;
import bot.callback.DisconnectedCallback;
import bot.callback.MagnetometerReadCallback;
import bot.callback.MovementNotificationCallback;
import bot.callback.OfflineCallback;
import bot.callback.OpenedCallback;
import bot.callback.PortsEnumeratedCallback;
import bot.callback.RobotHaltedCallback;
import bot.callback.RobotMovingCallback;
import bot.client.RobotConnection;
import bot.constants.ClientConstants;

/**
 * Componente gráfico que gerencia uma conexão com o robõ.
 */
@SuppressWarnings({ "rawtypes", "serial" })
public class HexapodCommandsControl extends JPanel {
	/**
	 * Acoplamento fraco de eventos da RobotConnection.
	 */
	private static class WeakEvents implements MovementNotificationCallback, OfflineCallback {
		private WeakReference<HexapodCommandsControl> m_callback;
		private RobotConnection m_connection;

		/**
		 * Constrói um novo acoplamento fraco de eventos da RobotConnection.
		 * 
		 * @param connection Conexão com o robô.
		 * @param parent Componente gráfico.
		 */
		private WeakEvents(RobotConnection connection, HexapodCommandsControl parent) {
			m_connection = connection;
			m_callback = new WeakReference<HexapodCommandsControl>(parent);
		}

		/**
		 * Cria um novo acoplamento fraco de eventos da RobotConnection.
		 * 
		 * @param connection Conexão com o robô.
		 * @param parent Componente gráfico.
		 * @return Acoplamento fraco de eventos da RobotConnection.
		 */
		public static WeakEvents create(RobotConnection connection, HexapodCommandsControl parent) {
			WeakEvents events = new WeakEvents(connection, parent);
			connection.addMovementCallback(events);
			connection.addOfflineCallback(events);
			return events;
		}

		/**
		 * Elimina o acoplamento fraco de eventos.
		 */
		public void dispose() {
			if (null != m_connection) {
				m_connection.removeMovementCallback(this);
				m_connection.removeOfflineCallback(this);
				m_connection = null;
				m_callback.clear();
			}
		}

		/**
		 * {@inheritDoc}
		 */
		@Override
		public void onMoved(RobotConnection connection, int value, int length, int id, MovementNotificationCallback.Cause cause) {
			HexapodCommandsControl callback = m_callback.get();
			if (callback == null) {
				this.dispose();
			} else {
				callback.onMoved(connection, value, length, id, cause);
			}
		}

		/**
		 * {@inheritDoc}
		 */
		@Override
		public void onOffline(RobotConnection connection, OfflineCallback.Cause cause) {
			HexapodCommandsControl callback = m_callback.get();
			if (callback == null) {
				this.dispose();
			} else {
				callback.onOffline(connection, cause);
			}
		}
	}

	/**
	 * Enumeração de estados possíveis da interface gráfica.
	 */
	private enum State {
		/**
		 * Estado inválido.
		 */
		None,

		/**
		 * O cliente está desconectado.
		 */
		NotConnected,

		/**
		 * O cliente está conectando ao driver.
		 */
		OngoingConnection,

		/**
		 * O cliente falhou ao conectar ao driver.
		 */
		FailedConnection,

		/**
		 * O cliente está conectado ao driver.
		 */
		Connected,

		/**
		 * O cliente está atualizando a lista de portas.
		 */
		OngoingEnumeration,

		/**
		 * O cliente falhou ao atualizar a lista de portas.
		 */
		FailedEnumeration,

		/**
		 * O cliente está abrindo a conexão com um robô.
		 */
		OngoingOpening,

		/**
		 * O cliente não pôde abrir a conexão com o robô.
		 */
		FailedOpening,

		/**
		 * O cliente abriu a conexão com o robô.
		 */
		Opened,

		/**
		 * O cliente está tentando iniciar um movimento no robô.
		 */
		OngoingStartingMovement,

		/**
		 * O cliente não pôde iniciar um movimento no robô.
		 */
		FailedStartingMovement,

		/**
		 * O cliente iniciou um movimento no robô.
		 */
		MovementStarted,
	}

	private static final String CARD_CONNECT = "Connect to Driver Card";
	private static final String CARD_OPEN = "Open Robot Card";
	private static final String CARD_ONLINE = "Online Card";
	private static final String CARD_OVER_LOADING = "Loading Over Card";
	private static final String CARD_OVER_MESSAGE = "Message Over Card";

	private static final String LABEL_CONNECTING_ONGOING = "Tentando estabelecer conexão com o driver...";
	private static final String LABEL_CONNECTING_FAILED = "Não foi possível estabelecer a conexão com o driver.";

	private static final String TITLE_CONNECT = "Conectar-se a driver";
	private static final String LABEL_CONNECT_HOST = "Host";
	private static final String LABEL_CONNECT_PORT = "Porta";
	private static final String OPTION_CONNECT_CHANGEPORT = "usar outra";
	private static final String ACTION_CONNECT_TRY = "Conectar";

	private static final String TITLE_OPEN = "Conectar-se a rob\u00F4";
	private static final String LABEL_OPEN_PORTS = "Portas";
	private static final String ACTION_OPEN_REFRESHPORTS = "Atualizar";
	private static final String ACTION_OPEN_TRY = "Conectar";

	private static final String LABEL_SENSORS = "Sensores";

	private static final String LABEL_MAGNETOMETER = "Magnet\u00F4metro";
	private static final String LABEL_MAGNETOMETER_X = "X:";
	private static final String LABEL_MAGNETOMETER_Y = "Y:";
	private static final String LABEL_MAGNETOMETER_Z = "Z:";
	private static final String LABEL_MAGNETOMETER_HEADING = "\u00C2ngulo:";
	private static final String ACTION_MAGNETOMETER_REFRESH = "Atualizar";

	private static final String LABEL_ACCELEROMETER = "Aceler\u00F4metro";
	private static final String LABEL_ACCELEROMETER_X = "X:";
	private static final String LABEL_ACCELEROMETER_Y = "Y:";
	private static final String LABEL_ACCELEROMETER_Z = "Z:";
	private static final String ACTION_ACCELEROMETER_REFRESH = "Atualizar";

	private static final String TITLE_WALK = "Andar";
	private static final String LABEL_WALK_DISTANCE = "N\u00FAmero de passos:";
	private static final String LABEL_WALK_BACKWARDS = "para trás";
	private static final String ACTION_WALK_TRY = "Iniciar";

	private static final String TITLE_WALKSIDEWAYS = "Andar de lado";
	private static final String LABEL_WALKSIDEWAYS_DISTANCE = "N\u00FAmero de passos:";
	private static final String LABEL_WALKSIDEWAYS_LEFTTORIGHT = "esquerda para direita";
	private static final String LABEL_WALKSIDEWAYS_RIGHTTOLEFT = "direita para esquerda";
	private static final String ACTION_WALKSIDEWAYS_TRY = "Iniciar";

	private static final String TITLE_WALKTO = "Andar alinhado";
	private static final String LABEL_WALKTO_DISTANCE = "N\u00FAmero de passos:";
	private static final String LABEL_WALKTO_BACKWARDS = "para trás";
	private static final String LABEL_WALKTO_ANGLE = "Ângulo em graus relativo ao norte:";
	private static final String ACTION_WALKTO_TRY = "Iniciar";

	private static final String TITLE_ROTATE = "Rotacionar";
	private static final String LABEL_ROTATE_ANGLE = "Quantos graus:";
	private static final String LABEL_ROTATE_CLOCKWISE = "sentido horário";
	private static final String LABEL_ROTATE_COUNTERCLOCKWISE = "sentido anti-horário";
	private static final String ACTION_ROTATE_TRY = "Iniciar";

	private static final String TITLE_LOOKTO = "Olhar para";
	private static final String LABEL_LOOKTO_ANGLE = "Ângulo em graus relativo ao norte:";
	private static final String ACTION_LOOKTO_TRY = "Iniciar";

	private static final String TITLE_PUSHUP = "Flexões";
	private static final String LABEL_PUSHUP_COUNT = "N\u00FAmero de flexões:";
	private static final String ACTION_PUSHUP_TRY = "Iniciar";

	private static final String TITLE_HULAHOOP = "Bambolear";
	private static final String LABEL_HULAHOOP_COUNT = "N\u00FAmero de bamboleadas:";
	private static final String ACTION_HULAHOOP_TRY = "Iniciar";

	private static final String TITLE_PUNCH = "Socar";
	private static final String LABEL_PUNCH_COUNT = "N\u00FAmero de socos:";
	private static final String ACTION_PUNCH_TRY = "Iniciar";

	private static final String TITLE_ADJUST = "Ajustar";
	private static final String ACTION_ADJUST_TRY = "Iniciar";

	private static final String LABEL_LOADING = "Carregando...";
	private static final String LABEL_DIDNOTENUMERATEPORTS_MESSAGE = "Não foi possível obter a lista de portas.";
	private static final String LABEL_DIDNOTOPEN_MESSAGE = "Não foi possível estabelecer a conexão com o robô.";
	private static final String LABEL_DIDNOTMOVE_MESSAGE = "Não pôde iniciar movimento.";
	private static final String LABEL_ISMOVING_MESSAGE = "Um movimento está em andamento.";
	private static final String ACTION_MESSAGE_CLOSE = "Fechar";
	private static final String ACTION_MESSAGE_ABORT = "Parar";

	private State m_state = State.None;

	private RobotConnection m_connection;

	private BufferedImage m_image;

	private int m_currentId;

	private String[] m_ports;

	private JPanel bottomCardbox;
	private CardLayout bottomLayout;

	private JTextField hostText;
	private JSpinner portSpinner;
	private JCheckBox portCheckbox;
	private JButton connectButton;

	private JComboBox openCombo;
	private JButton enumeratePortsButton;
	private JButton openButton;

	private JSpinner walkSpinner;
	private JCheckBox walkCheckbox;
	private JButton walkButton;

	private ButtonGroup walkSidewaysGroup;
	private JSpinner walkSidewaysSpinner;
	private JRadioButton walkSidewaysLeftToRightRadio;
	private JRadioButton walkSidewaysRightToLeftRadio;
	private JButton walkSidewaysButton;

	private JSpinner walkToSpinner1;
	private JSpinner walkToSpinner2;
	private JCheckBox walkToCheckbox;
	private JButton walkToButton;

	private ButtonGroup rotateGroup;
	private JSpinner rotateSpinner;
	private JRadioButton rotateClockwiseRadio;
	private JRadioButton rotateCounterclockwiseRadio;
	private JButton rotateButton;

	private JSpinner lookToSpinner;
	private JButton lookToButton;

	private JSpinner pushUpSpinner;
	private JButton pushUpButton;

	private JSpinner hulaHoopSpinner;
	private JButton hulaHoopButton;

	private JSpinner punchSpinner;
	private JButton punchButton;

	private JButton adjustButton;

	private JLayeredPane overPanel;
	private JPanel overCardbox;
	private CardLayout overLayout;

	private JPanel loadingPanel;
	private JLabel loadingLabel;

	private JPanel messagePanel;
	private JLabel messageLabel;
	private JButton messageButton;

	private JLabel magnetometerX;
	private JLabel magnetometerY;
	private JLabel magnetometerZ;
	private JLabel magnetometerAngle;
	private JButton magnetometerButton;

	private JLabel accelerometerX;
	private JLabel accelerometerY;
	private JLabel accelerometerZ;
	private JButton accelerometerButton;

	public HexapodCommandsControl() {
		UIManager.put("TabbedPane.contentOpaque", false);
		try {
			UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
		} catch (Exception e) {}
		try {
			m_image = ImageIO.read(HexapodCommandsControl.class.getResource("background.png"));
		} catch (IOException e) {}
		m_connection = RobotConnection.create();
		this.init();
		WeakEvents.create(m_connection, this);
		this.gotoState(State.NotConnected);
	}

	private void init() {
		setOpaque(false);
		GridBagLayout gridBagLayout = new GridBagLayout();
		gridBagLayout.columnWidths = new int[] { 0 };
		gridBagLayout.rowHeights = new int[] { 0 };
		gridBagLayout.columnWeights = new double[] { 1.0 };
		gridBagLayout.rowWeights = new double[] { 1.0 };
		setLayout(gridBagLayout);

		JLayeredPane mainPanel = new JLayeredPane();
		mainPanel.setBorder(null);
		mainPanel.setOpaque(true);
		GridBagConstraints gbc_mainPanel = new GridBagConstraints();
		gbc_mainPanel.fill = GridBagConstraints.BOTH;
		gbc_mainPanel.gridx = 0;
		gbc_mainPanel.gridy = 0;
		add(mainPanel, gbc_mainPanel);
		GridBagLayout gbl_mainPanel = new GridBagLayout();
		gbl_mainPanel.columnWidths = new int[] { 0 };
		gbl_mainPanel.rowHeights = new int[] { 0 };
		gbl_mainPanel.columnWeights = new double[] { 1.0 };
		gbl_mainPanel.rowWeights = new double[] { 1.0 };
		mainPanel.setLayout(gbl_mainPanel);

		StretchImageComponent background = new StretchImageComponent();
		background.setOpaque(false);
		background.setImage(m_image);
		GridBagConstraints gbc_background = new GridBagConstraints();
		gbc_background.fill = GridBagConstraints.BOTH;
		gbc_background.gridx = 0;
		gbc_background.gridy = 0;
		mainPanel.add(background, gbc_background);
		mainPanel.setLayer(background, 0);

		bottomCardbox = new JPanel();
		bottomCardbox.setBorder(new EmptyBorder(10, 10, 10, 10));
		bottomCardbox.setOpaque(false);
		GridBagConstraints gbc_bottomCardbox = new GridBagConstraints();
		gbc_bottomCardbox.fill = GridBagConstraints.BOTH;
		gbc_bottomCardbox.gridx = 0;
		gbc_bottomCardbox.gridy = 0;
		mainPanel.add(bottomCardbox, gbc_bottomCardbox);
		mainPanel.setLayer(bottomCardbox, 1);
		bottomLayout = new CardLayout(0, 0);
		bottomCardbox.setLayout(bottomLayout);

		JPanel connectCard = new JPanel();
		connectCard.setOpaque(false);
		bottomCardbox.add(connectCard, CARD_CONNECT);
		GridBagLayout gbl_connectCard = new GridBagLayout();
		gbl_connectCard.columnWidths = new int[] { 0 };
		gbl_connectCard.rowHeights = new int[] { 0 };
		gbl_connectCard.columnWeights = new double[] { 1.0 };
		gbl_connectCard.rowWeights = new double[] { 1.0 };
		connectCard.setLayout(gbl_connectCard);
		JPanel connectPanel = new JPanel();
		connectPanel.setBorder(new CompoundBorder(new TitledBorder(new LineBorder(new Color(0, 0, 0), 2), TITLE_CONNECT, TitledBorder.CENTER, TitledBorder.TOP, null, null), new EmptyBorder(5, 5, 5, 5)));
		GridBagConstraints gbc_connectPanel = new GridBagConstraints();
		connectCard.add(connectPanel, gbc_connectPanel);
		GridBagLayout gbl_connectPanel = new GridBagLayout();
		gbl_connectPanel.columnWidths = new int[] { 0, 0, 0 };
		gbl_connectPanel.rowHeights = new int[] { 0, 0, 0 };
		gbl_connectPanel.columnWeights = new double[] { 0.0, 1.0, 0.0 };
		gbl_connectPanel.rowWeights = new double[] { 0.0, 0.0, 0.0 };
		connectPanel.setLayout(gbl_connectPanel);

		JLabel connectLabel1 = new JLabel(LABEL_CONNECT_HOST + ":");
		GridBagConstraints gbc_connectLabel1 = new GridBagConstraints();
		gbc_connectLabel1.anchor = GridBagConstraints.EAST;
		gbc_connectLabel1.insets = new Insets(0, 0, 5, 5);
		gbc_connectLabel1.gridx = 0;
		gbc_connectLabel1.gridy = 0;
		connectPanel.add(connectLabel1, gbc_connectLabel1);

		hostText = new JTextField("192.168.1.107");
		GridBagConstraints gbc_hostText = new GridBagConstraints();
		gbc_hostText.gridwidth = 2;
		gbc_hostText.insets = new Insets(0, 0, 5, 0);
		gbc_hostText.fill = GridBagConstraints.HORIZONTAL;
		gbc_hostText.gridx = 1;
		gbc_hostText.gridy = 0;
		connectPanel.add(hostText, gbc_hostText);
		hostText.setColumns(10);

		JLabel connectLabel2 = new JLabel(LABEL_CONNECT_PORT + ":");
		GridBagConstraints gbc_connectLabel2 = new GridBagConstraints();
		gbc_connectLabel2.insets = new Insets(0, 0, 5, 5);
		gbc_connectLabel2.gridx = 0;
		gbc_connectLabel2.gridy = 1;
		connectPanel.add(connectLabel2, gbc_connectLabel2);

		portSpinner = new JSpinner();
		portSpinner.setEnabled(false);
		portSpinner.setModel(new SpinnerNumberModel(new Integer(60890), null, null, new Integer(1)));
		portSpinner.setValue(60890);
		GridBagConstraints gbc_portSpinner = new GridBagConstraints();
		gbc_portSpinner.insets = new Insets(0, 0, 5, 5);
		gbc_portSpinner.fill = GridBagConstraints.BOTH;
		gbc_portSpinner.gridx = 1;
		gbc_portSpinner.gridy = 1;
		connectPanel.add(portSpinner, gbc_portSpinner);

		portCheckbox = new JCheckBox(OPTION_CONNECT_CHANGEPORT);
		portCheckbox.addChangeListener(new ChangeListener() {
			public void stateChanged(ChangeEvent e) {
				HexapodCommandsControl.this.onPortCheckboxChanged();
			}
		});
		GridBagConstraints gbc_portCheckbox = new GridBagConstraints();
		gbc_portCheckbox.insets = new Insets(0, 0, 5, 0);
		gbc_portCheckbox.gridx = 2;
		gbc_portCheckbox.gridy = 1;
		connectPanel.add(portCheckbox, gbc_portCheckbox);

		connectButton = new JButton(ACTION_CONNECT_TRY);
		connectButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				HexapodCommandsControl.this.onConnectToDriverClicked();
			}
		});
		connectButton.setSelected(true);
		connectButton.setMargin(new Insets(4, 6, 4, 6));
		GridBagConstraints gbc_connectButton = new GridBagConstraints();
		gbc_connectButton.insets = new Insets(0, 0, 5, 5);
		gbc_connectButton.anchor = GridBagConstraints.SOUTHEAST;
		gbc_connectButton.gridwidth = 3;
		gbc_connectButton.gridx = 0;
		gbc_connectButton.gridy = 2;
		connectPanel.add(connectButton, gbc_connectButton);

		JPanel openCard = new JPanel();
		openCard.setOpaque(false);
		bottomCardbox.add(openCard, CARD_OPEN);
		GridBagLayout gbl_openCard = new GridBagLayout();
		gbl_openCard.columnWidths = new int[] { 0 };
		gbl_openCard.rowHeights = new int[] { 0 };
		gbl_openCard.columnWeights = new double[] { 1.0 };
		gbl_openCard.rowWeights = new double[] { 1.0 };
		openCard.setLayout(gbl_openCard);

		JPanel openPanel = new JPanel();
		openPanel.setBorder(new CompoundBorder(new TitledBorder(new LineBorder(new Color(0, 0, 0), 2), TITLE_OPEN, TitledBorder.CENTER, TitledBorder.TOP, null, null), new EmptyBorder(5, 5, 5, 5)));
		GridBagConstraints gbc_openPanel = new GridBagConstraints();
		gbc_openPanel.gridx = 0;
		gbc_openPanel.gridy = 0;
		openCard.add(openPanel, gbc_openPanel);
		GridBagLayout gbl_openPanel = new GridBagLayout();
		gbl_openPanel.columnWidths = new int[] { 0, 0 };
		gbl_openPanel.rowHeights = new int[] { 0, 0 };
		gbl_openPanel.columnWeights = new double[] { 0.0, 1.0 };
		gbl_openPanel.rowWeights = new double[] { 0.0, 0.0 };
		openPanel.setLayout(gbl_openPanel);

		JLabel openLabel = new JLabel(LABEL_OPEN_PORTS + ":");
		GridBagConstraints gbc_openLabel = new GridBagConstraints();
		gbc_openLabel.insets = new Insets(0, 0, 5, 5);
		gbc_openLabel.anchor = GridBagConstraints.EAST;
		gbc_openLabel.gridx = 0;
		gbc_openLabel.gridy = 0;
		openPanel.add(openLabel, gbc_openLabel);

		openCombo = new JComboBox();
		GridBagConstraints gbc_openCombo = new GridBagConstraints();
		gbc_openCombo.insets = new Insets(0, 0, 5, 0);
		gbc_openCombo.fill = GridBagConstraints.HORIZONTAL;
		gbc_openCombo.gridx = 1;
		gbc_openCombo.gridy = 0;
		openPanel.add(openCombo, gbc_openCombo);

		JPanel openButtonsPanel = new JPanel();
		GridBagConstraints gbc_openButtonsPanel = new GridBagConstraints();
		gbc_openButtonsPanel.anchor = GridBagConstraints.EAST;
		gbc_openButtonsPanel.gridwidth = 2;
		gbc_openButtonsPanel.gridx = 0;
		gbc_openButtonsPanel.gridy = 1;
		openPanel.add(openButtonsPanel, gbc_openButtonsPanel);
		GridBagLayout gbl_openButtonsPanel = new GridBagLayout();
		gbl_openButtonsPanel.columnWidths = new int[] { 0, 0, 0 };
		gbl_openButtonsPanel.rowHeights = new int[] { 0, 0 };
		gbl_openButtonsPanel.columnWeights = new double[] { 0.0, 0.0, Double.MIN_VALUE };
		gbl_openButtonsPanel.rowWeights = new double[] { 0.0, Double.MIN_VALUE };
		openButtonsPanel.setLayout(gbl_openButtonsPanel);

		enumeratePortsButton = new JButton(ACTION_OPEN_REFRESHPORTS);
		enumeratePortsButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				HexapodCommandsControl.this.onRefreshPortsButtonClicked();
			}
		});
		enumeratePortsButton.setMargin(new Insets(4, 6, 4, 6));
		GridBagConstraints gbc_enumeratePortsButton = new GridBagConstraints();
		gbc_enumeratePortsButton.insets = new Insets(0, 0, 0, 5);
		gbc_enumeratePortsButton.gridx = 0;
		gbc_enumeratePortsButton.gridy = 0;
		openButtonsPanel.add(enumeratePortsButton, gbc_enumeratePortsButton);

		openButton = new JButton(ACTION_OPEN_TRY);
		openButton.setSelected(true);
		openButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				HexapodCommandsControl.this.onConnectToPortButtonClicked();
			}
		});
		openButton.setMargin(new Insets(4, 6, 4, 6));
		GridBagConstraints gbc_openButton = new GridBagConstraints();
		gbc_openButton.gridx = 1;
		gbc_openButton.gridy = 0;
		openButtonsPanel.add(openButton, gbc_openButton);

		JPanel onlineCard = new JPanel();
		onlineCard.setOpaque(false);
		bottomCardbox.add(onlineCard, CARD_ONLINE);
		GridBagLayout gbl_onlineCard = new GridBagLayout();
		gbl_onlineCard.columnWidths = new int[] { 0 };
		gbl_onlineCard.rowHeights = new int[] { 0 };
		gbl_onlineCard.columnWeights = new double[] { 1.0 };
		gbl_onlineCard.rowWeights = new double[] { 1.0 };
		onlineCard.setLayout(gbl_onlineCard);

		JPanel sensorsView = new JPanel();
		sensorsView.setBorder(new TitledBorder(new LineBorder(new Color(0, 0, 0), 2), LABEL_SENSORS, TitledBorder.LEADING, TitledBorder.TOP, null, null));
		GridBagConstraints gbc_sensorsView = new GridBagConstraints();
		gbc_sensorsView.insets = new Insets(5, 0, 0, 0);
		gbc_sensorsView.gridx = 0;
		gbc_sensorsView.gridy = 1;
		onlineCard.add(sensorsView, gbc_sensorsView);
		GridBagLayout gbl_sensorsView = new GridBagLayout();
		gbl_sensorsView.columnWidths = new int[] { 0, 0 };
		gbl_sensorsView.rowHeights = new int[] { 0 };
		gbl_sensorsView.columnWeights = new double[] { 1.0, 1.0 };
		gbl_sensorsView.rowWeights = new double[] { 1.0 };
		sensorsView.setLayout(gbl_sensorsView);

		JPanel magnetometerPanel = new JPanel();
		magnetometerPanel.setBorder(new CompoundBorder(new TitledBorder(new LineBorder(new Color(0, 0, 0), 2), LABEL_MAGNETOMETER, TitledBorder.LEADING, TitledBorder.TOP, null, null), new EmptyBorder(5, 5, 5, 5)));
		GridBagConstraints gbc_magnetometerPanel = new GridBagConstraints();
		gbc_magnetometerPanel.fill = GridBagConstraints.BOTH;
		gbc_magnetometerPanel.insets = new Insets(0, 0, 0, 5);
		gbc_magnetometerPanel.gridx = 0;
		gbc_magnetometerPanel.gridy = 0;
		sensorsView.add(magnetometerPanel, gbc_magnetometerPanel);
		GridBagLayout gbl_magnetometerPanel = new GridBagLayout();
		gbl_magnetometerPanel.columnWidths = new int[] { 0, 0 };
		gbl_magnetometerPanel.rowHeights = new int[] { 0, 0, 0, 0, 0, 0 };
		gbl_magnetometerPanel.columnWeights = new double[] { 1.0, 1.0 };
		gbl_magnetometerPanel.rowWeights = new double[] { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };
		magnetometerPanel.setLayout(gbl_magnetometerPanel);

		JLabel magnetometerFiller = new JLabel("                                ");
		GridBagConstraints gbc_magnetometerFiller = new GridBagConstraints();
		gbc_magnetometerFiller.insets = new Insets(0, 0, 0, 0);
		gbc_magnetometerFiller.fill = GridBagConstraints.HORIZONTAL;
		gbc_magnetometerFiller.gridheight = 5;
		gbc_magnetometerFiller.gridx = 1;
		gbc_magnetometerFiller.gridy = 0;
		magnetometerPanel.add(magnetometerFiller, gbc_magnetometerFiller);

		JLabel magnetometerLabelX = new JLabel(LABEL_MAGNETOMETER_X);
		GridBagConstraints gbc_magnetometerLabelX = new GridBagConstraints();
		gbc_magnetometerLabelX.anchor = GridBagConstraints.EAST;
		gbc_magnetometerLabelX.insets = new Insets(0, 0, 5, 5);
		gbc_magnetometerLabelX.gridx = 0;
		gbc_magnetometerLabelX.gridy = 0;
		magnetometerPanel.add(magnetometerLabelX, gbc_magnetometerLabelX);

		magnetometerX = new JLabel();
		GridBagConstraints gbc_magnetometerX = new GridBagConstraints();
		gbc_magnetometerX.insets = new Insets(0, 0, 5, 0);
		gbc_magnetometerX.fill = GridBagConstraints.HORIZONTAL;
		gbc_magnetometerX.gridx = 1;
		gbc_magnetometerX.gridy = 0;
		magnetometerPanel.add(magnetometerX, gbc_magnetometerX);

		JLabel magnetometerLabelY = new JLabel(LABEL_MAGNETOMETER_Y);
		GridBagConstraints gbc_magnetometerLabelY = new GridBagConstraints();
		gbc_magnetometerLabelY.anchor = GridBagConstraints.EAST;
		gbc_magnetometerLabelY.insets = new Insets(0, 0, 5, 5);
		gbc_magnetometerLabelY.gridx = 0;
		gbc_magnetometerLabelY.gridy = 1;
		magnetometerPanel.add(magnetometerLabelY, gbc_magnetometerLabelY);

		magnetometerY = new JLabel();
		GridBagConstraints gbc_magnetometerY = new GridBagConstraints();
		gbc_magnetometerY.insets = new Insets(0, 0, 5, 0);
		gbc_magnetometerY.fill = GridBagConstraints.HORIZONTAL;
		gbc_magnetometerY.gridx = 1;
		gbc_magnetometerY.gridy = 1;
		magnetometerPanel.add(magnetometerY, gbc_magnetometerY);

		JLabel magnetometerLabelZ = new JLabel(LABEL_MAGNETOMETER_Z);
		GridBagConstraints gbc_magnetometerLabelZ = new GridBagConstraints();
		gbc_magnetometerLabelZ.anchor = GridBagConstraints.EAST;
		gbc_magnetometerLabelZ.insets = new Insets(0, 0, 5, 5);
		gbc_magnetometerLabelZ.gridx = 0;
		gbc_magnetometerLabelZ.gridy = 2;
		magnetometerPanel.add(magnetometerLabelZ, gbc_magnetometerLabelZ);

		magnetometerZ = new JLabel();
		GridBagConstraints gbc_magnetometerZ = new GridBagConstraints();
		gbc_magnetometerZ.insets = new Insets(0, 0, 5, 0);
		gbc_magnetometerZ.fill = GridBagConstraints.HORIZONTAL;
		gbc_magnetometerZ.gridx = 1;
		gbc_magnetometerZ.gridy = 2;
		magnetometerPanel.add(magnetometerZ, gbc_magnetometerZ);

		JSeparator separator = new JSeparator();
		GridBagConstraints gbc_separator = new GridBagConstraints();
		gbc_separator.fill = GridBagConstraints.HORIZONTAL;
		gbc_separator.insets = new Insets(0, 0, 5, 0);
		gbc_separator.gridwidth = 2;
		gbc_separator.gridx = 0;
		gbc_separator.gridy = 3;
		magnetometerPanel.add(separator, gbc_separator);

		JLabel magnetometerLabelAngle = new JLabel(LABEL_MAGNETOMETER_HEADING);
		GridBagConstraints gbc_magnetometerLabelAngle = new GridBagConstraints();
		gbc_magnetometerLabelAngle.anchor = GridBagConstraints.EAST;
		gbc_magnetometerLabelAngle.insets = new Insets(0, 0, 5, 5);
		gbc_magnetometerLabelAngle.gridx = 0;
		gbc_magnetometerLabelAngle.gridy = 4;
		magnetometerPanel.add(magnetometerLabelAngle, gbc_magnetometerLabelAngle);

		magnetometerAngle = new JLabel();
		GridBagConstraints gbc_magnetometerAngle = new GridBagConstraints();
		gbc_magnetometerAngle.fill = GridBagConstraints.HORIZONTAL;
		gbc_magnetometerAngle.insets = new Insets(0, 0, 5, 0);
		gbc_magnetometerAngle.gridx = 1;
		gbc_magnetometerAngle.gridy = 4;
		magnetometerPanel.add(magnetometerAngle, gbc_magnetometerAngle);

		magnetometerButton = new JButton(ACTION_MAGNETOMETER_REFRESH);
		magnetometerButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				HexapodCommandsControl.this.onMagnetometerButtonClicked();
			}
		});
		magnetometerButton.setMargin(new Insets(4, 6, 4, 6));
		GridBagConstraints gbc_magnetometerButton = new GridBagConstraints();
		gbc_magnetometerButton.insets = new Insets(0, 0, 0, 0);
		gbc_magnetometerButton.fill = GridBagConstraints.NONE;
		gbc_magnetometerButton.gridwidth = 2;
		gbc_magnetometerButton.gridx = 0;
		gbc_magnetometerButton.gridy = 5;
		magnetometerPanel.add(magnetometerButton, gbc_magnetometerButton);

		JPanel accelerometerPanel = new JPanel();
		accelerometerPanel.setBorder(new CompoundBorder(new TitledBorder(new LineBorder(new Color(0, 0, 0), 2), LABEL_ACCELEROMETER, TitledBorder.LEADING, TitledBorder.TOP, null, null), new EmptyBorder(5, 5, 5, 5)));
		GridBagConstraints gbc_accelerometerPanel = new GridBagConstraints();
		gbc_accelerometerPanel.fill = GridBagConstraints.BOTH;
		gbc_accelerometerPanel.gridx = 1;
		gbc_accelerometerPanel.gridy = 0;
		sensorsView.add(accelerometerPanel, gbc_accelerometerPanel);
		GridBagLayout gbl_accelerometerPanel = new GridBagLayout();
		gbl_accelerometerPanel.columnWidths = new int[] { 0, 0 };
		gbl_accelerometerPanel.rowHeights = new int[] { 0, 0, 0, 0 };
		gbl_accelerometerPanel.columnWeights = new double[] { 1.0, 1.0 };
		gbl_accelerometerPanel.rowWeights = new double[] { 0.0, 0.0, 0.0, 0.0 };
		accelerometerPanel.setLayout(gbl_accelerometerPanel);

		JLabel accelerometerFiller = new JLabel("                                ");
		GridBagConstraints gbc_accelerometerFiller = new GridBagConstraints();
		gbc_accelerometerFiller.insets = new Insets(0, 0, 0, 0);
		gbc_accelerometerFiller.fill = GridBagConstraints.HORIZONTAL;
		gbc_accelerometerFiller.gridheight = 5;
		gbc_accelerometerFiller.gridx = 1;
		gbc_accelerometerFiller.gridy = 0;
		accelerometerPanel.add(accelerometerFiller, gbc_accelerometerFiller);

		JLabel accelerometerLabelX = new JLabel(LABEL_ACCELEROMETER_X);
		GridBagConstraints gbc_accelerometerLabelX = new GridBagConstraints();
		gbc_accelerometerLabelX.anchor = GridBagConstraints.EAST;
		gbc_accelerometerLabelX.insets = new Insets(0, 0, 5, 5);
		gbc_accelerometerLabelX.gridx = 0;
		gbc_accelerometerLabelX.gridy = 0;
		accelerometerPanel.add(accelerometerLabelX, gbc_accelerometerLabelX);

		accelerometerX = new JLabel();
		GridBagConstraints gbc_accelerometerX = new GridBagConstraints();
		gbc_accelerometerX.insets = new Insets(0, 0, 5, 0);
		gbc_accelerometerX.fill = GridBagConstraints.HORIZONTAL;
		gbc_accelerometerX.gridx = 1;
		gbc_accelerometerX.gridy = 0;
		accelerometerPanel.add(accelerometerX, gbc_accelerometerX);

		JLabel accelerometerLabelY = new JLabel(LABEL_ACCELEROMETER_Y);
		GridBagConstraints gbc_accelerometerLabelY = new GridBagConstraints();
		gbc_accelerometerLabelY.anchor = GridBagConstraints.EAST;
		gbc_accelerometerLabelY.insets = new Insets(0, 0, 5, 5);
		gbc_accelerometerLabelY.gridx = 0;
		gbc_accelerometerLabelY.gridy = 1;
		accelerometerPanel.add(accelerometerLabelY, gbc_accelerometerLabelY);

		accelerometerY = new JLabel();
		GridBagConstraints gbc_accelerometerY = new GridBagConstraints();
		gbc_accelerometerY.insets = new Insets(0, 0, 5, 0);
		gbc_accelerometerY.fill = GridBagConstraints.HORIZONTAL;
		gbc_accelerometerY.gridx = 1;
		gbc_accelerometerY.gridy = 1;
		accelerometerPanel.add(accelerometerY, gbc_accelerometerY);

		JLabel accelerometerLabelZ = new JLabel(LABEL_ACCELEROMETER_Z);
		GridBagConstraints gbc_accelerometerLabelZ = new GridBagConstraints();
		gbc_accelerometerLabelZ.anchor = GridBagConstraints.EAST;
		gbc_accelerometerLabelZ.insets = new Insets(0, 0, 5, 5);
		gbc_accelerometerLabelZ.gridx = 0;
		gbc_accelerometerLabelZ.gridy = 2;
		accelerometerPanel.add(accelerometerLabelZ, gbc_accelerometerLabelZ);

		accelerometerZ = new JLabel();
		GridBagConstraints gbc_accelerometerZ = new GridBagConstraints();
		gbc_accelerometerZ.insets = new Insets(0, 0, 5, 0);
		gbc_accelerometerZ.fill = GridBagConstraints.HORIZONTAL;
		gbc_accelerometerZ.gridx = 1;
		gbc_accelerometerZ.gridy = 2;
		accelerometerPanel.add(accelerometerZ, gbc_accelerometerZ);

		accelerometerButton = new JButton(ACTION_ACCELEROMETER_REFRESH);
		accelerometerButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				HexapodCommandsControl.this.onAccelerometerButtonClicked();
			}
		});
		accelerometerButton.setMargin(new Insets(4, 6, 4, 6));
		GridBagConstraints gbc_accelerometerButton = new GridBagConstraints();
		gbc_accelerometerButton.insets = new Insets(0, 0, 0, 0);
		gbc_accelerometerButton.fill = GridBagConstraints.NONE;
		gbc_accelerometerButton.gridwidth = 2;
		gbc_accelerometerButton.gridx = 0;
		gbc_accelerometerButton.gridy = 3;
		accelerometerPanel.add(accelerometerButton, gbc_accelerometerButton);

		JTabbedPane onlineTabs = new JTabbedPane(JTabbedPane.TOP);
		GridBagConstraints gbc_onlineTabs = new GridBagConstraints();
		gbc_onlineTabs.fill = GridBagConstraints.BOTH;
		gbc_onlineTabs.gridx = 0;
		gbc_onlineTabs.gridy = 0;
		onlineCard.add(onlineTabs, gbc_onlineTabs);

		JLayeredPane walkTab = new JLayeredPane();
		onlineTabs.addTab(TITLE_WALK, null, walkTab, null);
		onlineTabs.setEnabledAt(0, true);
		GridBagLayout gbl_walkTab = new GridBagLayout();
		gbl_walkTab.columnWidths = new int[] { 0 };
		gbl_walkTab.rowHeights = new int[] { 0 };
		gbl_walkTab.columnWeights = new double[] { 1.0 };
		gbl_walkTab.rowWeights = new double[] { 1.0 };
		walkTab.setLayout(gbl_walkTab);

		TranslucidRectagleComponent walkBackground = new TranslucidRectagleComponent();
		walkBackground.setTransparence(0.25f);
		walkBackground.setColor(SystemColor.control);
		GridBagConstraints gbc_walkBackground = new GridBagConstraints();
		gbc_walkBackground.fill = GridBagConstraints.BOTH;
		gbc_walkBackground.gridx = 0;
		gbc_walkBackground.gridy = 0;
		walkTab.add(walkBackground, gbc_walkBackground);

		JPanel walkPanel = new JPanel();
		walkPanel.setBorder(new EmptyBorder(5, 5, 5, 5));
		walkPanel.setOpaque(false);
		walkTab.setLayer(walkPanel, 1);
		GridBagConstraints gbc_walkPanel = new GridBagConstraints();
		gbc_walkPanel.fill = GridBagConstraints.BOTH;
		gbc_walkPanel.gridx = 0;
		gbc_walkPanel.gridy = 0;
		walkTab.add(walkPanel, gbc_walkPanel);
		GridBagLayout gbl_walkPanel = new GridBagLayout();
		gbl_walkPanel.columnWidths = new int[] { 0, 0, 0 };
		gbl_walkPanel.rowHeights = new int[] { 0, 0 };
		gbl_walkPanel.columnWeights = new double[] { 0.0, 1.0, 0.0 };
		gbl_walkPanel.rowWeights = new double[] { 0.0, 0.0 };
		walkPanel.setLayout(gbl_walkPanel);

		JLabel walkLabel = new JLabel(LABEL_WALK_DISTANCE);
		GridBagConstraints gbc_walkLabel = new GridBagConstraints();
		gbc_walkLabel.insets = new Insets(0, 0, 5, 5);
		gbc_walkLabel.gridx = 0;
		gbc_walkLabel.gridy = 0;
		walkPanel.add(walkLabel, gbc_walkLabel);

		walkSpinner = new JSpinner();
		walkSpinner.setModel(new SpinnerNumberModel(1, 1, 30, 1));
		GridBagConstraints gbc_walkSpinner = new GridBagConstraints();
		gbc_walkSpinner.fill = GridBagConstraints.HORIZONTAL;
		gbc_walkSpinner.insets = new Insets(0, 0, 5, 5);
		gbc_walkSpinner.gridx = 1;
		gbc_walkSpinner.gridy = 0;
		walkPanel.add(walkSpinner, gbc_walkSpinner);

		walkCheckbox = new JCheckBox(LABEL_WALK_BACKWARDS);
		GridBagConstraints gbc_walkCheckbox = new GridBagConstraints();
		gbc_walkCheckbox.insets = new Insets(0, 0, 5, 0);
		gbc_walkCheckbox.gridx = 2;
		gbc_walkCheckbox.gridy = 0;
		walkPanel.add(walkCheckbox, gbc_walkCheckbox);

		walkButton = new JButton(ACTION_WALK_TRY);
		walkButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				HexapodCommandsControl.this.onWalkButtonClicked();
			}
		});
		walkButton.setMargin(new Insets(4, 6, 4, 6));
		GridBagConstraints gbc_walkButton = new GridBagConstraints();
		gbc_walkButton.gridwidth = 3;
		gbc_walkButton.gridx = 0;
		gbc_walkButton.gridy = 1;
		walkPanel.add(walkButton, gbc_walkButton);

		JLayeredPane walkSidewaysTab = new JLayeredPane();
		onlineTabs.addTab(TITLE_WALKSIDEWAYS, null, walkSidewaysTab, null);
		onlineTabs.setEnabledAt(1, true);
		GridBagLayout gbl_walkSidewaysTab = new GridBagLayout();
		gbl_walkSidewaysTab.columnWidths = new int[] { 0 };
		gbl_walkSidewaysTab.rowHeights = new int[] { 0 };
		gbl_walkSidewaysTab.columnWeights = new double[] { 1.0 };
		gbl_walkSidewaysTab.rowWeights = new double[] { 1.0 };
		walkSidewaysTab.setLayout(gbl_walkSidewaysTab);

		TranslucidRectagleComponent walkSidewaysBackground = new TranslucidRectagleComponent();
		walkSidewaysBackground.setTransparence(0.25f);
		walkSidewaysBackground.setColor(SystemColor.control);
		GridBagConstraints gbc_walkSidewaysBackground = new GridBagConstraints();
		gbc_walkSidewaysBackground.fill = GridBagConstraints.BOTH;
		gbc_walkSidewaysBackground.gridx = 0;
		gbc_walkSidewaysBackground.gridy = 0;
		walkSidewaysTab.add(walkSidewaysBackground, gbc_walkSidewaysBackground);

		JPanel walkSidewaysPanel = new JPanel();
		walkSidewaysPanel.setBorder(new EmptyBorder(5, 5, 5, 5));
		walkSidewaysPanel.setOpaque(false);
		walkSidewaysTab.setLayer(walkSidewaysPanel, 1);
		GridBagConstraints gbc_walkSidewaysPanel = new GridBagConstraints();
		gbc_walkSidewaysPanel.fill = GridBagConstraints.BOTH;
		gbc_walkSidewaysPanel.gridx = 0;
		gbc_walkSidewaysPanel.gridy = 0;
		walkSidewaysTab.add(walkSidewaysPanel, gbc_walkSidewaysPanel);
		GridBagLayout gbl_walkSidewaysPanel = new GridBagLayout();
		gbl_walkSidewaysPanel.columnWidths = new int[] { 0, 0, 0 };
		gbl_walkSidewaysPanel.rowHeights = new int[] { 0, 0 };
		gbl_walkSidewaysPanel.columnWeights = new double[] { 0.0, 1.0, 0 };
		gbl_walkSidewaysPanel.rowWeights = new double[] { 0.0, 0.0 };
		walkSidewaysPanel.setLayout(gbl_walkSidewaysPanel);

		JLabel walkSidewaysLabel = new JLabel(LABEL_WALKSIDEWAYS_DISTANCE);
		GridBagConstraints gbc_walkSidewaysLabel = new GridBagConstraints();
		gbc_walkSidewaysLabel.insets = new Insets(0, 0, 5, 5);
		gbc_walkSidewaysLabel.gridx = 0;
		gbc_walkSidewaysLabel.gridy = 0;
		walkSidewaysPanel.add(walkSidewaysLabel, gbc_walkSidewaysLabel);

		walkSidewaysSpinner = new JSpinner();
		walkSidewaysSpinner.setModel(new SpinnerNumberModel(1, 1, 30, 1));
		GridBagConstraints gbc_walkSidewaysSpinner = new GridBagConstraints();
		gbc_walkSidewaysSpinner.fill = GridBagConstraints.HORIZONTAL;
		gbc_walkSidewaysSpinner.insets = new Insets(0, 0, 5, 5);
		gbc_walkSidewaysSpinner.gridx = 1;
		gbc_walkSidewaysSpinner.gridy = 0;
		walkSidewaysPanel.add(walkSidewaysSpinner, gbc_walkSidewaysSpinner);

		JPanel walkSidewaysSubpanel = new JPanel();
		walkSidewaysSubpanel.setOpaque(false);
		GridBagConstraints gbc_walkSidewaysSubpanel = new GridBagConstraints();
		gbc_walkSidewaysSubpanel.insets = new Insets(0, 0, 5, 0);
		gbc_walkSidewaysSubpanel.gridx = 2;
		gbc_walkSidewaysSubpanel.gridy = 0;
		walkSidewaysPanel.add(walkSidewaysSubpanel, gbc_walkSidewaysSubpanel);
		walkSidewaysSubpanel.setLayout(new GridLayout(2, 0, 0, 0));

		walkSidewaysGroup = new ButtonGroup();

		walkSidewaysLeftToRightRadio = new JRadioButton(LABEL_WALKSIDEWAYS_LEFTTORIGHT);
		walkSidewaysLeftToRightRadio.setOpaque(false);
		walkSidewaysLeftToRightRadio.setSelected(true);
		walkSidewaysGroup.add(walkSidewaysLeftToRightRadio);
		walkSidewaysSubpanel.add(walkSidewaysLeftToRightRadio);

		walkSidewaysRightToLeftRadio = new JRadioButton(LABEL_WALKSIDEWAYS_RIGHTTOLEFT);
		walkSidewaysRightToLeftRadio.setOpaque(false);
		walkSidewaysGroup.add(walkSidewaysRightToLeftRadio);
		walkSidewaysSubpanel.add(walkSidewaysRightToLeftRadio);

		walkSidewaysButton = new JButton(ACTION_WALKSIDEWAYS_TRY);
		walkSidewaysButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				HexapodCommandsControl.this.onWalkSidewaysButtonClicked();
			}
		});
		walkSidewaysButton.setMargin(new Insets(4, 6, 4, 6));
		GridBagConstraints gbc_walkSidewaysButton = new GridBagConstraints();
		gbc_walkSidewaysButton.insets = new Insets(0, 0, 0, 5);
		gbc_walkSidewaysButton.gridwidth = 3;
		gbc_walkSidewaysButton.gridx = 0;
		gbc_walkSidewaysButton.gridy = 1;
		walkSidewaysPanel.add(walkSidewaysButton, gbc_walkSidewaysButton);

		JLayeredPane walkToTab = new JLayeredPane();
		onlineTabs.addTab(TITLE_WALKTO, null, walkToTab, null);
		onlineTabs.setEnabledAt(2, true);
		GridBagLayout gbl_walkToTab = new GridBagLayout();
		gbl_walkToTab.columnWidths = new int[] { 0 };
		gbl_walkToTab.rowHeights = new int[] { 0 };
		gbl_walkToTab.columnWeights = new double[] { 1.0 };
		gbl_walkToTab.rowWeights = new double[] { 1.0 };
		walkToTab.setLayout(gbl_walkToTab);

		TranslucidRectagleComponent walkToBackground = new TranslucidRectagleComponent();
		walkToBackground.setTransparence(0.25f);
		walkToBackground.setColor(SystemColor.control);
		GridBagConstraints gbc_walkToBackground = new GridBagConstraints();
		gbc_walkToBackground.fill = GridBagConstraints.BOTH;
		gbc_walkToBackground.gridx = 0;
		gbc_walkToBackground.gridy = 0;
		walkToTab.add(walkToBackground, gbc_walkToBackground);

		JPanel walkToPanel = new JPanel();
		walkToPanel.setBorder(new EmptyBorder(5, 5, 5, 5));
		walkToPanel.setOpaque(false);
		walkToTab.setLayer(walkToPanel, 1);
		GridBagConstraints gbc_walkToPanel = new GridBagConstraints();
		gbc_walkToPanel.fill = GridBagConstraints.BOTH;
		gbc_walkToPanel.gridx = 0;
		gbc_walkToPanel.gridy = 0;
		walkToTab.add(walkToPanel, gbc_walkToPanel);
		GridBagLayout gbl_walkToPanel = new GridBagLayout();
		gbl_walkToPanel.columnWidths = new int[] { 0, 0, 0 };
		gbl_walkToPanel.rowHeights = new int[] { 0, 0, 0 };
		gbl_walkToPanel.columnWeights = new double[] { 0.0, 1.0, 0.0 };
		gbl_walkToPanel.rowWeights = new double[] { 0.0, 0.0, 0.0 };
		walkToPanel.setLayout(gbl_walkToPanel);

		JLabel walkToLabel1 = new JLabel(LABEL_WALKTO_DISTANCE);
		GridBagConstraints gbc_walkToLabel1 = new GridBagConstraints();
		gbc_walkToLabel1.anchor = GridBagConstraints.EAST;
		gbc_walkToLabel1.insets = new Insets(0, 0, 5, 5);
		gbc_walkToLabel1.gridx = 0;
		gbc_walkToLabel1.gridy = 0;
		walkToPanel.add(walkToLabel1, gbc_walkToLabel1);

		walkToSpinner1 = new JSpinner();
		walkToSpinner1.setModel(new SpinnerNumberModel(1, 1, 30, 1));
		GridBagConstraints gbc_walkToSpinner1 = new GridBagConstraints();
		gbc_walkToSpinner1.fill = GridBagConstraints.HORIZONTAL;
		gbc_walkToSpinner1.insets = new Insets(0, 0, 5, 5);
		gbc_walkToSpinner1.gridx = 1;
		gbc_walkToSpinner1.gridy = 0;
		walkToPanel.add(walkToSpinner1, gbc_walkToSpinner1);

		walkToCheckbox = new JCheckBox(LABEL_WALKTO_BACKWARDS);
		GridBagConstraints gbc_walkToCheckbox = new GridBagConstraints();
		gbc_walkToCheckbox.insets = new Insets(0, 0, 5, 0);
		gbc_walkToCheckbox.gridx = 2;
		gbc_walkToCheckbox.gridy = 0;
		walkToPanel.add(walkToCheckbox, gbc_walkToCheckbox);

		JLabel walkToLabel2 = new JLabel(LABEL_WALKTO_ANGLE);
		GridBagConstraints gbc_walkToLabel2 = new GridBagConstraints();
		gbc_walkToLabel2.anchor = GridBagConstraints.EAST;
		gbc_walkToLabel2.insets = new Insets(0, 0, 5, 5);
		gbc_walkToLabel2.gridx = 0;
		gbc_walkToLabel2.gridy = 1;
		walkToPanel.add(walkToLabel2, gbc_walkToLabel2);

		walkToSpinner2 = new JSpinner();
		walkToSpinner2.setModel(new SpinnerNumberModel(0, -180, 180, 10));
		GridBagConstraints gbc_walkToSpinner2 = new GridBagConstraints();
		gbc_walkToSpinner2.fill = GridBagConstraints.HORIZONTAL;
		gbc_walkToSpinner2.insets = new Insets(0, 0, 5, 0);
		gbc_walkToSpinner2.gridwidth = 2;
		gbc_walkToSpinner2.gridx = 1;
		gbc_walkToSpinner2.gridy = 1;
		walkToPanel.add(walkToSpinner2, gbc_walkToSpinner2);

		walkToButton = new JButton(ACTION_WALKTO_TRY);
		walkToButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				HexapodCommandsControl.this.onWalkToButtonClicked();
			}
		});
		walkToButton.setMargin(new Insets(4, 6, 4, 6));
		GridBagConstraints gbc_walkToButton = new GridBagConstraints();
		gbc_walkToButton.gridwidth = 3;
		gbc_walkToButton.gridx = 0;
		gbc_walkToButton.gridy = 2;
		walkToPanel.add(walkToButton, gbc_walkToButton);

		JLayeredPane rotateTab = new JLayeredPane();
		onlineTabs.addTab(TITLE_ROTATE, null, rotateTab, null);
		onlineTabs.setEnabledAt(3, true);
		GridBagLayout gbl_rotateTab = new GridBagLayout();
		gbl_rotateTab.columnWidths = new int[] { 0 };
		gbl_rotateTab.rowHeights = new int[] { 0 };
		gbl_rotateTab.columnWeights = new double[] { 1.0 };
		gbl_rotateTab.rowWeights = new double[] { 1.0 };
		rotateTab.setLayout(gbl_rotateTab);

		TranslucidRectagleComponent rotateBackground = new TranslucidRectagleComponent();
		rotateBackground.setTransparence(0.25f);
		rotateBackground.setColor(SystemColor.control);
		GridBagConstraints gbc_rotateBackground = new GridBagConstraints();
		gbc_rotateBackground.fill = GridBagConstraints.BOTH;
		gbc_rotateBackground.gridx = 0;
		gbc_rotateBackground.gridy = 0;
		rotateTab.add(rotateBackground, gbc_rotateBackground);

		JPanel rotatePanel = new JPanel();
		rotatePanel.setBorder(new EmptyBorder(5, 5, 5, 5));
		rotatePanel.setOpaque(false);
		rotateTab.setLayer(rotatePanel, 1);
		GridBagConstraints gbc_rotatePanel = new GridBagConstraints();
		gbc_rotatePanel.fill = GridBagConstraints.BOTH;
		gbc_rotatePanel.gridx = 0;
		gbc_rotatePanel.gridy = 0;
		rotateTab.add(rotatePanel, gbc_rotatePanel);
		GridBagLayout gbl_rotatePanel = new GridBagLayout();
		gbl_rotatePanel.columnWidths = new int[] { 0, 0, 0 };
		gbl_rotatePanel.rowHeights = new int[] { 0, 0 };
		gbl_rotatePanel.columnWeights = new double[] { 0.0, 1.0, 0 };
		gbl_rotatePanel.rowWeights = new double[] { 0.0, 0.0 };
		rotatePanel.setLayout(gbl_rotatePanel);

		JLabel rotateLabel = new JLabel(LABEL_ROTATE_ANGLE);
		GridBagConstraints gbc_rotateLabel = new GridBagConstraints();
		gbc_rotateLabel.insets = new Insets(0, 0, 5, 5);
		gbc_rotateLabel.gridx = 0;
		gbc_rotateLabel.gridy = 0;
		rotatePanel.add(rotateLabel, gbc_rotateLabel);

		rotateSpinner = new JSpinner();
		rotateSpinner.setModel(new SpinnerNumberModel(1, 1, 180, 10));
		GridBagConstraints gbc_rotateSpinner = new GridBagConstraints();
		gbc_rotateSpinner.fill = GridBagConstraints.HORIZONTAL;
		gbc_rotateSpinner.insets = new Insets(0, 0, 5, 5);
		gbc_rotateSpinner.gridx = 1;
		gbc_rotateSpinner.gridy = 0;
		rotatePanel.add(rotateSpinner, gbc_rotateSpinner);

		JPanel rotateSubpanel = new JPanel();
		rotateSubpanel.setOpaque(false);
		GridBagConstraints gbc_rotateSubpanel = new GridBagConstraints();
		gbc_rotateSubpanel.insets = new Insets(0, 0, 5, 0);
		gbc_rotateSubpanel.gridx = 2;
		gbc_rotateSubpanel.gridy = 0;
		rotatePanel.add(rotateSubpanel, gbc_rotateSubpanel);
		rotateSubpanel.setLayout(new GridLayout(2, 0, 0, 0));

		rotateGroup = new ButtonGroup();

		rotateClockwiseRadio = new JRadioButton(LABEL_ROTATE_CLOCKWISE);
		rotateClockwiseRadio.setOpaque(false);
		rotateClockwiseRadio.setSelected(true);
		rotateGroup.add(rotateClockwiseRadio);
		rotateSubpanel.add(rotateClockwiseRadio);

		rotateCounterclockwiseRadio = new JRadioButton(LABEL_ROTATE_COUNTERCLOCKWISE);
		rotateCounterclockwiseRadio.setOpaque(false);
		rotateGroup.add(rotateCounterclockwiseRadio);
		rotateSubpanel.add(rotateCounterclockwiseRadio);

		rotateButton = new JButton(ACTION_ROTATE_TRY);
		rotateButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				HexapodCommandsControl.this.onRotateButtonClicked();
			}
		});
		rotateButton.setMargin(new Insets(4, 6, 4, 6));
		GridBagConstraints gbc_rotateButton = new GridBagConstraints();
		gbc_rotateButton.insets = new Insets(0, 0, 0, 5);
		gbc_rotateButton.gridwidth = 3;
		gbc_rotateButton.gridx = 0;
		gbc_rotateButton.gridy = 1;
		rotatePanel.add(rotateButton, gbc_rotateButton);

		JLayeredPane lookToTab = new JLayeredPane();
		onlineTabs.addTab(TITLE_LOOKTO, null, lookToTab, null);
		onlineTabs.setEnabledAt(4, true);
		GridBagLayout gbl_lookToTab = new GridBagLayout();
		gbl_lookToTab.columnWidths = new int[] { 0 };
		gbl_lookToTab.rowHeights = new int[] { 0 };
		gbl_lookToTab.columnWeights = new double[] { 1.0 };
		gbl_lookToTab.rowWeights = new double[] { 1.0 };
		lookToTab.setLayout(gbl_lookToTab);

		TranslucidRectagleComponent lookToBackground = new TranslucidRectagleComponent();
		lookToBackground.setTransparence(0.25f);
		lookToBackground.setColor(SystemColor.control);
		GridBagConstraints gbc_lookToBackground = new GridBagConstraints();
		gbc_lookToBackground.fill = GridBagConstraints.BOTH;
		gbc_lookToBackground.gridx = 0;
		gbc_lookToBackground.gridy = 0;
		lookToTab.add(lookToBackground, gbc_lookToBackground);

		JPanel lookToPanel = new JPanel();
		lookToPanel.setBorder(new EmptyBorder(5, 5, 5, 5));
		lookToPanel.setOpaque(false);
		lookToTab.setLayer(lookToPanel, 1);
		GridBagConstraints gbc_lookToPanel = new GridBagConstraints();
		gbc_lookToPanel.fill = GridBagConstraints.BOTH;
		gbc_lookToPanel.gridx = 0;
		gbc_lookToPanel.gridy = 0;
		lookToTab.add(lookToPanel, gbc_lookToPanel);
		GridBagLayout gbl_lookToPanel = new GridBagLayout();
		gbl_lookToPanel.columnWidths = new int[] { 0, 0 };
		gbl_lookToPanel.rowHeights = new int[] { 0, 0 };
		gbl_lookToPanel.columnWeights = new double[] { 0.0, 1.0 };
		gbl_lookToPanel.rowWeights = new double[] { 0.0, 0.0 };
		lookToPanel.setLayout(gbl_lookToPanel);

		JLabel lookToLabel = new JLabel(LABEL_LOOKTO_ANGLE);
		GridBagConstraints gbc_lookToLabel = new GridBagConstraints();
		gbc_lookToLabel.insets = new Insets(0, 0, 5, 5);
		gbc_lookToLabel.gridx = 0;
		gbc_lookToLabel.gridy = 0;
		lookToPanel.add(lookToLabel, gbc_lookToLabel);

		lookToSpinner = new JSpinner();
		lookToSpinner.setModel(new SpinnerNumberModel(0, -180, 180, 10));
		GridBagConstraints gbc_lookToSpinner = new GridBagConstraints();
		gbc_lookToSpinner.fill = GridBagConstraints.HORIZONTAL;
		gbc_lookToSpinner.insets = new Insets(0, 0, 5, 0);
		gbc_lookToSpinner.gridx = 1;
		gbc_lookToSpinner.gridy = 0;
		lookToPanel.add(lookToSpinner, gbc_lookToSpinner);

		lookToButton = new JButton(ACTION_LOOKTO_TRY);
		lookToButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				HexapodCommandsControl.this.onLookToButtonClicked();
			}
		});
		lookToButton.setMargin(new Insets(4, 6, 4, 6));
		GridBagConstraints gbc_lookToButton = new GridBagConstraints();
		gbc_lookToButton.gridwidth = 2;
		gbc_lookToButton.gridx = 0;
		gbc_lookToButton.gridy = 1;
		lookToPanel.add(lookToButton, gbc_lookToButton);

		JLayeredPane pushUpTab = new JLayeredPane();
		onlineTabs.addTab(TITLE_PUSHUP, null, pushUpTab, null);
		onlineTabs.setEnabledAt(5, true);
		GridBagLayout gbl_pushUpTab = new GridBagLayout();
		gbl_pushUpTab.columnWidths = new int[] { 0 };
		gbl_pushUpTab.rowHeights = new int[] { 0 };
		gbl_pushUpTab.columnWeights = new double[] { 1.0 };
		gbl_pushUpTab.rowWeights = new double[] { 1.0 };
		pushUpTab.setLayout(gbl_pushUpTab);

		TranslucidRectagleComponent pushUpBackground = new TranslucidRectagleComponent();
		pushUpBackground.setTransparence(0.25f);
		pushUpBackground.setColor(SystemColor.control);
		GridBagConstraints gbc_pushUpBackground = new GridBagConstraints();
		gbc_pushUpBackground.fill = GridBagConstraints.BOTH;
		gbc_pushUpBackground.gridx = 0;
		gbc_pushUpBackground.gridy = 0;
		pushUpTab.add(pushUpBackground, gbc_pushUpBackground);

		JPanel pushUpPanel = new JPanel();
		pushUpPanel.setBorder(new EmptyBorder(5, 5, 5, 5));
		pushUpPanel.setOpaque(false);
		pushUpTab.setLayer(pushUpPanel, 1);
		GridBagConstraints gbc_pushUpPanel = new GridBagConstraints();
		gbc_pushUpPanel.fill = GridBagConstraints.BOTH;
		gbc_pushUpPanel.gridx = 0;
		gbc_pushUpPanel.gridy = 0;
		pushUpTab.add(pushUpPanel, gbc_pushUpPanel);
		GridBagLayout gbl_pushUpPanel = new GridBagLayout();
		gbl_pushUpPanel.columnWidths = new int[] { 0, 0 };
		gbl_pushUpPanel.rowHeights = new int[] { 0, 0 };
		gbl_pushUpPanel.columnWeights = new double[] { 0.0, 1.0 };
		gbl_pushUpPanel.rowWeights = new double[] { 0.0, 0.0 };
		pushUpPanel.setLayout(gbl_pushUpPanel);

		JLabel pushUpLabel = new JLabel(LABEL_PUSHUP_COUNT);
		GridBagConstraints gbc_pushUpLabel = new GridBagConstraints();
		gbc_pushUpLabel.insets = new Insets(0, 0, 5, 5);
		gbc_pushUpLabel.gridx = 0;
		gbc_pushUpLabel.gridy = 0;
		pushUpPanel.add(pushUpLabel, gbc_pushUpLabel);

		pushUpSpinner = new JSpinner();
		pushUpSpinner.setModel(new SpinnerNumberModel(1, 1, 20, 1));
		GridBagConstraints gbc_pushUpSpinner = new GridBagConstraints();
		gbc_pushUpSpinner.fill = GridBagConstraints.HORIZONTAL;
		gbc_pushUpSpinner.insets = new Insets(0, 0, 5, 0);
		gbc_pushUpSpinner.gridx = 1;
		gbc_pushUpSpinner.gridy = 0;
		pushUpPanel.add(pushUpSpinner, gbc_pushUpSpinner);

		pushUpButton = new JButton(ACTION_PUSHUP_TRY);
		pushUpButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				HexapodCommandsControl.this.onPushUpButtonClicked();
			}
		});
		pushUpButton.setMargin(new Insets(4, 6, 4, 6));
		GridBagConstraints gbc_pushUpButton = new GridBagConstraints();
		gbc_pushUpButton.gridwidth = 2;
		gbc_pushUpButton.gridx = 0;
		gbc_pushUpButton.gridy = 1;
		pushUpPanel.add(pushUpButton, gbc_pushUpButton);

		JLayeredPane hulaHoopTab = new JLayeredPane();
		onlineTabs.addTab(TITLE_HULAHOOP, null, hulaHoopTab, null);
		onlineTabs.setEnabledAt(6, true);
		GridBagLayout gbl_hulaHoopTab = new GridBagLayout();
		gbl_hulaHoopTab.columnWidths = new int[] { 0 };
		gbl_hulaHoopTab.rowHeights = new int[] { 0 };
		gbl_hulaHoopTab.columnWeights = new double[] { 1.0 };
		gbl_hulaHoopTab.rowWeights = new double[] { 1.0 };
		hulaHoopTab.setLayout(gbl_hulaHoopTab);

		TranslucidRectagleComponent hulaHoopBackground = new TranslucidRectagleComponent();
		hulaHoopBackground.setTransparence(0.25f);
		hulaHoopBackground.setColor(SystemColor.control);
		GridBagConstraints gbc_hulaHoopBackground = new GridBagConstraints();
		gbc_hulaHoopBackground.fill = GridBagConstraints.BOTH;
		gbc_hulaHoopBackground.gridx = 0;
		gbc_hulaHoopBackground.gridy = 0;
		hulaHoopTab.add(hulaHoopBackground, gbc_hulaHoopBackground);

		JPanel hulaHoopPanel = new JPanel();
		hulaHoopPanel.setBorder(new EmptyBorder(5, 5, 5, 5));
		hulaHoopPanel.setOpaque(false);
		hulaHoopTab.setLayer(hulaHoopPanel, 1);
		GridBagConstraints gbc_hulaHoopPanel = new GridBagConstraints();
		gbc_hulaHoopPanel.fill = GridBagConstraints.BOTH;
		gbc_hulaHoopPanel.gridx = 0;
		gbc_hulaHoopPanel.gridy = 0;
		hulaHoopTab.add(hulaHoopPanel, gbc_hulaHoopPanel);
		GridBagLayout gbl_hulaHoopPanel = new GridBagLayout();
		gbl_hulaHoopPanel.columnWidths = new int[] { 0, 0 };
		gbl_hulaHoopPanel.rowHeights = new int[] { 0, 0 };
		gbl_hulaHoopPanel.columnWeights = new double[] { 0.0, 1.0 };
		gbl_hulaHoopPanel.rowWeights = new double[] { 0.0, 0.0 };
		hulaHoopPanel.setLayout(gbl_hulaHoopPanel);

		JLabel hulaHoopLabel = new JLabel(LABEL_HULAHOOP_COUNT);
		GridBagConstraints gbc_hulaHoopLabel = new GridBagConstraints();
		gbc_hulaHoopLabel.insets = new Insets(0, 0, 5, 5);
		gbc_hulaHoopLabel.gridx = 0;
		gbc_hulaHoopLabel.gridy = 0;
		hulaHoopPanel.add(hulaHoopLabel, gbc_hulaHoopLabel);

		hulaHoopSpinner = new JSpinner();
		hulaHoopSpinner.setModel(new SpinnerNumberModel(1, 1, 30, 1));
		GridBagConstraints gbc_hulaHoopSpinner = new GridBagConstraints();
		gbc_hulaHoopSpinner.fill = GridBagConstraints.HORIZONTAL;
		gbc_hulaHoopSpinner.insets = new Insets(0, 0, 5, 0);
		gbc_hulaHoopSpinner.gridx = 1;
		gbc_hulaHoopSpinner.gridy = 0;
		hulaHoopPanel.add(hulaHoopSpinner, gbc_hulaHoopSpinner);

		hulaHoopButton = new JButton(ACTION_HULAHOOP_TRY);
		hulaHoopButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				HexapodCommandsControl.this.onHulaHoopButtonClicked();
			}
		});
		hulaHoopButton.setMargin(new Insets(4, 6, 4, 6));
		GridBagConstraints gbc_hulaHoopButton = new GridBagConstraints();
		gbc_hulaHoopButton.gridwidth = 2;
		gbc_hulaHoopButton.gridx = 0;
		gbc_hulaHoopButton.gridy = 1;
		hulaHoopPanel.add(hulaHoopButton, gbc_hulaHoopButton);


		JLayeredPane punchTab = new JLayeredPane();
		onlineTabs.addTab(TITLE_PUNCH, null, punchTab, null);
		onlineTabs.setEnabledAt(7, true);
		GridBagLayout gbl_punchTab = new GridBagLayout();
		gbl_punchTab.columnWidths = new int[] { 0 };
		gbl_punchTab.rowHeights = new int[] { 0 };
		gbl_punchTab.columnWeights = new double[] { 1.0 };
		gbl_punchTab.rowWeights = new double[] { 1.0 };
		punchTab.setLayout(gbl_punchTab);

		TranslucidRectagleComponent punchBackground = new TranslucidRectagleComponent();
		punchBackground.setTransparence(0.25f);
		punchBackground.setColor(SystemColor.control);
		GridBagConstraints gbc_punchBackground = new GridBagConstraints();
		gbc_punchBackground.fill = GridBagConstraints.BOTH;
		gbc_punchBackground.gridx = 0;
		gbc_punchBackground.gridy = 0;
		punchTab.add(punchBackground, gbc_punchBackground);

		JPanel punchPanel = new JPanel();
		punchPanel.setBorder(new EmptyBorder(5, 5, 5, 5));
		punchPanel.setOpaque(false);
		punchTab.setLayer(punchPanel, 1);
		GridBagConstraints gbc_punchPanel = new GridBagConstraints();
		gbc_punchPanel.fill = GridBagConstraints.BOTH;
		gbc_punchPanel.gridx = 0;
		gbc_punchPanel.gridy = 0;
		punchTab.add(punchPanel, gbc_punchPanel);
		GridBagLayout gbl_punchPanel = new GridBagLayout();
		gbl_punchPanel.columnWidths = new int[] { 0, 0 };
		gbl_punchPanel.rowHeights = new int[] { 0, 0 };
		gbl_punchPanel.columnWeights = new double[] { 0.0, 1.0 };
		gbl_punchPanel.rowWeights = new double[] { 0.0, 0.0 };
		punchPanel.setLayout(gbl_punchPanel);

		JLabel punchLabel = new JLabel(LABEL_PUNCH_COUNT);
		GridBagConstraints gbc_punchLabel = new GridBagConstraints();
		gbc_punchLabel.insets = new Insets(0, 0, 5, 5);
		gbc_punchLabel.gridx = 0;
		gbc_punchLabel.gridy = 0;
		punchPanel.add(punchLabel, gbc_punchLabel);

		punchSpinner = new JSpinner();
		punchSpinner.setModel(new SpinnerNumberModel(1, 1, 30, 1));
		GridBagConstraints gbc_punchSpinner = new GridBagConstraints();
		gbc_punchSpinner.fill = GridBagConstraints.HORIZONTAL;
		gbc_punchSpinner.insets = new Insets(0, 0, 5, 0);
		gbc_punchSpinner.gridx = 1;
		gbc_punchSpinner.gridy = 0;
		punchPanel.add(punchSpinner, gbc_punchSpinner);

		punchButton = new JButton(ACTION_PUNCH_TRY);
		punchButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				HexapodCommandsControl.this.onPunchButtonClicked();
			}
		});
		punchButton.setMargin(new Insets(4, 6, 4, 6));
		GridBagConstraints gbc_punchButton = new GridBagConstraints();
		gbc_punchButton.gridwidth = 2;
		gbc_punchButton.gridx = 0;
		gbc_punchButton.gridy = 1;
		punchPanel.add(punchButton, gbc_punchButton);

		JLayeredPane adjustTab = new JLayeredPane();
		onlineTabs.addTab(TITLE_ADJUST, null, adjustTab, null);
		onlineTabs.setEnabledAt(8, true);
		GridBagLayout gbl_adjustTab = new GridBagLayout();
		gbl_adjustTab.columnWidths = new int[] { 0 };
		gbl_adjustTab.rowHeights = new int[] { 0 };
		gbl_adjustTab.columnWeights = new double[] { 1.0 };
		gbl_adjustTab.rowWeights = new double[] { 1.0 };
		adjustTab.setLayout(gbl_adjustTab);

		TranslucidRectagleComponent adjustBackground = new TranslucidRectagleComponent();
		adjustBackground.setTransparence(0.25f);
		adjustBackground.setColor(SystemColor.control);
		GridBagConstraints gbc_adjustBackground = new GridBagConstraints();
		gbc_adjustBackground.fill = GridBagConstraints.BOTH;
		gbc_adjustBackground.gridx = 0;
		gbc_adjustBackground.gridy = 0;
		adjustTab.add(adjustBackground, gbc_adjustBackground);

		JPanel adjustPanel = new JPanel();
		adjustPanel.setBorder(new EmptyBorder(5, 5, 5, 5));
		adjustPanel.setOpaque(false);
		adjustTab.setLayer(adjustPanel, 1);
		GridBagConstraints gbc_adjustPanel = new GridBagConstraints();
		gbc_adjustPanel.fill = GridBagConstraints.BOTH;
		gbc_adjustPanel.gridx = 0;
		gbc_adjustPanel.gridy = 0;
		adjustTab.add(adjustPanel, gbc_adjustPanel);
		GridBagLayout gbl_adjustPanel = new GridBagLayout();
		gbl_adjustPanel.columnWidths = new int[] { 0 };
		gbl_adjustPanel.rowHeights = new int[] { 0 };
		gbl_adjustPanel.columnWeights = new double[] { 0.0 };
		gbl_adjustPanel.rowWeights = new double[] { 0.0 };
		adjustPanel.setLayout(gbl_adjustPanel);
		
		adjustButton = new JButton(ACTION_ADJUST_TRY);
		adjustButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				HexapodCommandsControl.this.onAdjustButtonClicked();
			}
		});
		adjustButton.setMargin(new Insets(4, 6, 4, 6));
		GridBagConstraints gbc_adjustButton = new GridBagConstraints();
		gbc_adjustButton.gridwidth = 2;
		gbc_adjustButton.gridx = 0;
		gbc_adjustButton.gridy = 0;
		adjustPanel.add(adjustButton, gbc_adjustButton);

		overPanel = new JLayeredPane();
		overPanel.setVisible(false);
		overPanel.setOpaque(false);
		mainPanel.setLayer(overPanel, 2);
		GridBagConstraints gbc_overPanel = new GridBagConstraints();
		gbc_overPanel.fill = GridBagConstraints.BOTH;
		gbc_overPanel.gridx = 0;
		gbc_overPanel.gridy = 0;
		mainPanel.add(overPanel, gbc_overPanel);
		GridBagLayout gbl_overPanel = new GridBagLayout();
		gbl_overPanel.columnWidths = new int[] { 0 };
		gbl_overPanel.rowHeights = new int[] { 0 };
		gbl_overPanel.columnWeights = new double[] { 1.0 };
		gbl_overPanel.rowWeights = new double[] { 1.0 };
		overPanel.setLayout(gbl_overPanel);

		TranslucidRectagleComponent overBackground = new TranslucidRectagleComponent();
		overBackground.setTransparence(0.75f);
		overBackground.setColor(Color.BLACK);
		overPanel.setLayer(overBackground, 0);
		GridBagConstraints gbc_overBackground = new GridBagConstraints();
		gbc_overBackground.fill = GridBagConstraints.BOTH;
		gbc_overBackground.gridx = 0;
		gbc_overBackground.gridy = 0;
		overPanel.add(overBackground, gbc_overBackground);

		overCardbox = new JPanel();
		overCardbox.setOpaque(false);
		overPanel.setLayer(overCardbox, 1);
		GridBagConstraints gbc_overCardbox = new GridBagConstraints();
		gbc_overCardbox.fill = GridBagConstraints.BOTH;
		gbc_overCardbox.gridx = 0;
		gbc_overCardbox.gridy = 0;
		overPanel.add(overCardbox, gbc_overCardbox);
		overCardbox.setLayout(overLayout = new CardLayout(0, 0));

		JPanel loadingCard = new JPanel();
		loadingCard.setOpaque(false);
		overCardbox.add(loadingCard, CARD_OVER_LOADING);
		GridBagLayout gbl_loadingCard = new GridBagLayout();
		gbl_loadingCard.columnWidths = new int[] { 0 };
		gbl_loadingCard.rowHeights = new int[] { 0 };
		gbl_loadingCard.columnWeights = new double[] { 1.0 };
		gbl_loadingCard.rowWeights = new double[] { 1.0 };
		loadingCard.setLayout(gbl_loadingCard);

		loadingPanel = new JPanel();
		loadingPanel.setBackground(UIManager.getColor("TextField.background"));
		loadingPanel.setBorder(new CompoundBorder(new LineBorder(new Color(0, 0, 0), 2), new EmptyBorder(5, 5, 5, 5)));
		GridBagConstraints gbc_loadingPanel = new GridBagConstraints();
		gbc_loadingPanel.gridx = 0;
		gbc_loadingPanel.gridy = 0;
		loadingCard.add(loadingPanel, gbc_loadingPanel);

		GridBagLayout gbl_loadingPanel = new GridBagLayout();
		gbl_loadingPanel.columnWidths = new int[] { 0 };
		gbl_loadingPanel.rowHeights = new int[] { 0 };
		gbl_loadingPanel.columnWeights = new double[] { 1.0 };
		gbl_loadingPanel.rowWeights = new double[] { 1.0 };
		loadingPanel.setLayout(gbl_loadingPanel);

		loadingLabel = new JLabel(LABEL_LOADING);
		GridBagConstraints gbc_loadingLabel = new GridBagConstraints();
		gbc_loadingLabel.gridx = 0;
		gbc_loadingLabel.gridy = 0;
		loadingPanel.add(loadingLabel, gbc_loadingLabel);

		JPanel messageCard = new JPanel();
		messageCard.setOpaque(false);
		overCardbox.add(messageCard, CARD_OVER_MESSAGE);
		GridBagLayout gbl_messageCard = new GridBagLayout();
		gbl_messageCard.columnWidths = new int[] { 0, 0 };
		gbl_messageCard.rowHeights = new int[] { 0, 0 };
		gbl_messageCard.columnWeights = new double[] { 1.0, Double.MIN_VALUE };
		gbl_messageCard.rowWeights = new double[] { 1.0, Double.MIN_VALUE };
		messageCard.setLayout(gbl_messageCard);

		messagePanel = new JPanel();
		messagePanel.setBackground(UIManager.getColor("TextField.background"));
		messagePanel.setBorder(new CompoundBorder(new LineBorder(new Color(0, 0, 0), 2), new EmptyBorder(5, 5, 5, 5)));
		GridBagConstraints gbc_messagePanel = new GridBagConstraints();
		gbc_messagePanel.gridx = 0;
		gbc_messagePanel.gridy = 0;
		messageCard.add(messagePanel, gbc_messagePanel);
		GridBagLayout gbl_messagePanel = new GridBagLayout();
		gbl_messagePanel.columnWidths = new int[] { 0, 0 };
		gbl_messagePanel.rowHeights = new int[] { 0, 0, 0 };
		gbl_messagePanel.columnWeights = new double[] { 0.0, Double.MIN_VALUE };
		gbl_messagePanel.rowWeights = new double[] { 0.0, 0.0, Double.MIN_VALUE };
		messagePanel.setLayout(gbl_messagePanel);

		messageLabel = new JLabel("");
		GridBagConstraints gbc_messageLabel = new GridBagConstraints();
		gbc_messageLabel.insets = new Insets(0, 0, 5, 0);
		gbc_messageLabel.gridx = 0;
		gbc_messageLabel.gridy = 0;
		messagePanel.add(messageLabel, gbc_messageLabel);

		messageButton = new JButton("");
		messageButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				HexapodCommandsControl.this.onMessageButtonClicked();
			}
		});
		messageButton.setSelected(true);
		messageButton.setMargin(new Insets(4, 6, 4, 6));
		GridBagConstraints gbc_messageButton = new GridBagConstraints();
		gbc_messageButton.gridx = 0;
		gbc_messageButton.gridy = 1;
		messagePanel.add(messageButton, gbc_messageButton);
	}

	private void gotoState(State state) {
		System.out.println(state);

		hostText.setEnabled(state == State.NotConnected);
		portSpinner.setEnabled(state == State.NotConnected && !portCheckbox.isSelected());
		portCheckbox.setEnabled(state == State.NotConnected);
		connectButton.setEnabled(state == State.NotConnected);

		openCombo.setEnabled(state == State.Connected);
		enumeratePortsButton.setEnabled(state == State.Connected);
		openButton.setEnabled(state == State.Connected);

		walkSpinner.setEnabled(state == State.Opened);
		walkCheckbox.setEnabled(state == State.Opened);
		walkButton.setEnabled(state == State.Opened);

		walkSidewaysSpinner.setEnabled(state == State.Opened);
		walkSidewaysLeftToRightRadio.setEnabled(state == State.Opened);
		walkSidewaysRightToLeftRadio.setEnabled(state == State.Opened);
		walkSidewaysButton.setEnabled(state == State.Opened);

		walkToSpinner1.setEnabled(state == State.Opened);
		walkToSpinner2.setEnabled(state == State.Opened);
		walkToCheckbox.setEnabled(state == State.Opened);
		walkToButton.setEnabled(state == State.Opened);

		rotateSpinner.setEnabled(state == State.Opened);
		rotateClockwiseRadio.setEnabled(state == State.Opened);
		rotateCounterclockwiseRadio.setEnabled(state == State.Opened);
		rotateButton.setEnabled(state == State.Opened);

		lookToSpinner.setEnabled(state == State.Opened);
		lookToButton.setEnabled(state == State.Opened);

		pushUpSpinner.setEnabled(state == State.Opened);
		pushUpButton.setEnabled(state == State.Opened);

		hulaHoopSpinner.setEnabled(state == State.Opened);
		hulaHoopButton.setEnabled(state == State.Opened);

		adjustButton.setEnabled(state == State.Opened);

		switch (state) {
			case NotConnected:
				overPanel.setVisible(false);
				bottomLayout.show(bottomCardbox, CARD_CONNECT);
				break;
			case OngoingConnection:
				overLayout.show(overCardbox, CARD_OVER_LOADING);
				loadingLabel.setText(LABEL_CONNECTING_ONGOING);
				loadingPanel.validate();
				bottomLayout.show(bottomCardbox, CARD_CONNECT);
				overPanel.setVisible(true);
				break;
			case FailedConnection:
				messageLabel.setText(LABEL_CONNECTING_FAILED);
				messageButton.setText(ACTION_MESSAGE_CLOSE);
				messagePanel.validate();
				overLayout.show(overCardbox, CARD_OVER_MESSAGE);
				bottomLayout.show(bottomCardbox, CARD_CONNECT);
				overPanel.setVisible(true);
				break;
			case Connected:
				overPanel.setVisible(false);
				bottomLayout.show(bottomCardbox, CARD_OPEN);
				break;
			case OngoingEnumeration:
				overLayout.show(overCardbox, CARD_OVER_LOADING);
				loadingLabel.setText(LABEL_LOADING);
				loadingPanel.validate();
				bottomLayout.show(bottomCardbox, CARD_OPEN);
				overPanel.setVisible(true);
				break;
			case FailedEnumeration:
				messageLabel.setText(LABEL_DIDNOTENUMERATEPORTS_MESSAGE);
				messageButton.setText(ACTION_MESSAGE_CLOSE);
				messagePanel.validate();
				overLayout.show(overCardbox, CARD_OVER_MESSAGE);
				bottomLayout.show(bottomCardbox, CARD_OPEN);
				overPanel.setVisible(true);
				break;
			case OngoingOpening:
				overLayout.show(overCardbox, CARD_OVER_LOADING);
				loadingLabel.setText(LABEL_LOADING);
				loadingPanel.validate();
				bottomLayout.show(bottomCardbox, CARD_OPEN);
				overPanel.setVisible(true);
				break;
			case FailedOpening:
				messageLabel.setText(LABEL_DIDNOTOPEN_MESSAGE);
				messageButton.setText(ACTION_MESSAGE_CLOSE);
				messagePanel.validate();
				overLayout.show(overCardbox, CARD_OVER_MESSAGE);
				bottomLayout.show(bottomCardbox, CARD_OPEN);
				overPanel.setVisible(true);
				break;
			case Opened:
				overPanel.setVisible(false);
				bottomLayout.show(bottomCardbox, CARD_ONLINE);
				break;
			case OngoingStartingMovement:
				overLayout.show(overCardbox, CARD_OVER_LOADING);
				loadingLabel.setText(LABEL_LOADING);
				loadingPanel.validate();
				bottomLayout.show(bottomCardbox, CARD_ONLINE);
				overPanel.setVisible(true);
				break;
			case FailedStartingMovement:
				messageLabel.setText(LABEL_DIDNOTMOVE_MESSAGE);
				messageButton.setText(ACTION_MESSAGE_CLOSE);
				messagePanel.validate();
				overLayout.show(overCardbox, CARD_OVER_MESSAGE);
				bottomLayout.show(bottomCardbox, CARD_ONLINE);
				overPanel.setVisible(true);
				break;
			case MovementStarted:
				messageLabel.setText(LABEL_ISMOVING_MESSAGE);
				messageButton.setText(ACTION_MESSAGE_ABORT);
				messagePanel.validate();
				overLayout.show(overCardbox, CARD_OVER_MESSAGE);
				bottomLayout.show(bottomCardbox, CARD_ONLINE);
				overPanel.setVisible(true);
				break;
			default:
				return;
		}
		m_state = state;
	}

	protected void onMessageButtonClicked() {
		switch (m_state) {
			case FailedConnection:
				this.gotoState(State.NotConnected);
				break;
			case FailedEnumeration:
				this.gotoState(State.Connected);
				break;
			case FailedOpening:
				this.gotoState(State.Connected);
				break;
			case MovementStarted:
				this.abort();
				break;
			case FailedStartingMovement:
				this.gotoState(State.Opened);
				break;
			default:
		}
	}

	protected void onConnectToPortButtonClicked() {
		int selected = openCombo.getSelectedIndex();
		if (selected >= 0) {
			this.gotoState(State.OngoingOpening);
			m_connection.open(m_ports[selected], new OpenedCallback() {
				@Override
				public void onOpened(String port, OpenedCallback.Result result) {
					if (result == OpenedCallback.Result.Success) {
						HexapodCommandsControl.this.gotoState(State.Opened);
					} else {
						HexapodCommandsControl.this.gotoState(State.FailedOpening);
					}
				}
			});
		}
	}

	protected void onRefreshPortsButtonClicked() {
		this.enumeratePorts();
	}

	private void abort() {
		if (m_state == State.MovementStarted) {
			m_connection.halt(new RobotHaltedCallback() {
				@Override
				public void onRobotHalted(Result result) {
					if (result == RobotHaltedCallback.Result.Success) {
						HexapodCommandsControl.this.gotoState(State.Opened);
					}
				}
			});
		}
	}

	protected void onMagnetometerButtonClicked() {
		if (m_state == State.Opened) {
			m_connection.readMagnetometer(new MagnetometerReadCallback() {
				@Override
				public void onMagnetometerRead(MagnetometerData data, Result result) {
					if (result == Result.Success) {
						HexapodCommandsControl.this.refreshMagnetometer(data);
					}
				}
			});
		}
	}

	protected void onAccelerometerButtonClicked() {
		if (m_state == State.Opened) {
			m_connection.readAccelerometer(new AccelerometerReadCallback() {
				@Override
				public void onAccelerometerRead(AccelerometerData data, Result result) {
					if (result == Result.Success) {
						HexapodCommandsControl.this.refreshAccelerometer(data);
					}
				}
			});
		}
	}

	protected void onWalkButtonClicked() {
		Integer distance = null;
		try {
			distance = Integer.parseInt(walkSpinner.getValue().toString());
		} catch (Exception e) {}
		if (null == distance) {
			return;
		}
		if (m_state == State.Opened) {
			boolean isBackward = walkCheckbox.isSelected();
			this.gotoState(State.OngoingStartingMovement);
			m_currentId++;
			m_connection.walk(m_currentId, distance, isBackward, new RobotMovingCallback() {
				@Override
				public void onRobotMoving(Result result) {
					if (result == Result.Success) {
						HexapodCommandsControl.this.gotoState(State.MovementStarted);
					} else {
						HexapodCommandsControl.this.gotoState(State.FailedStartingMovement);
					}
				}
			});
		}
	}

	protected void onWalkSidewaysButtonClicked() {
		Integer distance = null;
		try {
			distance = Integer.parseInt(walkSidewaysSpinner.getValue().toString());
		} catch (Exception e) {}
		if (null == distance) {
			return;
		}
		boolean isRightToLeft = walkSidewaysGroup.isSelected(walkSidewaysRightToLeftRadio.getModel());
		boolean isLeftToRight = walkSidewaysGroup.isSelected(walkSidewaysLeftToRightRadio.getModel());
		if (m_state == State.Opened && (isRightToLeft || isLeftToRight)) {
			this.gotoState(State.OngoingStartingMovement);
			m_currentId++;
			m_connection.walkSideways(m_currentId, distance, isRightToLeft, new RobotMovingCallback() {
				@Override
				public void onRobotMoving(Result result) {
					if (result == Result.Success) {
						HexapodCommandsControl.this.gotoState(State.MovementStarted);
					} else {
						HexapodCommandsControl.this.gotoState(State.FailedStartingMovement);
					}
				}
			});
		}
	}

	protected void onWalkToButtonClicked() {
		Integer distance = null;
		Integer angle = null;
		try {
			distance = Integer.parseInt(walkToSpinner1.getValue().toString());
			angle = Integer.parseInt(walkToSpinner2.getValue().toString());
		} catch (Exception e) {}
		if (null == distance) {
			return;
		}
		if (m_state == State.Opened) {
			boolean isBackward = walkToCheckbox.isSelected();
			this.gotoState(State.OngoingStartingMovement);
			m_currentId++;
			m_connection.walkTo(m_currentId, angle, distance, isBackward, new RobotMovingCallback() {
				@Override
				public void onRobotMoving(Result result) {
					if (result == Result.Success) {
						HexapodCommandsControl.this.gotoState(State.MovementStarted);
					} else {
						HexapodCommandsControl.this.gotoState(State.FailedStartingMovement);
					}
				}
			});
		}
	}

	protected void onRotateButtonClicked() {
		Integer angle = null;
		try {
			angle = Integer.parseInt(rotateSpinner.getValue().toString());
		} catch (Exception e) {}
		if (null == angle) {
			return;
		}
		boolean isClockwise = rotateGroup.isSelected(rotateClockwiseRadio.getModel());
		boolean isCounterclockwise = rotateGroup.isSelected(rotateCounterclockwiseRadio.getModel());
		if (m_state == State.Opened && (isClockwise || isCounterclockwise)) {
			this.gotoState(State.OngoingStartingMovement);
			m_currentId++;
			m_connection.rotate(m_currentId, angle, isClockwise, new RobotMovingCallback() {
				@Override
				public void onRobotMoving(Result result) {
					if (result == Result.Success) {
						HexapodCommandsControl.this.gotoState(State.MovementStarted);
					} else {
						HexapodCommandsControl.this.gotoState(State.FailedStartingMovement);
					}
				}
			});
		}
	}

	protected void onLookToButtonClicked() {
		Integer angle = null;
		try {
			angle = Integer.parseInt(lookToSpinner.getValue().toString());
		} catch (Exception e) {}
		if (null == angle) {
			return;
		}
		if (m_state == State.Opened) {
			this.gotoState(State.OngoingStartingMovement);
			m_currentId++;
			m_connection.lookTo(m_currentId, angle, new RobotMovingCallback() {
				@Override
				public void onRobotMoving(Result result) {
					if (result == Result.Success) {
						HexapodCommandsControl.this.gotoState(State.MovementStarted);
					} else {
						HexapodCommandsControl.this.gotoState(State.FailedStartingMovement);
					}
				}
			});
		}
	}

	protected void onPushUpButtonClicked() {
		Integer pushUps = null;
		try {
			pushUps = Integer.parseInt(pushUpSpinner.getValue().toString());
		} catch (Exception e) {}
		if (null == pushUps) {
			return;
		}
		if (m_state == State.Opened) {
			this.gotoState(State.OngoingStartingMovement);
			m_currentId++;
			m_connection.pushUp(m_currentId, pushUps, new RobotMovingCallback() {
				@Override
				public void onRobotMoving(Result result) {
					if (result == Result.Success) {
						HexapodCommandsControl.this.gotoState(State.MovementStarted);
					} else {
						HexapodCommandsControl.this.gotoState(State.FailedStartingMovement);
					}
				}
			});
		}
	}

	protected void onHulaHoopButtonClicked() {
		Integer cycles = null;
		try {
			cycles = Integer.parseInt(hulaHoopSpinner.getValue().toString());
		} catch (Exception e) {}
		if (null == cycles) {
			return;
		}
		if (m_state == State.Opened) {
			this.gotoState(State.OngoingStartingMovement);
			m_currentId++;
			m_connection.hulaHoop(m_currentId, cycles, new RobotMovingCallback() {
				@Override
				public void onRobotMoving(Result result) {
					if (result == Result.Success) {
						HexapodCommandsControl.this.gotoState(State.MovementStarted);
					} else {
						HexapodCommandsControl.this.gotoState(State.FailedStartingMovement);
					}
				}
			});
		}
	}

	protected void onPunchButtonClicked() {
		Integer cycles = null;
		try {
			cycles = Integer.parseInt(punchSpinner.getValue().toString());
		} catch (Exception e) {}
		if (null == cycles) {
			return;
		}
		if (m_state == State.Opened) {
			this.gotoState(State.OngoingStartingMovement);
			m_currentId++;
			m_connection.punch(m_currentId, cycles, new RobotMovingCallback() {
				@Override
				public void onRobotMoving(Result result) {
					if (result == Result.Success) {
						HexapodCommandsControl.this.gotoState(State.MovementStarted);
					} else {
						HexapodCommandsControl.this.gotoState(State.FailedStartingMovement);
					}
				}
			});
		}
	}

	protected void onAdjustButtonClicked() {
		if (m_state == State.Opened) {
			this.gotoState(State.OngoingStartingMovement);
			m_currentId++;
			m_connection.adjust(m_currentId, new RobotMovingCallback() {
				@Override
				public void onRobotMoving(Result result) {
					if (result == Result.Success) {
						HexapodCommandsControl.this.gotoState(State.MovementStarted);
					} else {
						HexapodCommandsControl.this.gotoState(State.FailedStartingMovement);
					}
				}
			});
		}
	}

	protected void onPortCheckboxChanged() {
		if (portCheckbox.isSelected()) {
			portSpinner.setEnabled(true);
		} else {
			portSpinner.setValue(ClientConstants.CLIENT_PORT);
			portSpinner.setEnabled(false);
		}
	}

	protected void onConnectToDriverClicked() {
		String host = hostText.getText();
		Integer port = null;
		try {
			port = Integer.parseInt(portSpinner.getValue().toString());
		} catch (Exception e) {}
		if (null != port) {
			this.gotoState(State.OngoingConnection);
			m_connection.connect(host, port, new ConnectedCallback() {
				@Override
				public void onConnected(String host, int port, Result result) {
					if (m_state == State.OngoingConnection) {
						if (result == Result.Success) {
							HexapodCommandsControl.this.onConnected();
						} else if (result == Result.AlreadyConnected) {
							m_connection.disconnect(new DisconnectedCallback() {
								@Override
								public void onDisconnected(Result result) {
									HexapodCommandsControl.this.gotoState(State.FailedConnection);
								}
							});
						} else {
							HexapodCommandsControl.this.gotoState(State.FailedConnection);
						}
					}
				}
			});
		}
	}

	private void enumeratePorts() {
		gotoState(State.OngoingEnumeration);
		m_connection.enumeratePorts(new PortsEnumeratedCallback() {
			@Override
			public void onPortsEnumerated(String[] ports, PortsEnumeratedCallback.Result result) {
				if (m_state == State.OngoingEnumeration) {
					if (result == PortsEnumeratedCallback.Result.Success) {
						HexapodCommandsControl.this.onEnumerated(ports);
					} else {
						HexapodCommandsControl.this.gotoState(State.FailedEnumeration);
					}
				}
			}

		});
	}

	protected void onConnected() {
		this.gotoState(State.Connected);
		this.enumeratePorts();
	}

	@SuppressWarnings("unchecked")
	protected void onEnumerated(String[] ports) {
		m_ports = ports;
		openCombo.setModel(new DefaultComboBoxModel(ports));
		this.gotoState(State.Connected);
	}

	protected void refreshMagnetometer(MagnetometerData data) {
		magnetometerX.setText(Integer.toString(data.x));
		magnetometerY.setText(Integer.toString(data.y));
		magnetometerZ.setText(Integer.toString(data.z));
		magnetometerAngle.setText(Float.toString(data.heading));
	}

	protected void refreshAccelerometer(AccelerometerData data) {
		accelerometerX.setText(Float.toString(data.x));
		accelerometerY.setText(Float.toString(data.y));
		accelerometerZ.setText(Float.toString(data.z));
	}

	protected void onMoved(RobotConnection connection, int value, int length, int id, MovementNotificationCallback.Cause cause) {
		if (m_state == State.MovementStarted && m_currentId == id) {
			this.gotoState(State.Opened);
		}
	}

	protected void onOffline(RobotConnection connection, OfflineCallback.Cause cause) {
		this.gotoState(State.NotConnected);
	}
}
