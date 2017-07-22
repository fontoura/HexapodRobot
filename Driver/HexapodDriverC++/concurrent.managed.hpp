/*
 * concurrent.managed.hpp
 *
 *  Created on: 28/11/2012
 *      Author: Felipe Michels Fontoura
 */

#include <cstdlib>

namespace concurrent
{
	namespace managed
	{
		template<class T>
		WeakReference<T>::WeakReference()
		{
		}

		template<class T>
		WeakReference<T>::~WeakReference()
		{

		}

		template<class T>
		template<class U>
		WeakReference<T>::WeakReference(const WeakReference<U>& reference)
		{
			WeakReference<U>* unsafe = ((WeakReference<U>*) &reference);
			if (NULL != unsafe)
			{
				m_reference = reference.m_reference;
			}
		}

		template<class T>
		template<class U>
		WeakReference<T>::WeakReference(const StrongReference<U>& reference)
		{
			StrongReference<U>* unsafe = ((StrongReference<U>*) &reference);
			if (NULL != unsafe)
			{
				m_reference = unsafe->m_reference;
			}
		}

		template<class T>
		template<class U>
		WeakReference<T>& WeakReference<T>::operator=(StrongReference<U>& reference)
		{
			if (NULL != &reference)
			{
				m_reference = reference.m_reference;
			}
			else
			{
				m_reference.clear();
			}
			return *this;
		}

		template<class T>
		template<class U>
		WeakReference<T>& WeakReference<T>::operator=(WeakReference<U>& reference)
		{
			if (NULL != &reference)
			{
				m_reference = reference->m_reference;
			}
			else
			{
				m_reference.clear();
			}
			return *this;
		}

		template<class T>
		void WeakReference<T>::clear()
		{
			m_reference.clear();
		}

		template<class T>
		StrongReference<T>::StrongReference()
		{
		}

		template<class T>
		StrongReference<T>::StrongReference(T* pointer)
		{
			m_reference = pointer;
		}

		template<class T>
		template<class U>
		StrongReference<T>::StrongReference(const StrongReference<U>& reference)
		{
			StrongReference<U>* unsafe = ((StrongReference<U>*) &reference);
			if (NULL != unsafe)
			{
				m_reference = unsafe->m_reference;
			}
		}

		template<class T>
		template<class U>
		StrongReference<T>::StrongReference(const WeakReference<U>& reference)
		{
			WeakReference<U>* unsafe = ((WeakReference<U>*) &reference);
			if (NULL != unsafe)
			{
				m_reference = unsafe->m_reference;
			}
		}

		template<class T>
		StrongReference<T>::~StrongReference()
		{
		}

		template<class T>
		StrongReference<T>& StrongReference<T>::operator=(T* pointer)
		{
			m_reference = pointer;
			return *this;
		}

		template<class T>
		template<class U>
		StrongReference<T>& StrongReference<T>::operator=(const StrongReference<U>& reference)
		{
			StrongReference<U>* unsafe = ((StrongReference<U>*) &reference);
			if (NULL != unsafe)
			{
				m_reference = unsafe->m_reference;
			}
			else
			{
				m_reference = NULL;
			}
			return *this;
		}

		template<class T>
		template<class U>
		StrongReference<T>& StrongReference<T>::operator=(WeakReference<U>& reference)
		{
			WeakReference<U>* unsafe = ((WeakReference<U>*) &reference);
			if (NULL != unsafe)
			{
				m_reference = unsafe->m_reference;
			}
			else
			{
				m_reference = NULL;
			}
			return *this;
		}

		template<class T>
		T* StrongReference<T>::operator->()
		{
			return dynamic_cast<T*>(m_reference.get());
		}

		template<class T>
		T& StrongReference<T>::operator*()
		{
			return *dynamic_cast<T*>(m_reference.get());
		}

		template<class T>
		bool StrongReference<T>::operator==(T* pointer)
		{
			return m_reference == pointer;
		}

		template<class T>
		bool StrongReference<T>::operator==(StrongReference<T>& reference)
		{
			return m_reference == reference.get();
		}

		template<class T>
		bool StrongReference<T>::operator!=(T* pointer)
		{
			return m_reference != pointer;
		}

		template<class T>
		bool StrongReference<T>::operator!=(StrongReference<T>& reference)
		{
			return m_reference != reference.get();
		}

		template<class T>
		T* StrongReference<T>::get()
		{
			return dynamic_cast<T*>(m_reference.get());
		}

		template<class T>
		UnsafeArray<T>::UnsafeArray(int length)
		{
			m_array = new T[length];
			m_length = length;
		}

		template<class T>
		UnsafeArray<T>::~UnsafeArray()
		{
			delete[] m_array;
			m_array = NULL;
		}

		template<class T>
		int UnsafeArray<T>::getLength()
		{
			return m_length;
		}

		template<class T>
		T& UnsafeArray<T>::get(int index)
		{
			return m_array[index];
		}

		template<class T>
		T& UnsafeArray<T>::operator[](int index)
		{
			return m_array[index];
		}
	}
}
