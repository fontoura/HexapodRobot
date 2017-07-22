/*
 * PoolBase.h
 *
 *  Created on: 11/09/2013
 */

#ifndef BASE_POOLBASE_H
#define BASE_POOLBASE_H

#include "../globaldefs.h"

namespace base
{
	class ControlBlock;

	/**
	 * Classe abstrata que é ancestral de todas as pools de objetos.
	 */
	class PoolBase
	{
		protected:
			/**
			 * Destrutor virtual para permitir herança;
			 */
			inline virtual ~PoolBase();

			/**
			 * Entra na região crítica de operação da pool.
			 */
			static inline void enterCritical();

			/**
			 * Sai da região crítica de operação da pool.
			 */
			static inline void exitCritical();

			/**
			 * Obtém o ponteiro do sucessor de certo objeto na pool.
			 * @param obj Ponteiro do objeto cujo sucessor deve ser encontrado.
			 * @return Ponteiro do sucessor do objeto na pool.
			 */
			template <typename T> static inline T* getNext(T* obj);

			/**
			 * Define o sucessor de certo objeto a partir de seu ponteiro.
			 * @param obj Ponteiro do objeto cujo sucessor deve ser alterado.
			 * @param next Ponteiro do objeto que deve tornar-se sucessor do outro.
			 */
			template <typename T> static inline void setNext(T* obj, T* next);
	};
}

#include "./PoolBase.hpp"

#endif /* BASE_POOLBASE_H */
