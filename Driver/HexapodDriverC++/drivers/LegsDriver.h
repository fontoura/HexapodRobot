/*
 * LegsDriver.h
 *
 *  Created on: 09/09/2013
 */

#ifndef DRIVERS_LEGSDRIVER_H_
#define DRIVERS_LEGSDRIVER_H_

#include "../globaldefs.h"
#include "../base/all.h"

#include "./LegNumber.h"

namespace drivers
{
	/**
	 * Classe representando o driver responsável por realizar operações de baixo nível para posicionamento das patas do hexápode.
	 * <br/>
	 * As convenções adotadas são (da perspectiva do robô):
	 * <ul>
	 * <li>O eixo x é paralelo ao vetor que aponta da esquerda para a direita do robô.</li>
	 * <li>O eixo y é paralelo ao vetor que aponta da traseira para a dianteira do robô.</li>
	 * <li>O eixo z é paralelo ao vetor que aponta de cima para baixo do robô.</li>
	 * </ul>
	 */
	class LegsDriver :
		public base::Object
	{
		protected:
			/**
			 * Informações sobre as posições das patas.
			 */
			struct
			{
				bool changed;
				int x;
				int y;
				int z;
			} m_legs[6];

		protected:
			inline LegsDriver();
			virtual inline ~LegsDriver();
			virtual inline void initialize();
			virtual void finalize() = 0;

		public:
			/**
			 * Define a posição de uma pata do robô.
			 * @param leg Índice da pata do robô.
			 * @param x Posição x em relação ao eixo da pata.
			 * @param y Posição y em relação ao eixo da pataô.
			 * @param z Posição z em relação ao eixo da pata.
			 */
			inline void setPosition(int leg, int x, int y, int z);

			inline int getX(int leg);
			inline int getY(int leg);
			inline int getZ(int leg);

			/**
			 * Envia os sinais de movimentação para todas as patas.
			 * @return Não-zero caso tudo ocorra bem, zero caso haja algum problema.
			 */
			virtual bool flush() = 0;

			/**
			 * Cria uma instância do driver e retorna seu ponteiro.
			 * @return Ponteiro para a instância do driver.
			 */
			static LegsDriver* create();
	};
}

#include "LegsDriver.hpp"

#endif /* DRIVERS_LEGSDRIVER_H_ */
