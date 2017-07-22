/*
 * MessageNode.h
 *
 *  Created on: 08/12/2012
 */

#ifndef PROTOCOL_MESSAGENODE_H_
#define PROTOCOL_MESSAGENODE_H_

#include "../globaldefs.h"
#include "../base/all.h"
#include "../concurrent/managed/all.h"

namespace protocol
{
	class Message;
	class MessageReplyCallback;

	class MessageNode :
		public virtual base::Object
	{
		_pool_decl(MessageNode, _POOL_SIZE_FOR_REPLIERS)

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
