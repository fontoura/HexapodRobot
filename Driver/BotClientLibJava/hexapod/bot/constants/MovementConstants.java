package bot.constants;

public interface MovementConstants {
	/**
	 * Constante indicando o movimento de andar.
	 * <p>
	 * O parâmetro é o número de passos à frente.
	 */
	public static final short MOVEMENT_WALK = (short) 0xACE;

	/**
	 * Constante indicando o movimento de andar de lado.
	 * <p>
	 * O parâmetro é o número de passos à direita.
	 */
	public static final short MOVEMENT_WALKSIDEWAYS = (short) 0xC0A;

	/**
	 * Constante indicando o movimento de girar em um certo número ângulos.
	 * <p>
	 * O parâmetro é o ângulo em graus vezes 1024.
	 */
	public static final short MOVEMENT_ROTATE = (short) 0xCAB;

	/**
	 * Constante indicando o movimento de girar para um certo ângulo.
	 * <p>
	 * O parâmetro é o ângulo em graus vezes 1024.
	 */
	public static final short MOVEMENT_LOOKTO = (short) 0xB0A;

	/**
	 * Constante indicando o movimento de andar.
	 * <p>
	 * Os parâmetros são o ângulo em graus vezes 1024 e o número de passos à frente.
	 */
	public static final short MOVEMENT_WALKTO = (short) 0xFACA;

	/**
	 * Constante indicando o movimento de bambolear.
	 * <p>
	 * O parâmetro é o número de ciclos.
	 */
	public static final short MOVEMENT_HULAHOOP = (short) 0xC0CA;

	/**
	 * Constante indicando o movimento de fazer flexões.
	 * <p>
	 * O parâmetro é o número de flexões.
	 */
	public static final short MOVEMENT_PUSHUP = (short) 0xB0DE;

	/**
	 * Movimento de socar.
	 * <p>
	 * O parâmetro é o número de socos.
	 */
	public static final short MOVEMENT_PUNCH = (short) 0xD0CA;

	/**
	 * Constante indicando o movimento de ajustar.
	 */
	public static final short MOVEMENT_ADJUST = (short) 0xBEC0;
}
