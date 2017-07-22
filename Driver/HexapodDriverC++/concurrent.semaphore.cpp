/*
 * concurrent.semaphore.cpp
 *
 *  Created on: 28/11/2012
 */

#include "globaldefs.h"
#include "concurrent.semaphore.h"

#ifdef __WIN32__
#include "native/win32/semaphore.h"
#endif /* __WIN32__ */

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
			friend class Semaphore;
			_pool_decl(SemaphoreImpl, _POOL_SIZE_FOR_SEMAPHORES)

			protected:
				/* construtor e destrutor. */
				SemaphoreImpl();
				~SemaphoreImpl();

				/* gerência de memória. */
				void initialize(int count, int maximum);
				void finalize();

			protected:
				/* máximo de permits. */
				int m_maximum;

#ifdef __WIN32__
				/* handle WIN32 referente ao semáforo. */
				HANDLE m_semaphore;
#endif /* __WIN32__ */

#ifdef __NIOS2__
				/* evento do uC/OS-II referente ao semáforo. */
				xSemaphoreHandle m_semaphore;
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

		_pool_inst(SemaphoreImpl, _POOL_SIZE_FOR_SEMAPHORES)

		Semaphore* Semaphore::create(int count, int maximum)
		{
			_new_inst(SemaphoreImpl, semaphore);
			semaphore->initialize(count, maximum);
			return semaphore;
		}

		SemaphoreImpl::SemaphoreImpl()
		{
			m_maximum = 0;
#ifdef __WIN32__
			m_semaphore = INVALID_HANDLE_VALUE;
#endif /* __WIN32__ */
#ifdef __NIOS2__
			m_semaphore = NULL;
#endif /* __NIOS2__ */
		}

		SemaphoreImpl::~SemaphoreImpl()
		{
#ifdef __WIN32__
			native::win32::semaphore_destroy(m_semaphore);
#endif /* __WIN32__ */
#ifdef __NIOS2__
			native::niosii::semaphore_destroy(m_semaphore);
			m_semaphore = NULL;
#endif /* __NIOS2__ */
		}

		void SemaphoreImpl::initialize(int count, int maximum)
		{
			m_maximum = maximum;
#ifdef __WIN32__
			native::win32::semaphore_create(m_semaphore, count, maximum);
#endif /* __WIN32__ */
#ifdef __NIOS2__
			m_semaphore = native::niosii::semaphore_create(count, maximum);
#endif /* __NIOS2__ */
		}

		void SemaphoreImpl::finalize()
		{
#ifdef __WIN32__
			native::win32::semaphore_destroy(m_semaphore);
#endif /* __WIN32__ */
#ifdef __NIOS2__
			native::niosii::semaphore_destroy(m_semaphore);
			m_semaphore = NULL;
#endif /* __NIOS2__ */

			_del_inst(SemaphoreImpl);
		}

		int SemaphoreImpl::getMaximum()
		{
			return m_maximum;
		}

		int SemaphoreImpl::getCount()
		{
			int count;
#ifdef __WIN32__
			count = 0;
			native::win32::semaphore_query(m_semaphore, &count);
#endif /* __WIN32__ */
#ifdef __NIOS2__
			count = native::niosii::semaphore_query(m_semaphore);
#endif /* __NIOS2__ */
			return count;
		}

		void SemaphoreImpl::up()
		{
#ifdef __WIN32__
			native::win32::semaphore_up(m_semaphore);
#endif /* __WIN32__ */
#ifdef __NIOS2__
			native::niosii::semaphore_up(m_semaphore);
#endif /* __NIOS2__ */
		}

		bool SemaphoreImpl::down()
		{
#ifdef __WIN32__
			return native::win32::semaphore_down(m_semaphore, -1);
#endif /* __WIN32__ */
#ifdef __NIOS2__
			return native::niosii::semaphore_down(m_semaphore, -1);
#endif /* __NIOS2__ */
		}

		bool SemaphoreImpl::down(int milliseconds)
		{
#ifdef __WIN32__
			return native::win32::semaphore_down(m_semaphore, milliseconds);
#endif /* __WIN32__ */
#ifdef __NIOS2__
			return native::niosii::semaphore_down(m_semaphore, milliseconds);
#endif /* __NIOS2__ */
		}
	}
}
