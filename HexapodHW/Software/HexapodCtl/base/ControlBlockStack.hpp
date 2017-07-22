/*
 * ControlBlockStack.hpp
 *
 *  Created on: 11/09/2013
 */

namespace base
{
	ControlBlockStack::ControlBlockStack()
	{
		ControlBlock* top = NULL;
		for (int i = 0; i < _POOL_SIZE_FOR_CONTROLBLOCKS; i ++)
		{
			ControlBlock* block = &m_static[i];
			block->m_next = top;
			top = block;
		}
		m_top = top;
	}

	ControlBlock* ControlBlockStack::pop()
	{
		ControlBlock* block = m_top;
		m_top = block->m_next;
		block->m_next = NULL;
		return block;
	}

	void ControlBlockStack::push(ControlBlock* block)
	{
		block->m_next = m_top;
		m_top = block;
	}
}
