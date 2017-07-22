/*
 * base.h
 *
 *  Created on: 04/12/2012
 *      Author: Felipe Michels Fontoura
 */

#ifndef BASE_H_
#define BASE_H_

//#define DEBUG_BASE
//#define DEBUG_BASE_CONTROLBLOCK
//#define DEBUG_BASE_OBJECT
//#define DEBUG_BASE_OBJECTPOOL

#ifndef NULL
#define NULL 0
#endif

#ifdef DEBUG_BASE
#define DEBUG_BASE_CONTROLBLOCK
#define DEBUG_BASE_OBJECT
#define DEBUG_BASE_OBJECTPOOL
#endif /* DEBUG_BASE_CONTROLBLOCK */

#if defined(DEBUG_BASE) || defined(DEBUG_BASE_CONTROLBLOCK) || defined(DEBUG_BASE_OBJECT) || defined(DEBUG_BASE_OBJECTPOOL)
#include <iostream>
#endif /* defined(DEBUG_BASE) || defined(DEBUG_BASE_CONTROLBLOCK) || defined(DEBUG_BASE_OBJECT) || defined(DEBUG_BASE_OBJECTPOOL) */

namespace concurrent
{
	namespace managed
	{
		class WeakReferenceBase;
		class StrongReferenceBase;
	}
}

namespace base
{
	class Global;
	class ControlBlock;
	class Object;
	class ObjectPoolBase;

	class ControlBlock
	{
			friend class Global;
			friend class ObjectPoolBase;
		private:
			static Global m_global;
		private:
#ifdef DEBUG_BASE_CONTROLBLOCK
			static int m_lastId;
			int m_id;
#endif /* DEBUG_BASE_CONTROLBLOCK */
			int m_count;
			int m_strongCount;
			Object* m_target;
			ControlBlock* m_next;
		protected:
			ControlBlock();
			~ControlBlock();
		public:
			void reset(Object* target);
			void incrementStrong();
			void decrementStrong();
			void incrementWeak();
			void decrementWeak();
			Object* getTarget();
			void down();
			void up();
			static ControlBlock* obtain(Object* target);
			static void recycle(ControlBlock* block);
	};

	class Global
	{
		private:
			friend class ControlBlock;
#ifdef _POOLS_ENABLED
			ControlBlock m_allBlocks[_POOL_SIZE_FOR_CONTROLBLOCKS];
			ControlBlock* m_firstBlock;
#endif /* _POOLS_ENABLED */
			Global();
			~Global();
		public:
			void initialize();
			void down();
			void up();
			ControlBlock* obtain(Object* target);
			void recycle(ControlBlock* block);
	};

	class Object
	{
			friend class ::concurrent::managed::WeakReferenceBase;
			friend class ::concurrent::managed::StrongReferenceBase;
			friend class ObjectPoolBase;
			friend class ControlBlock;
		private:
			ControlBlock* m_counter;
			Object* m_next;
		public:
			Object();
			virtual ~Object();
		protected:
			virtual void finalize();
			void beforeRecycle();
		private:
			ControlBlock* getControlBlock();
	};

	/**
	 * Classe-base das pools de objetos.
	 */
	class ObjectPoolBase
	{
			friend class ControlBlock;
		protected:
			inline ObjectPoolBase()
			{
			}
			inline ~ObjectPoolBase()
			{
			}
			static inline Object* getNext(Object* object)
			{
				return object->m_next;
			}
			static inline void setNext(Object* object, Object* next)
			{
				object->m_next = next;
			}
			static inline void down()
			{
				ControlBlock::m_global.down();
			}
			static inline void up()
			{
				ControlBlock::m_global.up();
			}
	};

	/**
	 * Implementação de uma pool de objetos.
	 */
	template<class Class, int Count>
	class ObjectPool :
		public ObjectPoolBase
	{
		private:
			Class m_objects[Count];
			Class* m_first;
			int m_count;
		public:
			inline ObjectPool();
			inline Class* obtain();
			inline void recycle(Class* node);
	};
}

#include "base.hpp"

#endif /* BASE_H_ */
