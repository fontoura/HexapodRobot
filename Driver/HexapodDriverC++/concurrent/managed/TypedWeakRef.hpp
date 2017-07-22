/*
 * TypedWeakRef.hpp
 *
 *  Created on: 11/09/2013
 */

#include <cstdlib>

#include "../../base/all.h"

namespace concurrent
{
	namespace managed
	{
		template <typename T> TypedWeakRef<T>::TypedWeakRef()
		{
			m_ctrlBlk = NULL;
		}

		template <typename T> TypedWeakRef<T>::TypedWeakRef(BaseRef& reference)
		{
			m_ctrlBlk = reference.getCtrlBlk();
			if (NULL != m_ctrlBlk) {
				m_ctrlBlk->incrementWeak();
			}
		}

		template <typename T> TypedWeakRef<T>::TypedWeakRef(const BaseRef& reference)
		{
			BaseRef& unsafe = *((BaseRef*) &reference);
			m_ctrlBlk = unsafe.getCtrlBlk();
			if (NULL != m_ctrlBlk) {
				m_ctrlBlk->incrementWeak();
			}
		}

		template <typename T> TypedWeakRef<T>::~TypedWeakRef()
		{
			if (NULL != m_ctrlBlk) {
				m_ctrlBlk->decrementWeak();
				m_ctrlBlk = NULL;
			}
		}

		template <typename T> TypedWeakRef<T>& TypedWeakRef<T>::operator=(BaseRef& reference)
		{
			if (NULL != m_ctrlBlk) {
				m_ctrlBlk->decrementWeak();
			}
			m_ctrlBlk = reference.getCtrlBlk();
			if (NULL != m_ctrlBlk) {
				m_ctrlBlk->incrementWeak();
			}
			return *this;
		}

		template <typename T> TypedWeakRef<T>& TypedWeakRef<T>::operator=(const BaseRef& reference)
		{
			if (NULL != m_ctrlBlk) {
				m_ctrlBlk->decrementWeak();
			}
			BaseRef& unsafe = *((BaseRef*) &reference);
			m_ctrlBlk = unsafe.getCtrlBlk();
			if (NULL != m_ctrlBlk) {
				m_ctrlBlk->incrementWeak();
			}
			return *this;
		}

		template <typename T> void TypedWeakRef<T>::clear()
		{
			if (NULL != m_ctrlBlk) {
				m_ctrlBlk->decrementWeak();
				m_ctrlBlk = NULL;
			}
		}
	}
}
