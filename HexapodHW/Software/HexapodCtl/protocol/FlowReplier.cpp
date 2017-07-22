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
	_pool_inst(FlowReplier, _POOL_SIZE_FOR_REPLIERS)

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
		_del_inst(FlowReplier);
	}

	/* factory. */
	FlowReplier* FlowReplier::create(int id, _strong(Channel)& channel)
	{
		_new_inst(FlowReplier, replier);
		replier->initialize(id, channel);
		return replier;
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
