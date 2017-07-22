package stream.uart;

import java.util.Enumeration;

public class SerialPortInfo {
	private String m_name;

	public SerialPortInfo(String name) {
		m_name = name;
	}

	public String getName() {
		return m_name;
	}

	public static SerialPortInfo[] generate() {
		SerialPortInfo[] ports = new SerialPortInfo[8];
		int i = 0;

		// enumera as portas e adiciona à lista.
		@SuppressWarnings("unchecked")
		Enumeration<gnu.io.CommPortIdentifier> identifiers = (Enumeration<gnu.io.CommPortIdentifier>) gnu.io.CommPortIdentifier.getPortIdentifiers();
		while (identifiers.hasMoreElements()) {
			gnu.io.CommPortIdentifier identifier = identifiers.nextElement();

			// se a porta não for serial, ignora.
			if (gnu.io.CommPortIdentifier.PORT_SERIAL != identifier.getPortType()) {
				continue;
			}

			// se a lista for pequena demais, dobra o tamanho.
			if (i == ports.length) {
				SerialPortInfo[] newPorts = new SerialPortInfo[2 * i];
				System.arraycopy(ports, 0, newPorts, 0, i);
				ports = newPorts;
				newPorts = null;
			}

			// adiciona à lista a porta, se for serial.
			ports[i] = new SerialPortInfo(identifier.getName());
			i++;
		}

		// se a lista for grande demais, diminui.
		if (i < ports.length) {
			SerialPortInfo[] newPorts = new SerialPortInfo[i];
			System.arraycopy(ports, 0, newPorts, 0, i);
			ports = newPorts;
			newPorts = null;
		}

		// retorna a lista gerada.
		return ports;
	}

}
