import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;
import java.net.Socket;
import java.net.UnknownHostException;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JSpinner;
import javax.swing.JTextField;
import javax.swing.SpinnerNumberModel;

public class Test extends JFrame {
	private static final long serialVersionUID = 5584879508490159918L;

	private JTextField textField;
	private Socket socket;
	JSpinner spinner;

	public static void main(String[] args) {
		new Test().setVisible(true);
	}

	public Test() {
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		GridBagLayout gridBagLayout = new GridBagLayout();
		gridBagLayout.columnWidths = new int[] { 0, 0, 0, 0, 0 };
		gridBagLayout.rowHeights = new int[] { 0, 0, 0, 0 };
		gridBagLayout.columnWeights = new double[] { 0.0, 1.0, 0.0, 0.0, Double.MIN_VALUE };
		gridBagLayout.rowWeights = new double[] { 0.0, 0.0, 0.0, Double.MIN_VALUE };
		getContentPane().setLayout(gridBagLayout);

		JLabel lblPorta = new JLabel("Porta");
		GridBagConstraints gbc_lblPorta = new GridBagConstraints();
		gbc_lblPorta.insets = new Insets(0, 0, 5, 5);
		gbc_lblPorta.gridx = 0;
		gbc_lblPorta.gridy = 0;
		getContentPane().add(lblPorta, gbc_lblPorta);

		spinner = new JSpinner();
		spinner.setModel(new SpinnerNumberModel(new Integer(0), null, null, new Integer(1)));
		GridBagConstraints gbc_spinner = new GridBagConstraints();
		gbc_spinner.fill = GridBagConstraints.HORIZONTAL;
		gbc_spinner.insets = new Insets(0, 0, 5, 5);
		gbc_spinner.gridx = 1;
		gbc_spinner.gridy = 0;
		getContentPane().add(spinner, gbc_spinner);

		JButton btnNewButton = new JButton("Connect");
		btnNewButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				onConnect();
			}
		});
		GridBagConstraints gbc_btnNewButton = new GridBagConstraints();
		gbc_btnNewButton.insets = new Insets(0, 0, 5, 5);
		gbc_btnNewButton.gridx = 2;
		gbc_btnNewButton.gridy = 0;
		getContentPane().add(btnNewButton, gbc_btnNewButton);

		JButton btnNewButton_1 = new JButton("Disconnect");
		btnNewButton_1.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				onDisconnect();
			}
		});
		GridBagConstraints gbc_btnNewButton_1 = new GridBagConstraints();
		gbc_btnNewButton_1.insets = new Insets(0, 0, 5, 0);
		gbc_btnNewButton_1.gridx = 3;
		gbc_btnNewButton_1.gridy = 0;
		getContentPane().add(btnNewButton_1, gbc_btnNewButton_1);

		textField = new JTextField();
		GridBagConstraints gbc_textField = new GridBagConstraints();
		gbc_textField.insets = new Insets(0, 0, 5, 0);
		gbc_textField.gridwidth = 4;
		gbc_textField.fill = GridBagConstraints.HORIZONTAL;
		gbc_textField.gridx = 0;
		gbc_textField.gridy = 1;
		getContentPane().add(textField, gbc_textField);
		textField.setColumns(10);

		JButton btnNewButton_2 = new JButton("Send");
		btnNewButton_2.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				onSend();
			}
		});
		GridBagConstraints gbc_btnNewButton_2 = new GridBagConstraints();
		gbc_btnNewButton_2.anchor = GridBagConstraints.EAST;
		gbc_btnNewButton_2.gridwidth = 4;
		gbc_btnNewButton_2.insets = new Insets(0, 0, 0, 5);
		gbc_btnNewButton_2.gridx = 0;
		gbc_btnNewButton_2.gridy = 2;
		getContentPane().add(btnNewButton_2, gbc_btnNewButton_2);
	}

	protected void onSend() {
		try {
			this.socket.getOutputStream().write(textField.getText().getBytes());
			this.socket.getOutputStream().flush();
			JOptionPane.showMessageDialog(this, "BYTES ENVIADOS!");
		} catch (Exception e) {
			e.printStackTrace();
			JOptionPane.showMessageDialog(this, "BYTES NAO ENVIADOS!");
		}
	}

	protected void onDisconnect() {
		if (this.socket != null) {
			try {
				this.socket.close();
			} catch (IOException e) {}
			JOptionPane.showMessageDialog(this, "SOCKET FECHADO!");
			this.socket = null;
		}
	}

	protected void onConnect() {
		onDisconnect();
		Socket socket = null;
		try {
			socket = new Socket("localhost", (Integer) (spinner.getValue()));
		} catch (UnknownHostException e) {
			e.printStackTrace();
			/*
			 * if (socket != null)
			 * {
			 * try {
			 * socket.close();
			 * } catch (IOException e2) {}
			 * socket = null;
			 * }
			 */
		} catch (IOException e) {
			e.printStackTrace();
			/*
			 * if (socket != null)
			 * {
			 * try {
			 * socket.close();
			 * } catch (IOException e2) {}
			 * socket = null;
			 * }
			 */
		}
		if (socket != null) {
			JOptionPane.showMessageDialog(this, "SOCKET ABERTO!");
		} else {

			JOptionPane.showMessageDialog(this, "SOCKET NAO ABERTO!");
		}
		this.socket = socket;

	}

}
