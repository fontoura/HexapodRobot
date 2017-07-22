/*
 * FlowThreadBody.h
 *
 *  Created on: 08/12/2012
 */

#ifndef PROTOCOL_FLOWTHREADBODY_H_
#define PROTOCOL_FLOWTHREADBODY_H_

#include "../globaldefs.h"
#include "../base/all.h"
#include "../concurrent/managed/all.h"
#include "../concurrent.thread.h"

namespace protocol
{
	class Flow;

	/**
	 * Classe com o corpo de thread de verificação de timeout do fluxo de mensagens.
	 */
	class FlowThreadBody :
		public virtual concurrent::thread::ThreadBody
	{
		_pool_decl(FlowThreadBody, _POOL_SIZE_FOR_FLOWS)

		protected:
			/* construtor e destrutor. */
			FlowThreadBody();
			~FlowThreadBody();

			/* gerência de memória. */
			void initialize(Flow* flow);
			void finalize();

		public:
			/* factory. */
			static FlowThreadBody* create(Flow* flow);

		protected:
			/* fluxo ao qual esta thread se refere. */
			_strong(Flow) m_flow;

		public:
			/* implementação de ThreadBody. */
			void run();
	};
}

#endif /* PROTOCOL_FLOWTHREADBODY_H_ */
