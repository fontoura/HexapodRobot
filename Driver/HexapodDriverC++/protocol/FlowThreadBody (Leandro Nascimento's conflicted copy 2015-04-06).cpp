/*
 * FlowThreadBody.cpp
 *
 *  Created on: 08/12/2012
 */

#include "../protocol/FlowThreadBody.h"
#include "../protocol/Flow.h"
#include "../protocol/MessageNode.h"
#include "../concurrent.semaphore.h"
#include "../concurrent.time.h"

using namespace concurrent::thread;

namespace protocol
{
#ifdef _POOLS_ENABLED
	/* pool de objetos. */
	base::ObjectPool<FlowThreadBody, _POOL_SIZE_FOR_FLOWS> FlowThreadBody::m_pool;
#endif /* _POOLS_ENABLED */

	/* construtor e destrutor. */
	FlowThreadBody::FlowThreadBody()
	{
	}

	FlowThreadBody::~FlowThreadBody()
	{
	}

	/* gerência de memória. */
	void FlowThreadBody::initialize(Flow* flow)
	{
		m_flow = flow;
	}

	void FlowThreadBody::finalize()
	{
		m_flow = NULL;
#ifdef _POOLS_ENABLED
		Object::beforeRecycle();
		m_pool.recycle(this);
#else /* ifndef _POOLS_ENABLED */
		Object::finalize();
#endif /* _POOLS_ENABLED */
	}

	/* factory. */
	FlowThreadBody* FlowThreadBody::create(Flow* flow)
	{
#ifdef _POOLS_ENABLED
		FlowThreadBody* body = m_pool.obtain();
#else /* ifndef _POOLS_ENABLED */
		FlowThreadBody* body = new FlowThreadBody();
#endif /* _POOLS_ENABLED */
		if (body != NULL)
		{
			body->initialize(flow);
		}
		return body;
	}

	/* implementação de ThreadBody. */
	void FlowThreadBody::run()
	{
		m_flow->receive();
		m_flow = NULL;
	}
}
