/*
 * MessageNode.h
 *
 *  Created on: 08/12/2012
 */

#ifndef PROTOCOL_MESSAGENODE_H_
#define PROTOCOL_MESSAGENODE_H_

#include "../globaldefs.h"
#include "../base.h"
#include "../concurrent.managed.h"

namespace protocol
{
	class Message;
	class MessageReplyCallback;

	class MessageNode :
		public virtual base::Object
	{
		private:
#ifdef _POOLS_ENABLED
			friend class base::ObjectPool<MessageNode, _POOL_SIZE_FOR_REPLIERS>;
			static base::ObjectPool<MessageNode, _POOL_SIZE_FOR_REPLIERS> m_pool;
#endif /* _POOLS_ENABLED */
		protected:
			MessageNode();
			~MessageNode();
			void initialize();
			void finalize();
		public:
			_strong(MessageNode) next;
			_strong(Message) message;
			_strong(MessageReplyCallback) callback;
			unsigned long absoluteTimeout;
			static MessageNode* create();
	};
}

#endif /* PROTOCOL_MESSAGENODE_H_ */
