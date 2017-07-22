/*
 * base.cpp
 *
 *  Created on: 28/11/2012
 *      Author: Felipe Michels Fontoura
 */

#include "globaldefs.h"
#include "base.h"

#ifdef _WIN32
#include "windows.h"
#endif /* _WIN32 */

#ifdef __NIOS2__
#include <cstdlib>
#include "includes.h"
#endif /* __NIOS2__ */

#include <iostream>

namespace base
{
#ifdef DEBUG_BASE_CONTROLBLOCK
	int ControlBlock::m_lastId = 0;
#endif /* DEBUG_BASE_CONTROLBLOCK */

	Global ControlBlock::m_global;

#ifdef _WIN32
#define m_controlBlockLock __INTERNAL_WIN32_REFERENCECOUNTER_LOCK

	HANDLE m_controlBlockLock;

	Global::Global()
	{
		m_controlBlockLock = ::CreateSemaphore(NULL, 1, 1, NULL);
#ifdef _POOLS_ENABLED
		m_firstBlock = NULL;
#endif /* _POOLS_ENABLED */
		this->initialize();
	}

	Global::~Global()
	{
		if (INVALID_HANDLE_VALUE != m_controlBlockLock)
		{
			::CloseHandle(m_controlBlockLock);
			m_controlBlockLock = INVALID_HANDLE_VALUE;
		}
	}

	void Global::down()
	{
		WaitForSingleObject(m_controlBlockLock, INFINITE);
	}

	void Global::up()
	{
		ReleaseSemaphore(m_controlBlockLock, 1, NULL);
	}

#endif /* _WIN32 */

#ifdef __NIOS2__

#define m_controlBlockLock __INTERNAL_NIOS_REFERENCECOUNTER_LOCK

	OS_EVENT* m_controlBlockLock;

	Global::Global()
	{
		m_controlBlockLock = ::OSSemCreate(1);
#ifdef _POOLS_ENABLED
		m_firstBlock = NULL;
#endif /* _POOLS_ENABLED */
		this->initialize();
	}

	Global::~Global()
	{
		if (NULL != m_controlBlockLock)
		{
			INT8U error;
			::OSSemDel(m_controlBlockLock, OS_DEL_ALWAYS, &error);
			m_controlBlockLock = NULL;
		}
	}

	void Global::down()
	{
		INT8U error;
		::OSSemPend(m_controlBlockLock, 0, &error);
	}

	void Global::up()
	{
		::OSSemPost(m_controlBlockLock);
	}

#endif /* __NIOS2__ */

#ifdef _POOLS_ENABLED

	void Global::initialize()
	{
#ifdef DEBUG_BASE_CONTROLBLOCK
		std::cout << "Inicializando Global" << std::endl;
#endif /* DEBUG_BASE_CONTROLBLOCK */
		m_firstBlock = NULL;
		for (int i = 0; i < _POOL_SIZE_FOR_CONTROLBLOCKS; i ++)
		{
			ControlBlock* block = &m_allBlocks[i];
			block->m_next = m_firstBlock;
			m_firstBlock = block;
		}
	}

	ControlBlock* Global::obtain(Object* target)
	{
		this->down();
		ControlBlock* block = m_firstBlock;
#ifdef DEBUG_BASE_CONTROLBLOCK
		std::cout << "Obtendo ControlBlock (id " << block->m_id << ")..." << std::endl;
#endif /* DEBUG_BASE_CONTROLBLOCK */
		m_firstBlock = block->m_next;
		this->up();
		block->m_next = NULL;
		block->reset(target);
		return block;
	}

	void Global::recycle(ControlBlock* block)
	{
#ifdef DEBUG_BASE_CONTROLBLOCK
		std::cout << "Reciclando ControlBlock (id " << block->m_id << ")..." << std::endl;
#endif /* DEBUG_BASE_CONTROLBLOCK */
		this->down();
		block->m_next = m_firstBlock;
		m_firstBlock = block;
		this->up();
	}

#else /* ifndef _POOLS_ENABLED */

	void Global::initialize()
	{
#ifdef DEBUG_BASE_CONTROLBLOCK
		std::cout << "Inicializando Global" << std::endl;
#endif /* DEBUG_BASE_CONTROLBLOCK */
	}

	ControlBlock* Global::obtain(Object* target)
	{
		ControlBlock* block = new ControlBlock();
#ifdef DEBUG_BASE_CONTROLBLOCK
		std::cout << "Obtendo ControlBlock (id " << block->m_id << ")..." << std::endl;
#endif /* DEBUG_BASE_CONTROLBLOCK */
		block->reset(target);
		return block;
	}

	void Global::recycle(ControlBlock* block)
	{
#ifdef DEBUG_BASE_CONTROLBLOCK
		std::cout << "Reciclando ControlBlock (id " << block->m_id << ")..." << std::endl;
#endif /* DEBUG_BASE_CONTROLBLOCK */
		delete block;
	}

#endif /* _POOLS_ENABLED */

	ControlBlock::ControlBlock()
	{
#ifdef DEBUG_BASE_CONTROLBLOCK
		m_id = m_lastId;
		m_lastId++;
		std::cout << "Criando ControlBlock (id " << m_id << ")..." << std::endl;
#endif /* DEBUG_BASE_CONTROLBLOCK */
		m_count = 0;
		m_strongCount = 0;
		m_target = NULL;
		m_next = NULL;
	}

	ControlBlock::~ControlBlock()
	{
	}

	void ControlBlock::reset(Object* target)
	{
		m_target = target;
		m_count = 0;
		m_strongCount = 0;
	}

	void ControlBlock::incrementStrong()
	{
		this->down();
		m_count = m_count + 1;
		m_strongCount = m_strongCount + 1;
		this->up();
	}

	void ControlBlock::decrementStrong()
	{
		Object* target = NULL;
		ControlBlock* block = NULL;
		this->down();
		m_count = m_count - 1;
		m_strongCount = m_strongCount - 1;
		if (m_strongCount == 0)
		{
			target = m_target;
			m_target = NULL;
		}
		if (m_count == 0)
		{
			block = this;
		}
		this->up();
		if (NULL != target)
		{
			target->finalize();
			target = NULL;
		}
		if (NULL != block)
		{
			ControlBlock::recycle(block);
			block = NULL;
		}
	}

	void ControlBlock::incrementWeak()
	{
		this->down();
		m_count = m_count + 1;
		this->up();
	}

	void ControlBlock::decrementWeak()
	{
		ControlBlock* block = NULL;
		this->down();
		m_count = m_count - 1;
		if (m_count == 0)
		{
			block = this;
		}
		this->up();
		if (NULL != block)
		{
			ControlBlock::recycle(block);
			block = NULL;
		}
	}

	Object* ControlBlock::getTarget()
	{
		Object* target;
		this->down();
		target = m_target;
		this->up();
		return target;
	}

	void ControlBlock::down()
	{
		m_global.down();
	}

	void ControlBlock::up()
	{
		m_global.up();
	}

	ControlBlock* ControlBlock::obtain(Object* target)
	{
		return m_global.obtain(target);
	}

	void ControlBlock::recycle(ControlBlock* block)
	{
		return m_global.recycle(block);
	}

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
			m_counter = ControlBlock::obtain(this);
		}
		return m_counter;
	}
}
