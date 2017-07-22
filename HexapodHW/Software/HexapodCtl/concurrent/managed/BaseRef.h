/*
 * BaseRef.h
 *
 *  Created on: 11/09/2013
 */

#ifndef CONCURRENT_MANAGED_BASEREF_H_
#define CONCURRENT_MANAGED_BASEREF_H_

namespace base
{
	class ControlBlock;
	class Object;
}

namespace concurrent
{
	namespace managed
	{
		/**
		 * Classe abstrata que é ancestral de todas as classes que representam referências.
		 */
		class BaseRef
		{
			public:
				/**
				 * Destrutor virtual para permitir herança;
				 */
				inline virtual ~BaseRef();

				/**
				 * Obtém o bloco de controle associado a esta referência.
				 * @return Bloco de controle associado a esta referência.
				 */
				virtual base::ControlBlock* getCtrlBlk() = 0;

			protected:
				/**
				 * Método utilitário que obtém o bloco de controle de um objeto.
				 * @param obj Objeto cujo bloco de controle se quer obter.
				 * @return Bloco de controle do objeto.
				 */
				template <typename T> inline static base::ControlBlock* ctrlBlkOf(T* obj);
		};
	}
}

#include "./BaseRef.hpp"

#endif /* CONCURRENT_MANAGED_BASEREF_H_ */
