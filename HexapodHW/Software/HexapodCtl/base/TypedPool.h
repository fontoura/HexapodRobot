/*
 * TypedPool.h
 *
 *  Created on: 11/09/2013
 */

#ifndef BASE_TYPEDPOOL_H_
#define BASE_TYPEDPOOL_H_

#include "../globaldefs.h"
#include "./PoolBase.h"

namespace concurrent
{
	namespace managed
	{
		class BaseRef;
	}
}


namespace base
{
	/**
	 * Classe que representa uma pool de objetos com tipo e tamanho definidos.
	 */
	template <typename T, int N> class TypedPool :
		public PoolBase
	{
		private:
			/**
			 * Vetor alocado com todos os objetos, que normalmente não é acessado diretamente.
			 */
			T m_objects[N];

			/**
			 * Ponteiro para a pilha de objetos livres.
			 */
			T* m_first;

			/**
			 * Contagem de objetos na pilha.
			 */
			int m_count;
		public:
			/**
			 * Constrói uma pool de objetos cheia.
			 */
			inline TypedPool();

			/**
			 * Remove um objeto da pool e retorna seu ponteiro.
			 * @return Ponteiro para o objeto removido da pool.
			 */
			inline T* obtain();

			/**
			 * Devolve um objeto para a pool a partir de seu ponteiro.
			 * @param block Ponteiro para o objeto que deve ser devolvido à pool.
			 */
			inline void recycle(T* obj);
	};
}

#ifdef _POOLS_ENABLED
#define _pool_decl(T, N) private: friend class ::base::TypedPool<T, N>; static ::base::TypedPool<T, N> m_pool;
#define _pool_inst(T, N) ::base::TypedPool<T, N> T::m_pool;
#define _new_inst(T, v)  T* v = T::m_pool.obtain()
#define _del_inst(T)     Object::beforeRecycle();T::m_pool.recycle(this)
#else
#define _pool_decl(T, N)
#define _pool_inst(T, N)
#define _new_inst(T, v)  T* v = new T()
#define _del_inst(T)     Object::finalize()
#endif

#include "./TypedPool.hpp"

#endif /* BASE_TYPEDPOOL_H_ */
