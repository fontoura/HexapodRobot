/*
 * MessageNode.cpp
 *
 *  Created on: 08/12/2012
 */

#include "../protocol/MessageNode.h"
#include "../protocol/Message.h"
#include "../protocol/MessageReplyCallback.h"

namespace protocol
{
	_pool_inst(MessageNode, _POOL_SIZE_FOR_REPLIERS)

	MessageNode::MessageNode()
	{
		next = NULL;
		message = NULL;
		callback = NULL;
		absoluteTimeout = 0;
	}

	MessageNode::~MessageNode()
	{
	}

	void MessageNode::initialize()
	{
		next = NULL;
		message = NULL;
		callback = NULL;
		absoluteTimeout = 0;
	}

	void MessageNode::finalize()
	{
		next = NULL;
		message = NULL;
		callback = NULL;
		absoluteTimeout = 0;
		_del_inst(MessageNode);
	}

	MessageNode* MessageNode::create()
	{
		_new_inst(MessageNode, node);
		node->initialize();
		return node;
	}
}
