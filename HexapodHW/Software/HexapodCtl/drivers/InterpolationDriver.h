/*
 * InterpolationDriver.h
 *
 *  Created on: 09/09/2013
 */

#ifndef DRIVERS_INTERPOLATIONDRIVER_H_
#define DRIVERS_INTERPOLATIONDRIVER_H_

#include "../globaldefs.h"
#include "../base/all.h"

namespace drivers
{
	/**
	 * Classe representando o driver responsável por realizar operações de baixo nível para movimentação suave (com interpolação) das patas do hexápode.
	 * <br/>
	 * As convenções adotadas são (da perspectiva do robô):
	 * <ul>
	 * <li>O eixo x é paralelo ao vetor que aponta da esquerda para a direita do robô.</li>
	 * <li>O eixo y é paralelo ao vetor que aponta da traseira para a dianteira do robô.</li>
	 * <li>O eixo z é paralelo ao vetor que aponta de cima para baixo do robô.</li>
	 * </ul>
	 */
	class InterpolationDriver :
		public base::Object
	{
		protected:
			/**
			 * Informações sobre as posições das patas.
			 */
			struct
			{
				int x;
				int y;
				int z;
			} m_xyz[6];

		protected:
			inline InterpolationDriver();
			virtual inline ~InterpolationDriver();
			virtual void initialize() = 0;
			virtual void finalize() = 0;

		public:
			/**
			 * Define a posição desejada de uma pata do robô.
			 * @param leg Índice da pata do robô.
			 * @param x Posição x em relação ao eixo da pata.
			 * @param y Posição y em relação ao eixo da pataô.
			 * @param z Posição z em relação ao eixo da pata.
			 */
			inline void setPosition(int leg, int x, int y, int z);

			/**
			 * Executa a movimentação das patas com interpolação.
			 * <br/>
			 * Dentro do possível, este método deve suspender a tarefa enquanto o movimento está em andamento.
			 * @param time Tempo de duração do movimento em microssegundos.
			 * @param steps Número de passos que o movimento deve durar.
			 * @return Não-zero caso tudo ocorra bem, zero caso haja algum problema.
			 */
			virtual bool move(int time, int steps) = 0;

			/**
			 * Cria uma instância do driver e retorna seu ponteiro.
			 * @return Ponteiro para a instância do driver.
			 */
			static InterpolationDriver* create();
	};
}

#include "InterpolationDriver.hpp"

#endif /* DRIVERS_INTERPOLATIONDRIVER_H_ */
