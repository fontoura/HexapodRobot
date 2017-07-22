/*
 * PoolBase.hpp
 *
 *  Created on: 11/09/2013
 */

namespace base
{
	PoolBase::~PoolBase()
	{
	}

	void PoolBase::enterCritical()
	{
		ControlBlock::enterCritical();
	}

	void PoolBase::exitCritical()
	{
		ControlBlock::exitCritical();
	}

	template <typename T> T* PoolBase::getNext(T* obj)
	{
		return reinterpret_cast<T*>(obj->m_next);
	}

	template <typename T> void PoolBase::setNext(T* obj, T* next)
	{
		obj->m_next = reinterpret_cast<void*>(next);
	}
}



