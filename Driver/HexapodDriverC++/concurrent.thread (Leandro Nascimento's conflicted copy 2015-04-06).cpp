/*
 * concurrent.thread.cpp
 *
 *  Created on: 28/11/2012
 *      Author: Felipe Michels Fontoura
 */

#include "globaldefs.h"
#include "concurrent.thread.h"

#ifdef _WIN32
#include "native/win32/thread.h"
#endif /* _WIN32 */

#ifdef __NIOS2__
#include "native/nios2/thread.h"
#include "native/nios2/semaphore.h"
#endif /* __NIOS2__ */

namespace concurrent
{
	namespace thread
	{
#ifdef _WIN32
		DWORD WINAPI ThreadFunction(LPVOID parameter);
#endif /* __WIN32 */
#ifdef __NIOS2__
		void ThreadFunction(void *parameter) __attribute__((cdecl));
#endif /* __NIOS2__ */

		class ThreadImpl :
			public Thread
		{
				/* função de corpo de thread. */
#ifdef _WIN32
				friend DWORD WINAPI ThreadFunction(LPVOID parameter);
#endif /* __WIN32 */
#ifdef __NIOS2__
				friend void ThreadFunction(void *parameter);
#endif /* __NIOS2__ */

			private:
#ifdef _POOLS_ENABLED
				/* pool de objetos. */
				friend class base::ObjectPool<ThreadImpl, _POOL_SIZE_FOR_THREADS>;
				static base::ObjectPool<ThreadImpl, _POOL_SIZE_FOR_THREADS> m_pool;
#endif /* _POOLS_ENABLED */

			protected:
				/* construtor e destrutor. */
				ThreadImpl();
				~ThreadImpl();

				/* gerência de memória. */
				void initialize(ThreadBody* body);
				void finalize();

			public:
				/* factory. */
				static ThreadImpl* create(ThreadBody* body);

			protected:
				/* corpo da thread. */
				_strong(ThreadBody) m_body;

				/* ponteiro da thread para si própria, mantido durante a execução. */
				_strong(ThreadImpl) m_self;

				/* prioridade desejada da thread. */
				ThreadPriority m_preferedPriority;

#ifdef _WIN32
				/* handle WIN32 referente à thread. */
				HANDLE m_handle;
#endif /* __WIN32 */

#ifdef __NIOS2__
				/* pilha da thread. */
				OS_STK m_stack[_STACK_SIZE_IN_NIOS2];

				/* prioridade da tarefa. */
				INT8U m_priority;

				/* evento do uC/OS-II referente ao semáforo de join. */
				OS_EVENT* m_semaphore;
#endif /* __NIOS2__ */

			public:
				/* implementação de Thread. */
				void setPriority(ThreadPriority value);

				/* implementação de Thread. */
				void run();

				/* implementação de Thread. */
				void start();

				/* implementação de Thread. */
				bool join();

				/* implementação de Thread. */
				bool join(int milliseconds);
		};

#if defined(_WIN32)
		DWORD WINAPI ThreadFunction(LPVOID parameter)
#elif defined(__NIOS2__)
		void ThreadFunction(void *parameter)
#else
		void ThreadFunction(_strong(ThreadImpl)& parameter)
#endif
		{
			_strong(ThreadImpl)& thread = *(_strong(ThreadImpl)*) parameter;
			((ThreadImpl*) thread.get())->run();
			thread = NULL;
#ifdef _WIN32
			return EXIT_SUCCESS;
#endif
#ifdef __NIOS2__
			native::niosii::thread_destroy(thread->m_priority);
#endif /* __NIOS2__ */
		}

		void Thread::sleep(long milliseconds)
		{
#ifdef _WIN32
			native::win32::thread_sleep(milliseconds);
#endif /* __WIN32 */
#ifdef __NIOS2__
			native::niosii::thread_sleep(milliseconds);
#endif /* __NIOS2__ */
		}

		Thread* Thread::create(ThreadBody* body)
		{
			return ThreadImpl::create(body);
		}

#ifdef _POOLS_ENABLED
		base::ObjectPool<ThreadImpl, _POOL_SIZE_FOR_THREADS> ThreadImpl::m_pool;
#endif /* _POOLS_ENABLED */

		ThreadImpl::ThreadImpl()
		{
			m_preferedPriority = RegularThreadPriority;
#ifdef _WIN32
			m_handle = INVALID_HANDLE_VALUE;
#endif /* __WIN32 */
#ifdef __NIOS2__
			m_priority = 0;
			m_semaphore = NULL;
#endif /* __NIOS2__ */
		}

		ThreadImpl::~ThreadImpl()
		{
#ifdef _WIN32
			native::win32::thread_destroy(m_handle);
#endif /* __WIN32 */
#ifdef __NIOS2__
			native::niosii::thread_destroy(m_priority);
			native::niosii::semaphore_destroy(m_semaphore);
#endif /* __NIOS2__ */
		}

		void ThreadImpl::initialize(ThreadBody* body)
		{
			m_preferedPriority = RegularThreadPriority;
			m_body = body;
#ifdef _WIN32
			native::win32::thread_create(m_handle, ThreadFunction, (void*)&m_self);
#endif /* __WIN32 */
#ifdef __NIOS2__
			native::niosii::semaphore_create(m_semaphore, 0);
#endif /* __NIOS2__ */
		}

		void ThreadImpl::finalize()
		{
			m_body = NULL;
#ifdef _WIN32
			native::win32::thread_destroy(m_handle);
#endif /* __WIN32 */
#ifdef __NIOS2__
			native::niosii::semaphore_destroy(m_semaphore);
#endif /* __NIOS2__ */
#ifdef _POOLS_ENABLED
			Object::beforeRecycle();
			ThreadImpl::m_pool.recycle(this);
#else /* ifndef POOLS_ENABLED */
			Thread::finalize();
#endif /* POOLS_ENABLED */
		}

		void ThreadImpl::setPriority(ThreadPriority value)
		{
			m_preferedPriority = value;
		}

		void ThreadImpl::run()
		{
			if (m_body != NULL)
			{
				m_body->run();
				m_body = NULL;
			}
		}

		void ThreadImpl::start()
		{
			m_self = this;
#ifdef _WIN32
			bool result = native::win32::thread_resume(m_handle);
			if (! result)
			{
				m_self = NULL;
				m_body = NULL;
			}
#endif /* __WIN32 */
#ifdef __NIOS2__
			if (native::niosii::semaphore_down(m_semaphore, 0))
			{
				// se a thread já terminou, impede de rodar.
				native::niosii::semaphore_up(m_semaphore);
				return;
			}
			int value = 0;
			if (m_preferedPriority == LowThreadPriority)
			{
				value = -1;
			}
			else if (m_preferedPriority == HighThreadPriority)
			{
				value = 1;
			}
			bool result = native::niosii::thread_create(m_priority, m_stack, _STACK_SIZE_IN_NIOS2, ThreadFunction, (void*)&m_self, m_preferedPriority != LowThreadPriority);
			if (! result)
			{
				// se a task nao pode ser criada, simula que tenha terminado.
				native::niosii::semaphore_up(m_semaphore);
				m_self = NULL;
				m_body = NULL;
			}
#endif /* __NIOS2__ */
		}

		bool ThreadImpl::join()
		{
#ifdef _WIN32
			return native::win32::thread_join(m_handle, -1);
#endif /* __WIN32 */
#ifdef __NIOS2__
			if (native::niosii::semaphore_down(m_semaphore, -1))
			{
				native::niosii::semaphore_up(m_semaphore);
				return true;
			}
			else
			{
				return false;
			}
#endif /* __NIOS2__ */
		}

		bool ThreadImpl::join(int milliseconds)
		{
#ifdef _WIN32
			return native::win32::thread_join(m_handle, milliseconds);
#endif /* __WIN32 */
#ifdef __NIOS2__
			if (native::niosii::semaphore_down(m_semaphore, milliseconds))
			{
				native::niosii::semaphore_up(m_semaphore);
				return true;
			}
			else
			{
				return false;
			}
#endif /* __NIOS2__ */
		}

		ThreadImpl* ThreadImpl::create(ThreadBody* body)
		{
#ifdef _POOLS_ENABLED
			ThreadImpl* thread = ThreadImpl::m_pool.obtain();
#else /* ifndef _POOLS_ENABLED */
			ThreadImpl* thread = new ThreadImpl();
#endif /* _POOLS_ENABLED */
			if (thread != NULL)
			{
				thread->initialize(body);
			}
			return thread;
		}
	}
}
