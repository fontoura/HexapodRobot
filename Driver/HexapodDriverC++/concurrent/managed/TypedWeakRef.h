/*
 * TypedWeakRef.h
 *
 *  Created on: 11/09/2013
 */

#ifndef CONCURRENT_MANAGED_TYPEDWEAKREF_H_
#define CONCURRENT_MANAGED_TYPEDWEAKREF_H_

#include "./BaseWeakRef.h"

namespace base
{
	class ControlBlock;
}

namespace concurrent
{
	namespace managed
	{
		class BaseRef;
		class BaseWeakRef;

		/**
		 * Classe que representa uma referência fraca a um objeto com tipo definido.
		 */
		template <typename T> class TypedWeakRef
			: public BaseWeakRef
		{
			public:
				/**
				 * Constrói uma referência fraca não associada a um objeto.
				 */
				inline TypedWeakRef();

				/**
				 * Constrói uma referência fraca a um certo objeto a partir de outra referência forte ou fraca.
				 * @param pointer Referência forte ou fraca ao objeto ao qual esta referência fraca deve apontar.
				 */
				inline TypedWeakRef(BaseRef& reference);

				/**
				 * Constrói uma referência fraca a um certo objeto a partir de outra referência forte ou fraca imutável.
				 * @param reference Referência forte ou fraca imutável ao objeto ao qual esta referência fraca deve apontar.
				 */
				inline TypedWeakRef(const BaseRef& reference);

				/**
				 * Destrutor não-virtual para evitar herança.
				 */
				inline ~TypedWeakRef();

				/**
				 * Sobrecarga do operador de atribuição. Define o objeto ao qual esta referência fraca aponta a partir de outra referência forte ou fraca.
				 * @param reference Referência forte ou fraca ao objeto para o qual esta referência fraca deve apontar.
				 * @return Referência a esta instância de TypedWeakRef.
				 */
				inline TypedWeakRef& operator=(BaseRef& reference);

				/**
				 * Sobrecarga do operador de atribuição. Define o objeto ao qual esta referência fraca aponta a partir de outra referência forte ou fraca imutável.
				 * @param reference Referência forte ou fraca imutável ao objeto para o qual esta referência fraca deve apontar.
				 * @return Referência a esta instância de TypedWeakRef.
				 */
				inline TypedWeakRef& operator=(const BaseRef& reference);

				/**
				 * Limpa esta referência fraca, desassociando-a de qualquer objeto.
				 */
				inline void clear();
		};
	}
}

#define _weak(T) ::concurrent::managed::TypedWeakRef< T >

#include "./TypedWeakRef.hpp"

#endif /* CONCURRENT_MANAGED_TYPEDWEAKREF_H_ */
