/*
 * base.hpp
 *
 *  Created on: 22/03/2013
 *      Author: Felipe Michels Fontoura
 */

namespace base
{
	template<class Class, int Count>
	inline ObjectPool<Class, Count>::ObjectPool()
	{
		m_count = Count;
#ifdef DEBUG_BASE_OBJECTPOOL
		std::cout << "Criando ObjectPool (" << Count << " elementos)..." << std::endl;
#endif /* DEBUG_BASE_OBJECTPOOL */
		// adiciona todos os elementos à lista encadeada.
		m_first = NULL;
		for (int i = 0; i < Count; i++)
		{
			Class* node = &m_objects[i];
			ObjectPoolBase::setNext(node, m_first);
			m_first = node;
		}
	}

	template<class Class, int Count>
	inline Class* ObjectPool<Class, Count>::obtain()
	{
		ObjectPoolBase::down();
		m_count--;
#ifdef DEBUG_BASE_OBJECTPOOL
		std::cout << "Invocou ObjectPool.obtain (" << m_count << " de " << Count << " elementos)" << std::endl;
#endif /* DEBUG_BASE_OBJECTPOOL */
		// obtém um elemento da lista encadeada.
		Class* node = m_first;
		m_first = dynamic_cast<Class*>(ObjectPoolBase::getNext(node));
		ObjectPoolBase::up();
		return node;
	}

	template<class Class, int Count>
	inline void ObjectPool<Class, Count>::recycle(Class* node)
	{
		ObjectPoolBase::down();
		m_count++;
#ifdef DEBUG_BASE_OBJECTPOOL
		std::cout << "Invocou ObjectPool.recycle (" << m_count << " de " << Count << " elementos)" << std::endl;
#endif /* DEBUG_BASE_OBJECTPOOL */
		// devolve um elemento para a lista encadeada.
		ObjectPoolBase::setNext(node, m_first);
		m_first = node;
		ObjectPoolBase::up();
	}
}
