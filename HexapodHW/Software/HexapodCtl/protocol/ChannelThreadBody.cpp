/*
 * ChannelThreadBody.cpp
 *
 *  Created on: 03/12/2012
 */

#include "../protocol/ChannelThreadBody.h"
#include "../protocol/Channel.h"

namespace protocol
{
	_pool_inst(ChannelThreadBody, _POOL_SIZE_FOR_CHANNELS)

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
		_del_inst(ChannelThreadBody);
	}

	/* factory. */
	ChannelThreadBody* ChannelThreadBody::create(Channel* channel)
	{
		_new_inst(ChannelThreadBody, body);
		body->initialize(channel);
		return body;
	}

	/* implementação de ThreadBody. */
	void ChannelThreadBody::run()
	{
		m_channel->receive();
		m_channel = NULL;
	}
}
