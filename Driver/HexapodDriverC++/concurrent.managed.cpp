/*
 * concurrent.managed.cpp
 *
 *  Created on: 11/12/2012
 *      Author: Felipe Michels Fontoura
 */

#include "globaldefs.h"
#include "concurrent.managed.h"
#include <cstdlib>

namespace concurrent
{
	namespace managed
	{
		WeakReferenceBase::WeakReferenceBase()
		{
			m_controlBlock = NULL;
		}

		WeakReferenceBase::WeakReferenceBase(const WeakReferenceBase& reference)
		{
			if (NULL != &reference)
			{
				m_controlBlock = reference.m_controlBlock;
				if (NULL != m_controlBlock)
				{
					m_controlBlock->incrementWeak();
				}
			}
		}

		WeakReferenceBase::WeakReferenceBase(const StrongReferenceBase& reference)
		{
			StrongReferenceBase& unsafe = *((StrongReferenceBase*) &reference);
			if (NULL != &unsafe)
			{
				base::Object* pointer = unsafe.get();
				if (NULL != pointer)
				{
					m_controlBlock = pointer->getControlBlock();
					m_controlBlock->incrementWeak();
				}
				else
				{
					m_controlBlock = NULL;
				}
			}
			else
			{
				m_controlBlock = NULL;
			}
		}

		WeakReferenceBase::~WeakReferenceBase()
		{
			if (NULL != m_controlBlock)
			{
				m_controlBlock->decrementWeak();
				m_controlBlock = NULL;
			}
		}

		WeakReferenceBase& WeakReferenceBase::operator=(StrongReferenceBase& reference)
		{
			if (NULL != m_controlBlock)
			{
				m_controlBlock->decrementWeak();
				m_controlBlock = NULL;
			}
			if (NULL != &reference)
			{
				base::Object* pointer = reference.get();
				if (NULL != pointer)
				{
					m_controlBlock = pointer->getControlBlock();
					m_controlBlock->incrementWeak();
				}
			}
			return *this;
		}

		WeakReferenceBase& WeakReferenceBase::operator=(WeakReferenceBase& reference)
		{
			if (NULL != m_controlBlock)
			{
				m_controlBlock->decrementWeak();
				m_controlBlock = NULL;
			}
			if (NULL != &reference)
			{
				m_controlBlock = reference.m_controlBlock;
				if (NULL != m_controlBlock)
				{
					m_controlBlock->incrementWeak();
				}
			}
			return *this;
		}

		void WeakReferenceBase::clear()
		{
			if (NULL != m_controlBlock)
			{
				m_controlBlock->decrementWeak();
				m_controlBlock = NULL;
			}
		}

		StrongReferenceBase::StrongReferenceBase()
		{
			this->m_target = NULL;
		}

		StrongReferenceBase::StrongReferenceBase(base::Object* pointer)
		{
			this->m_target = pointer;
			if (NULL != pointer)
			{
				pointer->getControlBlock()->incrementStrong();
			}
		}

		StrongReferenceBase::StrongReferenceBase(const StrongReferenceBase& reference)
		{
			StrongReferenceBase& unsafe = *((StrongReferenceBase*) &reference);
			if (NULL != &unsafe)
			{
				if (unsafe != NULL)
				{
					this->m_target = unsafe.get();
					unsafe->getControlBlock()->incrementStrong();
				}
				else
				{
					this->m_target = NULL;
				}
			}
			else
			{
				this->m_target = NULL;
			}
		}

		StrongReferenceBase::StrongReferenceBase(const WeakReferenceBase& reference)
		{
			WeakReferenceBase& unsafe = *((WeakReferenceBase*) &reference);
			if (NULL != &unsafe)
			{
				base::ControlBlock* block = unsafe.m_controlBlock;
				if (block != NULL)
				{
					block->incrementStrong();
					m_target = block->getTarget();
					if (NULL == m_target)
					{
						block->decrementStrong();
					}
				}
				else
				{
					this->m_target = NULL;
				}
			}
			else
			{
				this->m_target = NULL;
			}
		}

		StrongReferenceBase::~StrongReferenceBase()
		{
			if (NULL != this->m_target)
			{
				this->m_target->getControlBlock()->decrementStrong();
			}
		}

		StrongReferenceBase& StrongReferenceBase::operator=(base::Object* pointer)
		{
			if (NULL != pointer)
			{
				pointer->getControlBlock()->incrementStrong();
			}
			if (NULL != this->m_target)
			{
				this->m_target->getControlBlock()->decrementStrong();
			}
			this->m_target = pointer;
			return *this;
		}

		StrongReferenceBase& StrongReferenceBase::operator=(const StrongReferenceBase& reference)
		{
			StrongReferenceBase& unsafe = *((StrongReferenceBase*) &reference);
			if (unsafe == NULL)
			{
				*this = NULL;
			}
			else
			{
				*this = unsafe.get();
			}
			return *this;
		}

		StrongReferenceBase& StrongReferenceBase::operator=(WeakReferenceBase& reference)
		{
			*this = NULL;
			if (NULL != &reference)
			{
				base::ControlBlock* block = reference.m_controlBlock;
				if (block != NULL)
				{
					block->incrementStrong();
					m_target = block->getTarget();
					if (NULL == m_target)
					{
						block->decrementStrong();
					}
				}
			}
			return *this;
		}

		base::Object* StrongReferenceBase::operator->()
		{
			return m_target;
		}

		base::Object& StrongReferenceBase::operator*()
		{
			return *m_target;
		}

		bool StrongReferenceBase::operator==(base::Object* pointer)
		{
			bool result = this->m_target == pointer;
			return result;
		}

		bool StrongReferenceBase::operator==(StrongReferenceBase& reference)
		{
			bool result = this->m_target == reference.get();
			return result;
		}

		bool StrongReferenceBase::operator!=(base::Object* pointer)
		{
			bool result = this->m_target != pointer;
			return result;
		}

		bool StrongReferenceBase::operator!=(StrongReferenceBase& reference)
		{
			bool result = this->m_target != reference.get();
			return result;
		}

		base::Object* StrongReferenceBase::get()
		{
			return m_target;
		}
	}
}
