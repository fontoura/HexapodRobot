/*
 * ChannelThreadBody.cpp
 *
 *  Created on: 03/12/2012
 */

#include "../protocol/ChannelThreadBody.h"
#include "../protocol/Channel.h"

namespace protocol
{
#ifdef _POOLS_ENABLED
	/* pool de objetos. */
	base::ObjectPool<ChannelThreadBody, _POOL_SIZE_FOR_CHANNELS> ChannelThreadBody::m_pool;
#endif /* _POOLS_ENABLED */

	/* construtor e destrutor. */
	ChannelThreadBody::ChannelThreadBody()
	{
	}

	ChannelThreadBody::~ChannelThreadBody()
	{
	}

	/* gerência de memória. */
	void ChannelThreadBody::initialize(Channel* channel)
	{
		m_channel = channel;
	}

	void ChannelThreadBody::finalize()
	{
		m_channel = NULL;
#ifdef _POOLS_ENABLED
		Object::beforeRecycle();
		m_pool.recycle(this);
#else /* ifndef _POOLS_ENABLED */
		Object::finalize();
#endif /* _POOLS_ENABLED */
	}

	/* factory. */
	ChannelThreadBody* ChannelThreadBody::create(Channel* channel)
	{
#ifdef _POOLS_ENABLED
		ChannelThreadBody* body = m_pool.obtain();
#else /* ifndef _POOLS_ENABLED */
		ChannelThreadBody* body = new ChannelThreadBody();
#endif /* _POOLS_ENABLED */
		if (body != NULL)
		{
			body->initialize(channel);
		}
		return body;
	}

	/* implementação de ThreadBody. */
	void ChannelThreadBody::run()
	{
		m_channel->receive();
		m_channel = NULL;
	}
}
