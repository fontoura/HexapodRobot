/*
 * ControlBlock.h
 *
 *  Created on: 11/09/2013
 */

#ifndef BASE_CONTROLBLOCK_H_
#define BASE_CONTROLBLOCK_H_

#include "../globaldefs.h"

namespace base
{
	class Object;
	class PoolBase;
	class ControlBlockStack;

	/**
	 * Classe que representa o bloco de controle de um objeto, utilizado pelo sistema de contagem de referências.
	 */
	class ControlBlock
	{
		friend class PoolBase;
		friend class ControlBlockStack;

		private:
#ifdef DEBUG_BASE_CONTROLBLOCK
			static int m_lastId;
			int m_id;
#endif /* DEBUG_BASE_CONTROLBLOCK */

			/**
			 * Contagem de referências fracas e fortes ao objeto.
			 */
			int m_count;

			/**
			 * Contagem de referências fortes ao objeto.
			 */
			int m_strongCount;

			/**
			 * Objeto ao qual este bloco de controle está associado.
			 */
			Object* m_target;

			/**
			 * Bloco de controle seguinte na pilha de blocos livres.
			 */
			ControlBlock* m_next;

		protected:
			/**
			 * Cria um bloco de controle não associado a um objeto.
			 */
			inline ControlBlock();

			/**
			 * Destrutor não-virtual para evitar herança.
			 */
			inline ~ControlBlock();

		public:
			/**
			 * Associa este bloco de controle a um objeto a partir de seu ponteiro.
			 * @param target Ponteiro Ponteiro para o objeto ao qual o bloco de controle deve ser associado.
			 */
			inline void reset(Object* object);

			/**
			 * Incrementa o contador de referências fortes associado a este bloco de controle.
			 */
			inline void incrementStrong();

			/**
			 * Decrementa o contador de referências fortes associado a este bloco de controle.
			 */
			inline void decrementStrong();

			/**
			 * Incrementa o contador de referências fracas associado a este bloco de controle.
			 */
			inline void incrementWeak();

			/**
			 * Decrementa o contador de referências fracas associado a este bloco de controle.
			 */
			inline void decrementWeak();

			/**
			 * Obtém o ponteiro para o objeto genérico ao qual este bloco de controle está associado.
			 * @return Ponteiro para o objeto genérico ao qual este bloco de controle está associado.
			 */
			inline Object* getTarget();

			/**
			 * Obtém um bloco de controle, associa a um objeto e retorna seu ponteiro.
			 * @param obj Ponteiro para o objeto ao qual o bloco de controle deve ser associado.
			 * @return Ponteiro para o bloco de controle associado ao objeto.
			 */
			inline static ControlBlock* obtain(Object* object);

			/**
			 * Recicla um bloco de controle.
			 * @param block Ponteiro para o bloco de controle que deve ser reciclado.
			 */
			inline static void recycle(ControlBlock* block);

			/**
			 * Entra na região crítica de operação do bloco de controle.
			 */
			static void enterCritical();

			/**
			 * Sai da região crítica de operação do bloco de controle.
			 */
			static void exitCritical();
	};
}

#include "./ControlBlock.hpp"

#endif /* BASE_CONTROLBLOCK_H_ */
