/*
 * FlowReplier.cpp
 *
 *  Created on: 08/12/2012
 */

#include "../protocol/FlowReplier.h"
#include "../protocol/Channel.h"
#include "../protocol/Message.h"

namespace protocol
{
#ifdef _POOLS_ENABLED
	/* pool de objetos. */
	base::ObjectPool<FlowReplier, _POOL_SIZE_FOR_REPLIERS> FlowReplier::m_pool;
#endif /* _POOLS_ENABLED */

	/* construtor e destrutor. */
	FlowReplier::FlowReplier()
	{
		m_id = 0;
	}

	FlowReplier::~FlowReplier()
	{
	}

	/* gerência de memória. */
	void FlowReplier::initialize(int id, _strong(Channel)& channel)
	{
		m_id = id;
		m_channel = channel;
	}

	void FlowReplier::finalize()
	{
		m_channel.clear();
#ifdef _POOLS_ENABLED
		Object::beforeRecycle();
		m_pool.recycle(this);
#else /* ifndef _POOLS_ENABLED */
		Object::finalize();
#endif /* _POOLS_ENABLED */
	}

	/* factory. */
	FlowReplier* FlowReplier::create(int id, _strong(Channel)& channel)
	{
#ifdef _POOLS_ENABLED
		FlowReplier* flow = m_pool.obtain();
#else /* ifndef _POOLS_ENABLED */
		FlowReplier* flow = new FlowReplier();
#endif /* _POOLS_ENABLED */
		if (flow != NULL)
		{
			flow->initialize(id, channel);
		}
		return flow;
	}

	/* envia a resposta pelo fluxo de mensagens. */
	void FlowReplier::sendReply(_strong(Message)& reply)
	{
		_strong(Channel) channel = m_channel;
		m_channel.clear();
		if (channel != NULL)
		{
			reply->setId(m_id);
			channel->send(reply);
			channel = NULL;
		}
	}
}
