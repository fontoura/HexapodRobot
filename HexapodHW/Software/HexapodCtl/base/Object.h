/*
 * Object.h
 *
 *  Created on: 11/09/2013
 */

#ifndef BASE_OBJECT_H_
#define BASE_OBJECT_H_

#include "../globaldefs.h"

namespace concurrent
{
	namespace managed
	{
		class BaseRef;
	}
}

namespace base
{
	class ControlBlock;
	class PoolBase;

	/**
	 * Classe abstrata que é ancestral de todas as classes que permitem contagem de referências.
	 */
	class Object
	{
		friend class ::concurrent::managed::BaseRef;
		friend class PoolBase;
		friend class ControlBlock;

		private:
			/**
			 * Bloco de controle associado ao objeto.
			 */
			ControlBlock* m_counter;

			/**
			 * Ponteiro do objeto seguinte, quando pertencente a uma pool de objetos.
			 */
			void* m_next;

		public:
			/**
			 * Constrói um objeto vazio.
			 */
			inline Object();

			/**
			 * Destrutor virtual para permitir herança;
			 */
			virtual inline ~Object();

		protected:
			/**
			 * Finaliza o objeto, de forma que não seja necessária nenhuma ação adicional no destrutor.
			 */
			virtual inline void finalize();

			/**
			 * Prapara o objeto para reciclagem.
			 */
			void inline beforeRecycle();

		private:
			/**
			 * Obtém o bloco de controle deste objeto.
			 * @return Bloco de controle deste objeto.
			 */
			inline ControlBlock* getControlBlock();

			/**
			 * Obtém o bloco de controle de um certo objeto.
			 * @param obj Objeto cujo bloco de controle deve ser obtido.
			 * @return Bloco de controle do objeto.
			 */
			template <typename T> static inline ControlBlock* ctrlBlkOf(T* obj);
	};
}

#include "./Object.hpp"

#endif /* BASE_OBJECT_H_ */
