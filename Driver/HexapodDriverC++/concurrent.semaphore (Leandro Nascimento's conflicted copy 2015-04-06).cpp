/*
 * concurrent.semaphore.cpp
 *
 *  Created on: 28/11/2012
 *      Author: Felipe Michels Fontoura
 */

#include "globaldefs.h"
#include "concurrent.semaphore.h"

#ifdef _WIN32
#include "native/win32/semaphore.h"
#endif /* _WIN32 */

#ifdef __NIOS2__
#include "native/nios2/semaphore.h"
#endif /* __NIOS2__ */

namespace concurrent
{
	namespace semaphore
	{
		class SemaphoreImpl :
			public Semaphore
		{
			private:
#ifdef _POOLS_ENABLED
				/* pool de objetos. */
				friend class base::ObjectPool<SemaphoreImpl, _POOL_SIZE_FOR_SEMAPHORES>;
				static base::ObjectPool<SemaphoreImpl, _POOL_SIZE_FOR_SEMAPHORES> m_pool;
#endif /* _POOLS_ENABLED */

			protected:
				/* construtor e destrutor. */
				SemaphoreImpl();
				~SemaphoreImpl();

				/* gerência de memória. */
				void initialize(int count, int maximum);
				void finalize();

			public:
				/* factory. */
				static SemaphoreImpl* create(int count, int maximum);

			protected:
				/* máximo de permits. */
				int m_maximum;

#ifdef _WIN32
				/* handle WIN32 referente ao semáforo. */
				HANDLE m_semaphore;
#endif /* __WIN32 */

#ifdef __NIOS2__
				/* evento do uC/OS-II referente ao semáforo. */
				OS_EVENT* m_semaphore;
#endif /* __NIOS2__ */

			public:
				/* implementação de Semaphore. */
				int getMaximum();

				/* implementação de Semaphore. */
				int getCount();

				/* implementação de Semaphore. */
				void up();

				/* implementação de Semaphore. */
				bool down();

				/* implementação de Semaphore. */
				bool down(int milliseconds);
		};

		Semaphore::Semaphore()
		{
		}

		Semaphore::~Semaphore()
		{
		}

		Semaphore* Semaphore::create(int count, int maximum)
		{
			return SemaphoreImpl::create(count, maximum);
		}

#ifdef _POOLS_ENABLED
		base::ObjectPool<SemaphoreImpl, _POOL_SIZE_FOR_SEMAPHORES> SemaphoreImpl::m_pool;
#endif /* _POOLS_ENABLED */

		SemaphoreImpl::SemaphoreImpl()
		{
			m_maximum = 0;
#ifdef _WIN32
			m_semaphore = INVALID_HANDLE_VALUE;
#endif /* __WIN32 */
#ifdef __NIOS2__
			m_semaphore = NULL;
#endif /* __NIOS2__ */
		}

		SemaphoreImpl::~SemaphoreImpl()
		{
#ifdef _WIN32
			native::win32::semaphore_destroy(m_semaphore);
#endif /* __WIN32 */
#ifdef __NIOS2__
			native::niosii::semaphore_destroy(m_semaphore);
#endif /* __NIOS2__ */
		}

		void SemaphoreImpl::initialize(int count, int maximum)
		{
			m_maximum = maximum;
#ifdef _WIN32
			native::win32::semaphore_create(m_semaphore, count, maximum);
#endif /* __WIN32 */
#ifdef __NIOS2__
			native::niosii::semaphore_create(m_semaphore, count);
#endif /* __NIOS2__ */
		}

		void SemaphoreImpl::finalize()
		{
#ifdef _WIN32
			native::win32::semaphore_destroy(m_semaphore);
#endif /* __WIN32 */
#ifdef __NIOS2__
			native::niosii::semaphore_destroy(m_semaphore);
#endif /* __NIOS2__ */
#ifdef _POOLS_ENABLED
			Object::beforeRecycle();
			SemaphoreImpl::m_pool.recycle(this);
#else /* ifndef POOLS_ENABLED */
			Semaphore::finalize();
#endif /* POOLS_ENABLED */
		}

		int SemaphoreImpl::getMaximum()
		{
			return m_maximum;
		}

		int SemaphoreImpl::getCount()
		{
			int count = 0;
#ifdef _WIN32
			native::win32::semaphore_query(m_semaphore, &count);
#endif /* __WIN32 */
#ifdef __NIOS2__
			native::niosii::semaphore_query(m_semaphore, &count);
#endif /* __NIOS2__ */
			return count;
		}

		void SemaphoreImpl::up()
		{
#ifdef _WIN32
			native::win32::semaphore_up(m_semaphore);
#endif /* __WIN32 */
#ifdef __NIOS2__
			native::niosii::semaphore_up(m_semaphore);
#endif /* __NIOS2__ */
		}

		bool SemaphoreImpl::down()
		{
#ifdef _WIN32
			return native::win32::semaphore_down(m_semaphore, -1);
#endif /* __WIN32 */
#ifdef __NIOS2__
			return native::niosii::semaphore_down(m_semaphore, -1);
#endif /* __NIOS2__ */
		}

		bool SemaphoreImpl::down(int milliseconds)
		{
#ifdef _WIN32
			return native::win32::semaphore_down(m_semaphore, milliseconds);
#endif /* __WIN32 */
#ifdef __NIOS2__
			return native::niosii::semaphore_down(m_semaphore, milliseconds);
#endif /* __NIOS2__ */
		}

		SemaphoreImpl* SemaphoreImpl::create(int count, int maximum)
		{
#ifdef _POOLS_ENABLED
			SemaphoreImpl* semaphore = SemaphoreImpl::m_pool.obtain();
#else /* ifndef _POOLS_ENABLED */
			SemaphoreImpl* semaphore = new SemaphoreImpl();
#endif /* _POOLS_ENABLED */
			if (semaphore != NULL)
			{
				semaphore->initialize(count, maximum);
			}
			return semaphore;
		}
	}
}
