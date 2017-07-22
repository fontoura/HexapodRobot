/*
 * ControlBlock.hpp
 *
 *  Created on: 11/09/2013
 */

#include "./Object.h"
#include "./ControlBlockStack.h"

namespace base
{
#ifdef _POOLS_ENABLED
	extern ControlBlockStack blocks;
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

	void ControlBlock::reset(Object* object)
	{
		m_target = object;
		m_count = 0;
		m_strongCount = 0;
	}

	void ControlBlock::incrementStrong()
	{
		// região crítica, em que o contador de referências fortes é incrementado.
		ControlBlock::enterCritical();
		m_count = m_count + 1;
		m_strongCount = m_strongCount + 1;
		ControlBlock::exitCritical();
	}

	void ControlBlock::decrementStrong()
	{
		Object* target = NULL;
		ControlBlock* block = NULL;

		// região crítica, em que o contador de referências fracas é decrementado.
		ControlBlock::enterCritical();
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
		ControlBlock::exitCritical();

		// verifica se deve apagar o objeto ou o bloco de controle.
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
		// região crítica, em que o contador de referências fracas é incrementado.
		ControlBlock::enterCritical();
		m_count = m_count + 1;
		ControlBlock::exitCritical();
	}

	void ControlBlock::decrementWeak()
	{
		ControlBlock* block = NULL;

		// região crítica, em que o contador de referências fracas é decrementado.
		ControlBlock::enterCritical();
		m_count = m_count - 1;
		if (m_count == 0)
		{
			block = this;
		}
		ControlBlock::exitCritical();

		// verifica se deve apagar o bloco de controle.
		if (NULL != block)
		{
			ControlBlock::recycle(block);
			block = NULL;
		}
	}

	Object* ControlBlock::getTarget()
	{
		return m_target;
	}

	ControlBlock* ControlBlock::obtain(Object* object)
	{
#ifdef DEBUG_BASE_CONTROLBLOCK
		std::cout << "Obtendo ControlBlock (id " << block->m_id << ")..." << std::endl;
#endif /* DEBUG_BASE_CONTROLBLOCK */

#ifdef _POOLS_ENABLED
		// região crítica, em que é obtido um bloco de controle da pilha.
		ControlBlock* block = blocks.pop();
#else /* ifndef _POOLS_ENABLED */
		// é alocado um novo bloco de controle.
		ControlBlock* block = new ControlBlock();
#endif /* _POOLS_ENABLED */

		// define o objeto associado ao bloco de controle.
		block->reset(object);
		return block;
	}

	void ControlBlock::recycle(ControlBlock* block)
	{
#ifdef DEBUG_BASE_CONTROLBLOCK
		std::cout << "Reciclando ControlBlock (id " << block->m_id << ")..." << std::endl;
#endif /* DEBUG_BASE_CONTROLBLOCK */

#ifdef _POOLS_ENABLED
		// região crítica, em que é devolvido o bloco de controle para a pilha.
		ControlBlock::enterCritical();
		blocks.push(block);
		ControlBlock::exitCritical();
#else /* ifndef _POOLS_ENABLED */
		// é apagado o bloco de controle.
		delete block;
#endif /* _POOLS_ENABLED */
	}
}
