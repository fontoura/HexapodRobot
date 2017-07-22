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
#ifdef _POOLS_ENABLED
	base::ObjectPool<MessageNode, _POOL_SIZE_FOR_REPLIERS> MessageNode::m_pool;
#endif /* _POOLS_ENABLED */

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

#ifdef _POOLS_ENABLED
	void MessageNode::finalize()
	{
		next = NULL;
		message = NULL;
		callback = NULL;
		absoluteTimeout = 0;
		Object::beforeRecycle();
		m_pool.recycle(this);
	}

	MessageNode* MessageNode::create()
	{
		MessageNode* node = m_pool.obtain();
		if (node != NULL)
		{
			node->initialize();
		}
		return node;
	}
#else /* ifndef _POOLS_ENABLED */
	void MessageNode::finalize()
	{
		next = NULL;
		message = NULL;
		callback = NULL;
		absoluteTimeout = 0;
		Object::finalize();
	}

	MessageNode* MessageNode::create()
	{
		MessageNode* node = new MessageNode();
		node->initialize();
		return node;
	}
#endif /* _POOLS_ENABLED */
}
