/*
 * concurrent.jobs.cpp
 *
 *  Created on: 01/02/2013
 *      Author: Felipe Michels Fontoura
 */

#include "globaldefs.h"
#include "concurrent.jobs.h"
#include "concurrent.thread.h"
#include "concurrent.semaphore.h"

using namespace concurrent::thread;
using namespace concurrent::semaphore;

namespace concurrent
{
	namespace jobs
	{
		JobQueue::JobQueue()
		{
		}

		JobQueue::~JobQueue()
		{
		}

		class JobQueueImpl :
			public JobQueue
		{
				friend class JobQueue;
			private:
#ifdef _POOLS_ENABLED
				friend class base::ObjectPool<JobQueueImpl, _POOL_SIZE_FOR_JOBQUEUES>;
				static base::ObjectPool<JobQueueImpl, _POOL_SIZE_FOR_JOBQUEUES> m_pool;
#endif /* _POOLS_ENABLED */
				class JobNode;
				_strong(Semaphore) m_semaphore;
				_strong(Thread) m_thread;
				_strong(JobNode) m_first;
				_strong(JobNode) m_last;
			protected:
				/* construtor e destrutor. */
				JobQueueImpl();
				virtual ~JobQueueImpl();

				void initialize();
				void finalize();

			public:
				void enqueue(_strong(ThreadBody)& body);
			private:
				class JobNode :
					public base::Object
				{
					public:
						_strong(ThreadBody) m_body;
						_strong(JobNode) m_next;
						JobNode(_strong(ThreadBody)& body)
						{
							m_body = body;
						}
				};
				class JobThread :
					public thread::ThreadBody
				{
					private:
						_strong(JobQueueImpl) m_queue;
					public:
						JobThread(JobQueueImpl* queue);
						~JobThread();
						void run();
				};
		};

#ifdef _POOLS_ENABLED
		base::ObjectPool<JobQueueImpl, _POOL_SIZE_FOR_JOBQUEUES> JobQueueImpl::m_pool;
#endif /* _POOLS_ENABLED */


		JobQueueImpl::JobQueueImpl()
		{
		}

		JobQueueImpl::~JobQueueImpl()
		{
		}

		JobQueue* JobQueue::create()
		{
#ifdef _POOLS_ENABLED
			JobQueueImpl* queue = JobQueueImpl::m_pool.obtain();
#else /* ifndef _POOLS_ENABLED */
			JobQueueImpl* queue = new JobQueueImpl();
#endif /* _POOLS_ENABLED */
			queue->initialize();
			return queue;
		}

		void JobQueueImpl::finalize()
		{
			m_semaphore = NULL;
#ifdef _POOLS_ENABLED
			Object::beforeRecycle();
			JobQueueImpl::m_pool.recycle(this);
#else /* ifndef _POOLS_ENABLED */
			Object::finalize();
#endif /* _POOLS_ENABLED */
		}

		void JobQueueImpl::initialize()
		{
			m_semaphore = Semaphore::create(1, 1);
		}

		void JobQueueImpl::enqueue(_strong(ThreadBody)& body)
		{
			_strong(JobNode) node = new JobNode(body);
			m_semaphore->down();
			if (m_first == NULL)
			{
				m_first = node;
				m_last = node;
			}
			else
			{
				m_last->m_next = node;
				m_last = node;
			}
			if (m_thread == NULL)
			{
				m_thread = Thread::create(new JobThread(this));
				m_thread->start();
			}
			m_semaphore->up();
		}

		JobQueueImpl::JobThread::JobThread(JobQueueImpl* queue)
		{
			m_queue = queue;
		}

		JobQueueImpl::JobThread::~JobThread()
		{
			m_queue = NULL;
		}

		void JobQueueImpl::JobThread::run()
		{
			_strong(JobNode) node;

			while (true)
			{
				m_queue->m_semaphore->down();
				node = m_queue->m_first;
				if (node != NULL)
				{
					m_queue->m_first = node->m_next;
					node->m_next = NULL;
					if (m_queue->m_first == NULL)
					{
						m_queue->m_last = NULL;
					}
				}
				if (node == NULL)
				{
					m_queue->m_thread = NULL;
				}
				m_queue->m_semaphore->up();

				if (node != NULL)
				{
					node->m_body->run();
					node->m_body = NULL;
					node = NULL;
				}
				else
				{
					break;
				}
			}
		}
	}
}
