/*
 * concurrent.thread.cpp
 *
 *  Created on: 28/11/2012
 */

#include "globaldefs.h"
#include "concurrent.thread.h"

#ifdef __WIN32__
#include "native/win32/thread.h"
#endif /* __WIN32__ */

#ifdef __NIOS2__
#include "native/nios2/thread.h"
#include "native/nios2/semaphore.h"
#endif /* __NIOS2__ */

namespace concurrent
{
	namespace thread
	{
		void GenericThreadFunction(void* parameter);

		class ThreadImpl :
			public Thread
		{
			friend class Thread;
			friend void GenericThreadFunction(void* parameter);
			_pool_decl(ThreadImpl, _POOL_SIZE_FOR_THREADS)

			protected:
				/* construtor e destrutor. */
				ThreadImpl();
				~ThreadImpl();

				/* gerência de memória. */
				void initialize(ThreadBody* body);
				void finalize();

			protected:
				/* corpo da thread. */
				_strong(ThreadBody) m_body;

				/* ponteiro da thread para si própria, mantido durante a execução. */
				_strong(ThreadImpl) m_self;

				/* prioridade desejada da thread. */
				ThreadPriority m_preferedPriority;

#ifdef __WIN32__
				/* handle WIN32 referente à thread. */
				HANDLE m_handle;
#endif /* __WIN32__ */

#ifdef __NIOS2__
				/* handle FreeRTOS da tarefa referente à thread. */
				xTaskHandle m_task;

				/* handle FreeRTOS do semáforo usado para join. */
				xSemaphoreHandle m_semaphore;
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

		_pool_inst(ThreadImpl, _POOL_SIZE_FOR_THREADS)

		void GenericThreadFunction(void* parameter)
		{
			_strong(ThreadImpl)* thread = reinterpret_cast<_strong(ThreadImpl)*>(parameter);
			(*thread)->run();
#ifdef __NIOS2__
			native::niosii::thread_destroy((*thread)->m_task);
#endif /* __NIOS2__ */
			(*thread) = NULL;
		}

#ifdef __WIN32__
		DWORD WINAPI NativeThreadFunction(LPVOID parameter)
		{
			GenericThreadFunction(parameter);
			return EXIT_SUCCESS;
		}
#endif

#ifdef __NIOS2__
		void NativeThreadFunction(void* parameter)
		{
			GenericThreadFunction(parameter);
		}
#endif /* __NIOS2__ */

		Thread* Thread::create(ThreadBody* body)
		{
			_new_inst(ThreadImpl, thread);
			thread->initialize(body);
			return thread;
		}

		void Thread::sleep(long milliseconds)
		{
#ifdef __WIN32__
			native::win32::thread_sleep(milliseconds);
#endif /* __WIN32__ */
#ifdef __NIOS2__
			native::niosii::thread_sleep(milliseconds);
#endif /* __NIOS2__ */
		}

		ThreadImpl::ThreadImpl()
		{
			m_preferedPriority = RegularThreadPriority;
#ifdef __WIN32__
			m_handle = INVALID_HANDLE_VALUE;
#endif /* __WIN32__ */
#ifdef __NIOS2__
			m_semaphore = NULL;
#endif /* __NIOS2__ */
		}

		ThreadImpl::~ThreadImpl()
		{
#ifdef __WIN32__
			native::win32::thread_destroy(m_handle);
#endif /* __WIN32__ */
#ifdef __NIOS2__
			native::niosii::thread_destroy(m_task);
			native::niosii::semaphore_destroy(m_semaphore);
#endif /* __NIOS2__ */
		}

		void ThreadImpl::initialize(ThreadBody* body)
		{
			m_preferedPriority = RegularThreadPriority;
			m_body = body;
#ifdef __WIN32__
			native::win32::thread_create(m_handle, NativeThreadFunction, reinterpret_cast<void*>(&m_self));
#endif /* __WIN32__ */
#ifdef __NIOS2__
			m_semaphore = native::niosii::semaphore_create(0, 1);
#endif /* __NIOS2__ */
		}

		void ThreadImpl::finalize()
		{
			m_body = NULL;
#ifdef __WIN32__
			native::win32::thread_destroy(m_handle);
#endif /* __WIN32__ */
#ifdef __NIOS2__
			native::niosii::semaphore_destroy(m_semaphore);
			m_semaphore = NULL;
#endif /* __NIOS2__ */

			_del_inst(ThreadImpl);
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
#ifdef __WIN32__
			bool result = native::win32::thread_resume(m_handle);
			if (! result)
			{
				m_self = NULL;
				m_body = NULL;
			}
#endif /* __WIN32__ */
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
			bool result = native::niosii::thread_create(&m_task, _STACK_SIZE_IN_NIOS2, NativeThreadFunction, reinterpret_cast<void*>(&m_self), m_preferedPriority);
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
#ifdef __WIN32__
			return native::win32::thread_join(m_handle, -1);
#endif /* __WIN32__ */
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
#ifdef __WIN32__
			return native::win32::thread_join(m_handle, milliseconds);
#endif /* __WIN32__ */
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
	}
}
