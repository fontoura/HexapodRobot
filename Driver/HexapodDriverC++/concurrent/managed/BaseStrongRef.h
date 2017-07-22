/*
 * BaseStrongRef.h
 *
 *  Created on: 11/09/2013
 */

#ifndef CONCURRENT_MANAGED_BASESTRONGREF_H_
#define CONCURRENT_MANAGED_BASESTRONGREF_H_

#include "./BaseRef.h"

namespace base
{
	class ControlBlock;
	class Object;
}

namespace concurrent
{
	namespace managed
	{
		class BaseRef;

		/**
		 * Classe abstrata que é ancestral de todas as classes que representam referências fortes.
		 */
		class BaseStrongRef
			: public BaseRef
		{
			public:
				/**
				 * Destrutor virtual para permitir herança.
				 */
				inline virtual ~BaseStrongRef();

				/**
				 * Obtém um ponteiro genérico para o objeto ao qual esta referência forte aponta.
				 * @return Ponteiro genérico para o objeto ao qual esta referência forte aponta
				 */
				virtual base::Object* getObj() = 0;
		};
	}
}

#include "./BaseStrongRef.hpp"

#endif /* CONCURRENT_MANAGED_BASESTRONGREF_H_ */
