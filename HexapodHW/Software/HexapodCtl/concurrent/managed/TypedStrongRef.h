/*
 * TypedStrongRef.h
 *
 *  Created on: 11/09/2013
 */

#ifndef CONCURRENT_MANAGED_TYPEDSTRONGREF_H_
#define CONCURRENT_MANAGED_TYPEDSTRONGREF_H_

#include "./BaseStrongRef.h"

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
		template <typename T> class TypedWeakRef;
		class BaseStrongRef;
		template <typename T> class TypedStrongRef;

		/**
		 * Classe que representa uma referência forte a um objeto com tipo definido.
		 */
		template <typename T> class TypedStrongRef
			: public BaseStrongRef
		{
			private:
				/**
				 * Ponteiro para o objeto ao qual esta referência aponta.
				 */
				T* m_obj;

			public:
				/**
				 * Constrói uma referência forte não associada a um objeto.
				 */
				inline TypedStrongRef();

				/**
				 * Constrói uma referência forte a um certo objeto a partir de seu ponteiro.
				 * @param pointer Ponteiro para o objeto ao qual esta referência forte deve apontar.
				 */
				inline TypedStrongRef(T* pointer);

				/**
				 * Constrói uma referência forte a um certo objeto a partir de outra referência forte.
				 * @param reference Referência forte ao objeto para o qual esta referência forte deve apontar.
				 */
				template <typename U> inline TypedStrongRef(TypedStrongRef<U>& reference);

				/**
				 * Constrói uma referência forte a um certo objeto a partir de uma referência forte imutável.
				 * @param reference Referência forte imutável ao objeto para o qual esta referência forte deve apontar.
				 */
				template <typename U> inline TypedStrongRef(const TypedStrongRef<U>& reference);

				/**
				 * Constrói uma referência forte a um certo objeto a partir de uma referência fraca.
				 * @param reference Referência fraca ao objeto para o qual esta referência forte deve apontar.
				 */
				inline TypedStrongRef(const BaseWeakRef& reference);

				/**
				 * Destrutor não-virtual para evitar herança.
				 */
				inline ~TypedStrongRef();

				/**
				 * Sobrecarga do operador de atribuição. Define o objeto ao qual esta referência forte aponta a partir de seu ponteiro.
				 * @param pointer Ponteiro para o objeto ao qual esta referência forte deve apontar.
				 * @return Referência a esta instância de TypedStrongRef.
				 */
				inline TypedStrongRef<T>& operator=(T* pointer);

				/**
				 * Sobrecarga do operador de atribuição. Define o objeto ao qual esta referência forte aponta a partir de outra referência forte.
				 * @param reference Referência forte ao objeto para o qual esta referência forte deve apontar.
				 * @return Referência a esta instância de TypedStrongRef.
				 */
				template <typename U> inline TypedStrongRef<T>& operator=(TypedStrongRef<U>& reference);

				/**
				 * Sobrecarga do operador de atribuição. Define o objeto ao qual esta referência forte aponta a partir de outra referência forte imutável.
				 * @param reference Referência forte imutável ao objeto para o qual esta referência forte deve apontar.
				 * @return Referência a esta instância de TypedStrongRef.
				 */
				template <typename U> inline TypedStrongRef<T>& operator=(const TypedStrongRef<U>& reference);

				/**
				 * Sobrecarga do operador de atribuição. Define o objeto ao qual esta referência forte aponta a partir de outra referência fraca.
				 * @param reference Referência fraca ao objeto para o qual esta referência forte deve apontar.
				 * @return Referência a esta instância de TypedStrongRef.
				 */
				inline TypedStrongRef<T>& operator=(const BaseWeakRef& reference);

				/**
				 * Sobrecarga do operador de acesso a membro. Retorna o ponteiro para o objeto ao qual esta referência forte aponta.
				 * @return Ponteiro para o objeto ao qual esta referência forte aponta.
				 */
				inline T* operator->();

				/**
				 * Sobrecarga do operador de acesso a ponteiro. Retorna a referência ao objeto ao qual esta referência forte aponta.
				 * @return Referência ao objeto ao qual esta referência forte aponta.
				 */
				inline T& operator*();

				/**
				 * Sobrecarga do operador de igualdade. Compara o objeto ao qual esta referência forte com outro a partir de seu ponteiro.
				 * @param pointer Ponteiro para o objeto com o qual comparar.
				 * @return Resultado da comparação de igualdade entre os objetos.
				 */
				inline bool operator==(T* pointer);

				/**
				 * Sobrecarga do operador de igualdade. Compara o objeto ao qual esta referência forte com outro a partir de outra referência forte.
				 * @param reference Referência forte ao objeto com o qual comparar.
				 * @return Resultado da comparação de igualdade entre os objetos.
				 */
				template <typename U> inline bool operator==(TypedStrongRef<U>& reference);

				/**
				 * Sobrecarga do operador de igualdade. Compara o objeto ao qual esta referência forte com outro a partir de outra referência forte imutável.
				 * @param reference Referência forte imutável ao objeto com o qual comparar.
				 * @return Resultado da comparação de igualdade entre os objetos.
				 */
				template <typename U> inline bool operator==(const TypedStrongRef<U>& reference);

				/**
				 * Sobrecarga do operador de diferença. Compara o objeto ao qual esta referência forte com outro a partir de seu ponteiro.
				 * @param pointer Ponteiro para o objeto com o qual comparar.
				 * @return Resultado da comparação de diferença entre os objetos.
				 */
				inline bool operator!=(T* pointer);

				/**
				 * Sobrecarga do operador de diferença. Compara o objeto ao qual esta referência forte com outro a partir de outra referência forte.
				 * @param reference Referência forte ao objeto com o qual comparar.
				 * @return Resultado da comparação de diferença entre os objetos.
				 */
				template <typename U> inline bool operator!=(TypedStrongRef<U>& reference);

				/**
				 * Sobrecarga do operador de diferença. Compara o objeto ao qual esta referência forte com outro a partir de outra referência forte imutável.
				 * @param reference Referência forte imutável ao objeto com o qual comparar.
				 * @return Resultado da comparação de diferença entre os objetos.
				 */
				template <typename U> inline bool operator!=(const TypedStrongRef<U>& reference);

				/**
				 * Obtém o ponteiro para o objeto ao qual esta referência forte aponta.
				 * @return Ponteiro para o objeto ao qual esta referência forte aponta.
				 */
				inline T* get();

				/**
				 * Obtém o ponteiro para o bloco de controle associado a esta referência forte.
				 * @return Ponteiro para o bloco de controle associado a esta referência forte.
				 */
				inline base::ControlBlock* getCtrlBlk();

				/**
				 * Obtém um ponteiro genérico para o objeto ao qual esta referência forte aponta.
				 * @return Ponteiro genérico para o objeto ao qual esta referência forte aponta
				 */
				inline base::Object* getObj();
		};
	}
}

#define _strong(T) ::concurrent::managed::TypedStrongRef< T >

#include "./TypedStrongRef.hpp"

#endif /* CONCURRENT_MANAGED_TYPEDSTRONGREF_H_ */
