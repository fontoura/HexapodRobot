/*
 * FlowClosedCallback.h
 *
 *  Created on: 08/12/2012
 */

#ifndef PROTOCOL_FLOWCLOSEDCALLBACK_H_
#define PROTOCOL_FLOWCLOSEDCALLBACK_H_

#include "../globaldefs.h"
#include "../base.h"
#include "../concurrent.managed.h"

namespace protocol
{
	class Flow;

	/**
	 * Classe que trata o fechamento de um fluxo de mensagens.
	 */
	class FlowClosedCallback :
		public virtual base::Object
	{
		public:
			/* destrutor virtual para permitir herança. */
			virtual ~FlowClosedCallback();

			/* trata o fechamento do fluxo de mensagens. */
			virtual void onFlowClosed(_strong(Flow)& flow) = 0;
	};
}

#endif /* PROTOCOL_FLOWCLOSEDCALLBACK_H_ */
