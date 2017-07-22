/*
 * ControlBlockStack.h
 *
 *  Created on: 11/09/2013
 */

#ifndef BASE_CONTROLBLOCKSTACK_H_
#define BASE_CONTROLBLOCKSTACK_H_

#include "./ControlBlock.h"

namespace base
{
	/**
	 * Classe representando uma pilha de blocos de controle pré-alocados.
	 */
	class ControlBlockStack
	{
		private:
			/**
			 * Vetor com todos os blocos, que normalmente não é acessado diretamente.
			 */
			ControlBlock m_static[_POOL_SIZE_FOR_CONTROLBLOCKS];

			/**
			 * Ponteiro para a pilha de blocos livres.
			 */
			ControlBlock* m_top;

		public:
			/**
			 * Constrói uma pilha de blocos cheia.
			 */
			inline ControlBlockStack();

			/**
			 * Remove um bloco de controle no topo da pilha e retorna seu ponteiro.
			 * @return Ponteiro para o bloco de controle removido da pilha.
			 */
			inline ControlBlock* pop();

			/**
			 * Devolve um bloco de controle para o topo da pilha a partir de seu ponteiro.
			 * @param block Ponteiro para o bloco de controle que deve ser devolvido à pilha.
			 */
			inline void push(ControlBlock* block);
	};
}

#include "./ControlBlockStack.hpp"

#endif /* BASE_CONTROLBLOCKSTACK_H_ */
