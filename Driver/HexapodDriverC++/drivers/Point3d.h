/*
 * Point3d.h
 *
 *  Created on: 16/09/2013
 */

#ifndef DRIVERS_POINT3D_H_
#define DRIVERS_POINT3D_H_

namespace drivers
{
	/**
	 * Estrutura representando um ponto no espaço em coordenadas cartesianas.
	 * <br/>
	 * As convenções adotadas são (da perspectiva do robô):
	 * <ul>
	 * <li>O eixo x é paralelo ao vetor que aponta da esquerda para a direita do robô.</li>
	 * <li>O eixo y é paralelo ao vetor que aponta da traseira para a dianteira do robô.</li>
	 * <li>O eixo z é paralelo ao vetor que aponta de cima para baixo do robô.</li>
	 * </ul>
	 */
	struct
	{
		int x;
		int y;
		int z;
	};
}

#endif /* DRIVERS_POINT3D_H_ */
