package br.edu.utfpr.hexapod2013;

import java.awt.Graphics;
import java.awt.image.BufferedImage;

import javax.swing.JComponent;

@SuppressWarnings("serial")
class StretchImageComponent extends JComponent {
	private BufferedImage m_image;

	public void setImage(BufferedImage value) {
		m_image = value;
		this.repaint();
	}

	public BufferedImage getImage() {
		return m_image;
	}

	@Override
	public void paint(Graphics g) {
		super.paint(g);
		if (null != m_image) {
			int width, height, x, y;
			if (m_image.getWidth() * this.getHeight() > m_image.getHeight() * this.getWidth()) {
				// a altura foi menos reduzida que a largura...
				// ajusta com base na largura.
				width = this.getWidth();
				height = (m_image.getHeight() * this.getWidth()) / m_image.getWidth();
				x = 0;
				y = (this.getHeight() - height) >> 1;
			} else {
				// a largura foi menos reduzida que a altura...
				// ajusta com base na altura.
				width = (m_image.getWidth() * this.getHeight()) / m_image.getHeight();
				height = this.getHeight();
				x = (this.getWidth() - width) >> 1;
				y = 0;
			}
			g.drawImage(m_image, x, y, width, height, null);
		}
	}
}
