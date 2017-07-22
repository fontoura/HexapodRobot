package global;

/**
 * Classe com métodos globais de uso geral.
 */
public class Global {
	/**
	 * Construtor privado para impedir instanciação.
	 */
	private Global() {}

	/**
	 * Calcula o checksum simples (apenas soma) de uma série de bytes.
	 * 
	 * @param bytes Buffer de bytes.
	 * @param offset Offset do primeiro byte.
	 * @param length Total de bytes a somar.
	 * @return Checksum simples.
	 */
	public static final short checksum16(byte[] bytes, int offset, int length) {
		if (length <= 0) {
			return 0;
		}
		short checksum = 0;
		for (int i = 0; i < length; i++) {
			checksum += (0xFF & bytes[offset + i]);
		}
		return checksum;
	}

	/**
	 * Escreve um inteiro 16 bits (2 bytes) em um vetor de bytes, usando bytes em ordem little endian,
	 * 
	 * @param target Buffer de bytes.
	 * @param offset Offset do primeiro byte.
	 * @param value Valor de 16 bits (2 bytes) a escrever.
	 */
	public static final void writeLittleEndian16(byte[] target, int offset, short value) {
		target[offset + 0] = (byte) (value & 0xFF);
		target[offset + 1] = (byte) ((value >> 8) & 0xFF);
	}

	/**
	 * Escreve um inteiro 32 bits (4 bytes) em um vetor de bytes, usando bytes em ordem little endian,
	 * 
	 * @param target Buffer de bytes.
	 * @param offset Offset do primeiro byte.
	 * @param value Valor de 32 bits (4 bytes) a escrever.
	 */
	public static final void writeLittleEndian32(byte[] target, int offset, int value) {
		target[offset + 0] = (byte) (value & 0xFF);
		target[offset + 1] = (byte) ((value >> 8) & 0xFF);
		target[offset + 2] = (byte) ((value >> 16) & 0xFF);
		target[offset + 3] = (byte) ((value >> 24) & 0xFF);
	}

	/**
	 * Lê um inteiro 16 bits (2 bytes) de um vetor de bytes, usando bytes em ordem little endian,
	 * 
	 * @param target Buffer de bytes.
	 * @param offset Offset do primeiro byte.
	 * @return Valor de 16 bits (2 bytes) lido.
	 */
	public static final short readLittleEndian16(byte[] source, int offset) {
		return (short) ((source[offset + 0] & 0xFF) | ((source[offset + 1] & 0xFF) << 8));
	}

	/**
	 * Lê um inteiro 32 bits (4 bytes) de um vetor de bytes, usando bytes em ordem little endian,
	 * 
	 * @param target Buffer de bytes.
	 * @param offset Offset do primeiro byte.
	 * @return Valor de 32 bits (4 bytes) lido.
	 */
	public static final int readLittleEndian32(byte[] source, int offset) {
		return (source[offset + 0] & 0xFF) | ((source[offset + 1] & 0xFF) << 8) | ((source[offset + 2] & 0xFF) << 16) | ((source[offset + 3] & 0xFF) << 24);
	}
}
