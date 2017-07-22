package bot;

/**
 * Estrutura de dados com uma leitura do magnetômetro.
 */
public class MagnetometerData {
	/**
	 * Leitura no eixo X.
	 */
	public short x;

	/**
	 * Leitura no eixo Y.
	 */
	public short y;

	/**
	 * Leitura no eixo Z.
	 */
	public short z;

	/**
	 * Ângulo em relação ao norte.
	 */
	public float heading;
}
