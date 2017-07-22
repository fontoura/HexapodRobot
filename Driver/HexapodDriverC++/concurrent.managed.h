/*
 * concurrent.managed.h
 *
 *  Created on: 28/11/2012
 *      Author: Felipe Michels Fontoura
 */

#ifndef CONCURRENT_MANAGED_H_
#define CONCURRENT_MANAGED_H_

#include <cstdlib>
#include "base.h"

namespace concurrent
{
	namespace managed
	{
#define _strong(T) ::concurrent::managed::StrongReference< T >
#define _weak(T) ::concurrent::managed::WeakReference< T >
#define _array(T) ::concurrent::managed::SafeArray< T >

		class WeakReferenceBase;
		class StrongReferenceBase;

		class WeakReferenceBase
		{
				friend class StrongReferenceBase;
			private:
				base::ControlBlock* m_controlBlock;
			public:
				WeakReferenceBase();
				WeakReferenceBase(const WeakReferenceBase& reference);
				WeakReferenceBase(const StrongReferenceBase& reference);
				~WeakReferenceBase();
				WeakReferenceBase& operator=(StrongReferenceBase& reference);
				WeakReferenceBase& operator=(WeakReferenceBase& reference);
				void clear();
		};

		class StrongReferenceBase
		{
			private:
				base::Object* m_target;
			public:
				StrongReferenceBase();
				StrongReferenceBase(base::Object* pointer);
				StrongReferenceBase(const StrongReferenceBase& reference);
				StrongReferenceBase(const WeakReferenceBase& reference);
				~StrongReferenceBase();
				StrongReferenceBase& operator=(base::Object* pointer);
				StrongReferenceBase& operator=(const StrongReferenceBase& reference);
				StrongReferenceBase& operator=(WeakReferenceBase& reference);
				base::Object* operator->();
				base::Object& operator*();
				bool operator==(base::Object* pointer);
				bool operator==(StrongReferenceBase& reference);
				bool operator!=(base::Object* pointer);
				bool operator!=(StrongReferenceBase& reference);
				base::Object* get();
		};

		template<class T>
		struct StrongReference;
		template<class T>
		struct WeakReference;

		template<class T>
		struct WeakReference
		{
			WeakReferenceBase m_reference;
			inline WeakReference();
			inline ~WeakReference();
			template<class U>
			inline WeakReference(const WeakReference<U>& reference);
			template<class U>
			inline WeakReference(const StrongReference<U>& reference);
			template<class U>
			inline WeakReference<T>& operator=(StrongReference<U>& reference);
			template<class U>
			inline WeakReference<T>& operator=(WeakReference<U>& reference);
			void clear();
		};

		template<class T>
		struct StrongReference
		{
			StrongReferenceBase m_reference;
			inline StrongReference();
			inline StrongReference(T* pointer);
			template<class U>
			inline StrongReference(const StrongReference<U>& reference);
			template<class U>
			inline StrongReference(const WeakReference<U>& reference);
			inline ~StrongReference();
			inline StrongReference<T>& operator=(T* pointer);
			template<class U>
			inline StrongReference<T>& operator=(const StrongReference<U>& reference);
			template<class U>
			inline StrongReference<T>& operator=(WeakReference<U>& reference);
			inline T* operator->();
			inline T& operator*();
			inline bool operator==(T* pointer);
			inline bool operator==(StrongReference<T>& reference);
			inline bool operator!=(T* pointer);
			inline bool operator!=(StrongReference<T>& reference);
			inline T* get();
		};

		template<class T>
		class UnsafeArray :
			public base::Object
		{
			private:
				T* m_array;
				int m_length;
			public:
				UnsafeArray(int length);
				virtual ~UnsafeArray();
				int getLength();
				T& get(int index);
				T& operator[](int index);
		};

		template<class T>
		class SafeArray :
			public UnsafeArray<StrongReference<T> >
		{
			public:
				SafeArray(int length) : UnsafeArray<StrongReference<T> >(length)
			{

			}
		};
	}
}

#include "concurrent.managed.hpp"

#endif /* CONCURRENT_MANAGED_H_ */
