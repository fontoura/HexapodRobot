package br.edu.utfpr.hexapod2013;

import java.awt.Color;
import java.awt.Graphics;

import javax.swing.JComponent;

@SuppressWarnings("serial")
class TranslucidRectagleComponent extends JComponent {
	private Color m_color;
	private float m_transparence;
	private Color m_actualColor;

	public TranslucidRectagleComponent() {
		this.refreshRectangle();
	}

	private void refreshRectangle() {
		if (null != m_color) {
			m_actualColor = new Color(m_color.getRed(), m_color.getGreen(), m_color.getBlue(), 0xFF & (int) ((1.0f - m_transparence) * m_color.getAlpha()));
		} else {
			m_actualColor = null;
		}
		this.repaint();
	}

	public void setColor(Color value) {
		m_color = value;
		this.refreshRectangle();
	}

	public Color getColor() {
		return m_color;
	}

	public void setTransparence(float value) {
		m_transparence = value;
		this.refreshRectangle();
	}

	public float getTransparence() {
		return m_transparence;
	}

	@Override
	public void paint(Graphics g) {
		if (null != m_actualColor) {
			g.setColor(m_actualColor);
			g.fillRect(0, 0, this.getWidth(), this.getHeight());
		}
	}
}
