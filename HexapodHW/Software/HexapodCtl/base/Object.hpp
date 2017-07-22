/*
 * Object.hpp
 *
 *  Created on: 11/09/2013
 */

#include "./ControlBlock.h"

namespace base
{
	Object::Object()
	{
#ifdef DEBUG_BASE_OBJECT
		std::cout << "Criando Object..." << std::endl;
#endif /* DEBUG_BASE_OBJECT */

		m_counter = NULL;
		m_next = NULL;
	}

	Object::~Object()
	{
	}

	void Object::finalize()
	{
#ifdef DEBUG_BASE_OBJECT
		std::cout << "Finalizando Object do jeito convencional..." << std::endl;
#endif /* DEBUG_BASE_OBJECT */
		delete this;
	}

	void Object::beforeRecycle()
	{
#ifdef DEBUG_BASE_OBJECT
		std::cout << "Preparando Object para reciclagem..." << std::endl;
#endif /* DEBUG_BASE_OBJECT */
		m_counter = NULL;
	}

	ControlBlock* Object::getControlBlock()
	{
		if (m_counter == NULL)
		{
			ControlBlock::enterCritical();
			if ((volatile ControlBlock*)m_counter == NULL)
			{
				m_counter = ControlBlock::obtain(this);
			}
			ControlBlock::exitCritical();
		}
		return m_counter;
	}

	template <typename T> ControlBlock* Object::ctrlBlkOf(T* obj)
	{
		ControlBlock* ctrlBlk = obj->Object::m_counter;
		if (NULL != ctrlBlk)
		{
			return ctrlBlk;
		}
		return ((Object*)obj)->getControlBlock();
	}
}
