package br.edu.utfpr.hexapod2013;

import javax.swing.JFrame;

@SuppressWarnings("serial")
public class HexapodCommandsWindow extends JFrame {
	public static void main(String[] args) {
		HexapodCommandsWindow frame = new HexapodCommandsWindow();
		frame.setVisible(true);
		frame.setTitle("Robô Hexápode");
	}

	private HexapodCommandsWindow() {
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		this.setContentPane(new HexapodCommandsControl());
		this.pack();
		this.setLocationByPlatform(true);
		this.setSize(getInsets().left + getPreferredSize().width + 200 + getInsets().right, getInsets().top + getPreferredSize().height + 200 + getInsets().bottom);
	}
}
