/*
 * TypedPool.hpp
 *
 *  Created on: 11/09/2013
 */

namespace base
{
	template <typename T, int N> TypedPool<T, N>::TypedPool()
	{
		m_count = N;
	#ifdef DEBUG_BASE_OBJECTPOOL
		std::cout << "Criando ObjectPool (" << Count << " elementos)..." << std::endl;
	#endif /* DEBUG_BASE_OBJECTPOOL */
		// adiciona todos os elementos à lista encadeada.
		m_first = NULL;
		for (int i = 0; i < N; i++)
		{
			T* node = &m_objects[i];
			PoolBase::setNext(node, m_first);
			m_first = node;
		}
	}

	template <typename T, int N> T* TypedPool<T, N>::obtain()
	{
		PoolBase::enterCritical();
		m_count--;
#ifdef DEBUG_BASE_OBJECTPOOL
		std::cout << "Invocou ObjectPool.obtain (" << m_count << " de " << Count << " elementos)" << std::endl;
#endif /* DEBUG_BASE_OBJECTPOOL */
		// obtém um elemento da lista encadeada.
		T* node = m_first;
		m_first = PoolBase::getNext<T>(node);
		PoolBase::exitCritical();
		return node;
	}

	template <typename T, int N> void TypedPool<T, N>::recycle(T* obj)
	{
		PoolBase::enterCritical();
		m_count++;
#ifdef DEBUG_BASE_OBJECTPOOL
		std::cout << "Invocou ObjectPool.recycle (" << m_count << " de " << Count << " elementos)" << std::endl;
#endif /* DEBUG_BASE_OBJECTPOOL */
		// devolve um elemento para a lista encadeada.
		PoolBase::setNext(obj, m_first);
		m_first = obj;
		PoolBase::exitCritical();
	}
}
