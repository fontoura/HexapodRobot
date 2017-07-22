package br.edu.utfpr.hexapod2013.android;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import android.app.Activity;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;
import bot.callback.ConnectedCallback;
import bot.callback.DisconnectedCallback;
import bot.callback.MovementNotificationCallback;
import bot.callback.OfflineCallback;
import bot.callback.OpenedCallback;
import bot.callback.PortsEnumeratedCallback;
import bot.callback.RobotHaltedCallback;
import bot.callback.RobotMovingCallback;
import bot.client.RobotConnection;

public class MainActivity extends Activity {
	/**
	 * Acoplamento fraco de eventos da RobotConnection.
	 */
	private static class WeakEvents implements MovementNotificationCallback, OfflineCallback {
		private WeakReference<MainActivity> m_callback;
		private RobotConnection m_connection;

		/**
		 * Constrói um novo acoplamento fraco de eventos da RobotConnection.
		 * 
		 * @param connection Conexão com o robô.
		 * @param parent Componente gráfico.
		 */
		private WeakEvents(RobotConnection connection, MainActivity parent) {
			m_connection = connection;
			m_callback = new WeakReference<MainActivity>(parent);
		}

		/**
		 * Cria um novo acoplamento fraco de eventos da RobotConnection.
		 * 
		 * @param connection Conexão com o robô.
		 * @param parent Componente gráfico.
		 * @return Acoplamento fraco de eventos da RobotConnection.
		 */
		public static WeakEvents create(RobotConnection connection, MainActivity parent) {
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
		public void onMoved(final RobotConnection connection, final int value, final int length, final int id, final MovementNotificationCallback.Cause cause) {
			final MainActivity callback = m_callback.get();
			if (callback == null) {
				this.dispose();
			} else {
				callback.runOnUiThread(new Runnable() {
					@Override
					public void run() {
						callback.onMoved(connection, value, length, id, cause);
					}
				});
			}
		}

		/**
		 * {@inheritDoc}
		 */
		@Override
		public void onOffline(final RobotConnection connection, final OfflineCallback.Cause cause) {
			final MainActivity callback = m_callback.get();
			if (callback == null) {
				this.dispose();
			} else {
				callback.runOnUiThread(new Runnable() {
					@Override
					public void run() {
						callback.onOffline(connection, cause);
					}
				});
			}
		}
	}

	private enum State {
		/**
		 * O cliente está desconectado.
		 */
		NotConnected,

		/**
		 * O cliente está conectando ao driver.
		 */
		OngoingConnection,

		/**
		 * O cliente está conectado ao driver.
		 */
		Connected,

		/**
		 * O cliente está abrindo a conexão com um robô.
		 */
		OngoingOpening,

		/**
		 * O cliente abriu a conexão com o robô.
		 */
		Opened
	}

	private enum Substate {
		Idle, Input, OngoingStartingMovement, MovementStarted
	}

	private State m_state;
	private Substate m_subState;
	private RobotConnection m_connection;
	private Direction m_direction;

	public MainActivity() {
		m_state = State.NotConnected;
		System.setProperty("java.net.preferIPv6Addresses", "false");
	}

	public void onOffline(RobotConnection connection, OfflineCallback.Cause cause) {
		MainActivity.this.gotoState(State.NotConnected);
	}

	public void onMoved(RobotConnection connection, int value, int length, int id, MovementNotificationCallback.Cause cause) {
		MainActivity.this.gotoState(State.Opened);
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		m_connection.disconnect(null);
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		m_connection = RobotConnection.create();
		WeakEvents.create(m_connection, this);
		setContentView(R.layout.activity_main);
		this.registerEventHandlers();
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_main, menu);
		return true;
	}

	private void registerEventHandlers() {
		Button connectButton = (Button) this.findViewById(R.id.connectButton);
		connectButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				MainActivity.this.onConnectButtonClicked(v);
			}
		});

		Button refreshPortsButton = (Button) this.findViewById(R.id.refreshPortsButton);
		refreshPortsButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				MainActivity.this.onRefreshPortsButtonClicked(v);
			}
		});

		Button openButton = (Button) this.findViewById(R.id.openButton);
		openButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				MainActivity.this.onOpenButtonClicked(v);
			}
		});

		Spinner actionSpinner = (Spinner) this.findViewById(R.id.actionSpinner);
		ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(this, R.array.actions, android.R.layout.simple_spinner_item);
		adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		actionSpinner.setAdapter(adapter);
		MainActivity.this.onActionChosen(actionSpinner.getSelectedItemPosition());
		actionSpinner.setOnItemSelectedListener(new OnItemSelectedListener() {
			@Override
			public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
				MainActivity.this.onActionChosen(position);
			}

			@Override
			public void onNothingSelected(AdapterView<?> parent) {
				MainActivity.this.onActionChosen(-1);
			}
		});

		ImageButton leftButton = (ImageButton) this.findViewById(R.id.buttonLeft);
		leftButton.setOnClickListener(this.getDirectionListener(Direction.Left));
		ImageButton upButton = (ImageButton) this.findViewById(R.id.buttonUp);
		upButton.setOnClickListener(this.getDirectionListener(Direction.Up));
		ImageButton rightButton = (ImageButton) this.findViewById(R.id.buttonRight);
		rightButton.setOnClickListener(this.getDirectionListener(Direction.Right));
		ImageButton downButton = (ImageButton) this.findViewById(R.id.buttonDown);
		downButton.setOnClickListener(this.getDirectionListener(Direction.Down));

		Button spinnerButton = (Button) this.findViewById(R.id.spinnerButton);
		spinnerButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				MainActivity.this.onSpinnerButtonClicked(v);
			}
		});

		Button stopButton = (Button) this.findViewById(R.id.stopButton);
		stopButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				MainActivity.this.onStopButtonClicked(v);
			}
		});
	}

	private OnClickListener getDirectionListener(final Direction dir) {
		return new OnClickListener() {
			@Override
			public void onClick(View v) {
				MainActivity.this.onDirectionButtonClicked(v, dir);
			}
		};
	}

	protected void onActionChosen(int index) {
		ViewGroup arrowsView = (ViewGroup) this.findViewById(R.id.arrowsView);

		arrowsView.setVisibility((index == 0) ? View.VISIBLE : View.GONE);
	}

	private static enum Direction {
		Left, Up, Right, Down
	}

	private static final int CARD_CONNECT = 0;
	private static final int CARD_OPEN = 1;
	private static final int CARD_ONLINE = 2;

	private static final int CARD_OVER_NONE = 0;
	private static final int CARD_OVER_LOADING = 1;
	private static final int CARD_OVER_STOP = 2;
	private static final int CARD_OVER_SPINNER = 3;

	private void chooseLowerCard(int card) {
		ViewGroup connectCard = (ViewGroup) this.findViewById(R.id.connectCard);
		ViewGroup openCard = (ViewGroup) this.findViewById(R.id.openCard);
		ViewGroup onlineCard = (ViewGroup) this.findViewById(R.id.onlineCard);

		connectCard.setVisibility((card == CARD_CONNECT) ? View.VISIBLE : View.GONE);
		openCard.setVisibility((card == CARD_OPEN) ? View.VISIBLE : View.GONE);
		onlineCard.setVisibility((card == CARD_ONLINE) ? View.VISIBLE : View.GONE);

	}

	private void chooseOverCard(int card) {
		ViewGroup overArea = (ViewGroup) this.findViewById(R.id.overArea);
		ViewGroup loadingOverCard = (ViewGroup) this.findViewById(R.id.loadingOverCard);
		ViewGroup stopOverCard = (ViewGroup) this.findViewById(R.id.stopOverCard);
		ViewGroup spinnerOverCard = (ViewGroup) this.findViewById(R.id.spinnerOverCard);

		overArea.setVisibility((card != CARD_OVER_NONE) ? View.VISIBLE : View.GONE);
		loadingOverCard.setVisibility((card == CARD_OVER_LOADING) ? View.VISIBLE : View.GONE);
		stopOverCard.setVisibility((card == CARD_OVER_STOP) ? View.VISIBLE : View.GONE);
		spinnerOverCard.setVisibility((card == CARD_OVER_SPINNER) ? View.VISIBLE : View.GONE);

	}

	private void gotoState(State state) {
		this.gotoState(state, Substate.Idle);
	}

	private void gotoState(State state, Substate substate) {

		TextView loadingText = (TextView) this.findViewById(R.id.loadingText);
		TextView spinnerText = (TextView) this.findViewById(R.id.spinnerText);
		Button spinnerButton = (Button) this.findViewById(R.id.spinnerButton);
		TextView stopText = (TextView) this.findViewById(R.id.stopText);
		Button stopButton = (Button) this.findViewById(R.id.stopButton);
		switch (state) {
			case NotConnected:
				chooseLowerCard(CARD_CONNECT);
				chooseOverCard(CARD_OVER_NONE);
				break;
			case OngoingConnection:
				loadingText.setText(R.string.text_connecting);
				chooseLowerCard(CARD_CONNECT);
				chooseOverCard(CARD_OVER_LOADING);
				break;
			case Connected:
				chooseLowerCard(CARD_OPEN);
				chooseOverCard(CARD_OVER_NONE);
				break;
			case OngoingOpening:
				loadingText.setText(R.string.text_opening);
				chooseLowerCard(CARD_OPEN);
				chooseOverCard(CARD_OVER_LOADING);
				break;
			case Opened:
				chooseLowerCard(CARD_ONLINE);
				switch (substate) {
					case Idle:
						chooseOverCard(CARD_OVER_NONE);
						break;
					case Input:
						spinnerText.setText(R.string.text_walk_steps);
						spinnerButton.setText(R.string.text_walk_start);
						chooseOverCard(CARD_OVER_SPINNER);
						break;
					case OngoingStartingMovement:
						loadingText.setText(R.string.text_startingMovement);
						chooseOverCard(CARD_OVER_LOADING);
						break;
					case MovementStarted:
						stopText.setText(R.string.text_moving);
						stopButton.setText(R.string.text_moving_stop);
						chooseOverCard(CARD_OVER_STOP);
						break;
				}
				break;
		}
		m_state = state;
		m_subState = substate;

		View my_layout = this.findViewById(R.id.my_layout);
		my_layout.requestFocus();

		getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
	}

	@Override
	public void onBackPressed() {
		if (m_state == State.NotConnected) {
			super.onBackPressed();
			return;
		}
		if (m_state == State.Opened || m_state == State.Connected) {
			if (m_subState == Substate.Idle) {
				m_connection.disconnect(new DisconnectedCallback() {
					@Override
					public void onDisconnected(Result result) {
					}
				});
				return;
			} else if (m_state == State.Opened) {
				if (m_subState == Substate.MovementStarted) {
					this.stop();
				} else {
					this.gotoState(State.Opened);
					return;
				}
			}
		}
	}

	private void refreshPortList(List<String> list) {
		Spinner spinner = (Spinner) findViewById(R.id.openSpinner);
		ArrayAdapter<String> dataAdapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, list);
		dataAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spinner.setAdapter(dataAdapter);
	}

	private void stop() {
		m_connection.halt(new RobotHaltedCallback() {
			@Override
			public void onRobotHalted(Result result) {
				if (result == RobotHaltedCallback.Result.Success) {
					MainActivity.this.runOnUiThread(new Runnable() {
						@Override
						public void run() {
							MainActivity.this.gotoState(State.Opened);
						}
					});
				}
			}
		});
	}

	protected void onConnectButtonClicked(View v) {
		EditText hostWidget = (EditText) this.findViewById(R.id.hostText);
		EditText portWidget = (EditText) this.findViewById(R.id.portText);
		if (hostWidget == null || portWidget == null) {
			return;
		}
		String host;
		Integer port;
		try {
			host = hostWidget.getText().toString();
			port = Integer.parseInt(portWidget.getText().toString());
		} catch (Exception e) {
			port = null;
			host = null;
		}
		if (host == null || port == null) {
			return;
		}
		this.gotoState(State.OngoingConnection);
		m_connection.connect(host, port, new ConnectedCallback() {
			@Override
			public void onConnected(String host, int port, final Result result) {
				MainActivity.this.runOnUiThread(new Runnable() {
					@Override
					public void run() {
						if (result == Result.Success) {
							MainActivity.this.gotoState(State.Connected);
						} else {
							MainActivity.this.gotoState(State.NotConnected);
							MainActivity.this.showErrorToast(result);
						}
					}
				});
			}
		});
	}

	protected void onRefreshPortsButtonClicked(View v) {
		if (m_state == State.Connected) {
			m_connection.enumeratePorts(new PortsEnumeratedCallback() {
				@Override
				public void onPortsEnumerated(final String[] ports, final Result result) {
					MainActivity.this.runOnUiThread(new Runnable() {
						@Override
						public void run() {
							if (result == Result.Success) {
								ArrayList<String> portList = new ArrayList<String>(Arrays.asList(ports));
								MainActivity.this.refreshPortList(portList);
							} else {
								MainActivity.this.showErrorToast(result);
							}
						}
					});
				}
			});
		}
	}

	protected void onOpenButtonClicked(View v) {
		if (m_state == State.Connected) {
			Spinner spinner = (Spinner) findViewById(R.id.openSpinner);
			String port = (String) spinner.getSelectedItem();
			if (port == null) {
				port = "";
			}
			this.gotoState(State.OngoingOpening);
			m_connection.open(port, new OpenedCallback() {
				@Override
				public void onOpened(String port, final Result result) {
					MainActivity.this.runOnUiThread(new Runnable() {
						@Override
						public void run() {
							if (m_state == State.OngoingOpening) {
								if (result == Result.Success) {
									MainActivity.this.gotoState(State.Opened);
								} else {
									MainActivity.this.showErrorToast(result);
									MainActivity.this.gotoState(State.Connected);
								}
							}
						}
					});
				}
			});
		}
	}

	protected void onDirectionButtonClicked(View v, Direction dir) {
		m_direction = dir;
		this.gotoState(State.Opened, Substate.Input);
	}

	protected void onSpinnerButtonClicked(View v) {
		if (m_direction == Direction.Up || m_direction == Direction.Down || m_direction == Direction.Left || m_direction == Direction.Right)
			;
		else
			return;
		EditText spinnerWidget = (EditText) this.findViewById(R.id.spinnerData);
		Integer steps;
		try {
			steps = Integer.parseInt(spinnerWidget.getText().toString());
		} catch (Exception e) {
			steps = null;
		}
		if (steps == null) {
			MainActivity.this.showErrorToast(R.string.text_walk_error_noSteps);
			return;
		}
		if (steps <= 0) {
			MainActivity.this.showErrorToast(R.string.text_walk_error_invalidSteps);
			return;
		}
		this.gotoState(State.Opened, Substate.OngoingStartingMovement);
		RobotMovingCallback callback = new RobotMovingCallback() {
			@Override
			public void onRobotMoving(final Result result) {
				MainActivity.this.runOnUiThread(new Runnable() {
					@Override
					public void run() {
						if (result == Result.Success) {
							MainActivity.this.gotoState(State.Opened, Substate.MovementStarted);
						} else {
							MainActivity.this.showErrorToast(R.string.text_move_error);
							MainActivity.this.gotoState(State.Opened);
						}
					}
				});
			}
		};
		if (m_direction == Direction.Up || m_direction == Direction.Down)
			m_connection.walk(0, steps, m_direction == Direction.Down, callback);
		else
			m_connection.walkSideways(0, steps, m_direction == Direction.Left, callback);
	}

	protected void onStopButtonClicked(View v) {
		this.stop();
	}

	protected void showErrorToast(Object genericResult) {
		if (genericResult instanceof ConnectedCallback.Result) {
			ConnectedCallback.Result result = (ConnectedCallback.Result) genericResult;
			switch (result) {
				case AlreadyConnected:
					this.showErrorToastFromResource(R.string.text_connect_error_alreadyConnected);
					break;
				case NotAccepted:
					this.showErrorToastFromResource(R.string.text_connect_error_notAccepted);
					break;
				default:
			}
		}
		if (genericResult instanceof PortsEnumeratedCallback.Result) {
			PortsEnumeratedCallback.Result result = (PortsEnumeratedCallback.Result) genericResult;
			switch (result) {
				case UnexpectedResponse:
					this.showErrorToastFromResource(R.string.text_generic_error_unexpectedResponse);
					break;
				case Timeout:
					this.showErrorToastFromResource(R.string.text_generic_error_timedOut);
					break;
				default:
			}

		}
		if (genericResult instanceof OpenedCallback.Result) {
			OpenedCallback.Result result = (OpenedCallback.Result) genericResult;
			switch (result) {
				case UnexpectedClientResponse:
					this.showErrorToastFromResource(R.string.text_generic_error_unexpectedResponse);
					break;
				case ClientTimeout:
					this.showErrorToastFromResource(R.string.text_generic_error_timedOut);
					break;
				case UnexpectedRobotResponse:
					this.showErrorToastFromResource(R.string.text_generic_error_robotUnexpectedResponse);
					break;
				case RobotTimeout:
					this.showErrorToastFromResource(R.string.text_generic_error_robotTimedOut);
					break;
				case InvalidPort:
					this.showErrorToastFromResource(R.string.text_open_error_invalidPort);
					break;
				default:
			}

		}
	}

	protected void showErrorToastFromResource(int resource) {
		Toast.makeText(this, resource, Toast.LENGTH_LONG).show();
	}
}
