/*
 * BaseWeakRef.h
 *
 *  Created on: 11/09/2013
 */

#ifndef CONCURRENT_MANAGED_BASEWEAKREF_H_
#define CONCURRENT_MANAGED_BASEWEAKREF_H_

#include "./BaseRef.h"

namespace base
{
	class ControlBlock;
}

namespace concurrent
{
	namespace managed
	{
		class BaseRef;

		/**
		 * Classe abstrata que é ancestral de todas as classes que representam referências fracas.
		 */
		class BaseWeakRef
			: public BaseRef
		{
			protected:
				/**
				 * Bloco de controle associado a esta referência fraca.
				 */
				base::ControlBlock* m_ctrlBlk;
			public:
				/**
				 * Destrutor virtual para permitir herança.
				 */
				inline virtual ~BaseWeakRef();

				/**
				 * Obtém o ponteiro para o bloco de controle associado a esta referência fraca.
				 * @return Ponteiro para o bloco de controle associado a esta referência fraca.
				 */
				inline base::ControlBlock* getCtrlBlk();
		};
	}
}

#include "./BaseWeakRef.hpp"

#endif /* CONCURRENT_MANAGED_BASEWEAKREF_H_ */
