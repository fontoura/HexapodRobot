/*
 * TypedStrongRef.hpp
 *
 *  Created on: 11/09/2013
 */

#include <cstdlib>

#include "../../base/all.h"
#include "./BaseWeakRef.h"

namespace concurrent
{
	namespace managed
	{
		template <typename T> TypedStrongRef<T>::TypedStrongRef()
		{
			m_obj = NULL;
		}

		template <typename T> TypedStrongRef<T>::TypedStrongRef(T* pointer)
		{
			m_obj = pointer;
			if (NULL != m_obj)
			{
				ctrlBlkOf(m_obj)->incrementStrong();
			}
		}

		template <typename T> template <typename U> TypedStrongRef<T>::TypedStrongRef(TypedStrongRef<U>& reference)
		{
			m_obj = (T*)reference.get();
			if (NULL != m_obj)
			{
				ctrlBlkOf(m_obj)->incrementStrong();
			}
		}

		template <typename T> template <typename U> TypedStrongRef<T>::TypedStrongRef(const TypedStrongRef<U>& reference)
		{
			TypedStrongRef<U>& unsafe = *((TypedStrongRef<U>*) &reference);
			m_obj = (T*)unsafe.get();
			if (NULL != m_obj)
			{
				ctrlBlkOf(m_obj)->incrementStrong();
			}
		}

		template <typename T> TypedStrongRef<T>::TypedStrongRef(const BaseWeakRef& reference)
		{
			BaseWeakRef& unsafe = *((BaseWeakRef*) &reference);
			base::ControlBlock* ctrlBlk = unsafe.getCtrlBlk();
			if (ctrlBlk != NULL)
			{
				ctrlBlk->incrementStrong();
				m_obj = dynamic_cast<T*>(ctrlBlk->getTarget());
				if (NULL == m_obj)
				{
					ctrlBlk->decrementStrong();
				}
			} else {
				m_obj = NULL;
			}
		}

		template <typename T> TypedStrongRef<T>::~TypedStrongRef()
		{
			if (NULL != m_obj)
			{
				ctrlBlkOf(m_obj)->decrementStrong();
				m_obj = NULL;
			}
		}

		template <typename T> TypedStrongRef<T>& TypedStrongRef<T>::operator=(T* pointer)
		{
			if (NULL != pointer)
			{
				ctrlBlkOf(pointer)->incrementStrong();
			}
			if (NULL != m_obj)
			{
				ctrlBlkOf(m_obj)->decrementStrong();
			}
			m_obj = pointer;
			return *this;
		}

		template <typename T> template <typename U> TypedStrongRef<T>& TypedStrongRef<T>::operator=(TypedStrongRef<U>& reference)
		{
			T* pointer = reference.get();
			if (NULL != pointer)
			{
				ctrlBlkOf(pointer)->incrementStrong();
			}
			if (NULL != m_obj)
			{
				ctrlBlkOf(m_obj)->decrementStrong();
			}
			m_obj = pointer;
			return *this;
		}

		template <typename T> template <typename U> TypedStrongRef<T>& TypedStrongRef<T>::operator=(const TypedStrongRef<U>& reference)
		{
			TypedStrongRef<U>& unsafe = *((TypedStrongRef<U>*) &reference);
			T* pointer = unsafe.get();
			if (NULL != pointer)
			{
				ctrlBlkOf(pointer)->incrementStrong();
			}
			if (NULL != m_obj)
			{
				ctrlBlkOf(m_obj)->decrementStrong();
			}
			m_obj = pointer;
			return *this;
		}

		template <typename T> TypedStrongRef<T>& TypedStrongRef<T>::operator=(const BaseWeakRef& reference)
		{
			if (NULL != m_obj)
			{
				m_obj->getControlBlock()->decrementStrong();
			}
			BaseWeakRef& unsafe = *((BaseWeakRef*) &reference);
			base::ControlBlock* ctrlBlk = unsafe.getCtrlBlk();
			if (ctrlBlk != NULL)
			{
				ctrlBlk->incrementStrong();
				m_obj = ctrlBlk->getTarget();
				if (NULL == m_obj)
				{
					ctrlBlk->decrementStrong();
				}
			} else {
				m_obj = NULL;
			}
			return *this;
		}

		template <typename T> T* TypedStrongRef<T>::operator->()
		{
			return m_obj;
		}

		template <typename T> T& TypedStrongRef<T>::operator*()
		{
			return *m_obj;
		}

		template <typename T> bool TypedStrongRef<T>::operator==(T* pointer)
		{
			return m_obj == pointer;
		}

		template <typename T> template <typename U> bool TypedStrongRef<T>::operator==(TypedStrongRef<U>& reference)
		{
			return m_obj == reference.get();
		}

		template <typename T> template <typename U> bool TypedStrongRef<T>::operator==(const TypedStrongRef<U>& reference)
		{
			TypedStrongRef<U>& unsafe = *((TypedStrongRef<U>*) &reference);
			return m_obj == unsafe.get();
		}

		template <typename T> bool TypedStrongRef<T>::operator!=(T* pointer)
		{
			return m_obj != pointer;
		}

		template <typename T> template <typename U> bool TypedStrongRef<T>::operator!=(TypedStrongRef<U>& reference)
		{
			return m_obj != reference.get();
		}

		template <typename T> template <typename U> bool TypedStrongRef<T>::operator!=(const TypedStrongRef<U>& reference)
		{
			TypedStrongRef<U>& unsafe = *((TypedStrongRef<U>*) &reference);
			return m_obj != unsafe.get();
		}

		template <typename T> T* TypedStrongRef<T>::get()
		{
			return m_obj;
		}

		template <typename T> base::ControlBlock* TypedStrongRef<T>::getCtrlBlk()
		{
			return ctrlBlkOf(m_obj);
		}

		template <typename T> base::Object* TypedStrongRef<T>::getObj()
		{
			return (base::Object*)m_obj;
		}
	}
}
