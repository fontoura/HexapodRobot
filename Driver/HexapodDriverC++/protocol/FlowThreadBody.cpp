/*
 * FlowThreadBody.cpp
 *
 *  Created on: 08/12/2012
 */

#include "../protocol/FlowThreadBody.h"
#include "../protocol/Flow.h"
#include "../protocol/MessageNode.h"
#include "../concurrent.semaphore.h"
#include "../concurrent.time.h"

using namespace concurrent::thread;

namespace protocol
{
	_pool_inst(FlowThreadBody, _POOL_SIZE_FOR_FLOWS)

	/* construtor e destrutor. */
	FlowThreadBody::FlowThreadBody()
	{
	}

	FlowThreadBody::~FlowThreadBody()
	{
	}

	/* gerência de memória. */
	void FlowThreadBody::initialize(Flow* flow)
	{
		m_flow = flow;
	}

	void FlowThreadBody::finalize()
	{
		m_flow = NULL;
		_del_inst(FlowThreadBody);
	}

	/* factory. */
	FlowThreadBody* FlowThreadBody::create(Flow* flow)
	{
		_new_inst(FlowThreadBody, body);
		body->initialize(flow);
		return body;
	}

	/* implementação de ThreadBody. */
	void FlowThreadBody::run()
	{
		m_flow->receive();
		m_flow = NULL;
	}
}
