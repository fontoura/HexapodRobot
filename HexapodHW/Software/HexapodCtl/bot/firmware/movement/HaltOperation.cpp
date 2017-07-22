/*
 * HaltOperation.cpp
 *
 *  Created on: 28/03/2013
 */

#include "../fw_defines.h"
#include "./HaltOperation.h"
#include "../MovementManager.h"

using namespace base;

/* macros para debug */
#ifdef DEBUG_bot_firmware_movement_HaltOperation
#include <iostream>
#define DEBUG(v1) std::cout<<(v1)<<std::endl
#define DEBUG2(v1,v2) std::cout<<(v1)<<(v2)<<std::endl
#define DEBUG3(v1,v2,v3) std::cout<<(v1)<<(v2)<<(v3)<<std::endl
#define DEBUG4(v1,v2,v3,v4) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<std::endl
#define DEBUG5(v1,v2,v3,v4,v5) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<(v5)<<std::endl
#else /* ifndef DEBUG_bot_firmware_movement_HaltOperation */
#define DEBUG(v1) {}
#define DEBUG2(v1,v2) {}
#define DEBUG3(v1,v2,v3) {}
#define DEBUG4(v1,v2,v3,v4) {}
#define DEBUG5(v1,v2,v3,v4,v5) {}
#endif /* DEBUG_bot_firmware_movement_HaltOperation */

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			/* pool de objetos. */
			_pool_inst(HaltOperation, 1)

			/* construtor e destrutor. */
			HaltOperation::HaltOperation()
			{
				DEBUG("HaltOperation alocado!");
			}

			HaltOperation::~HaltOperation()
			{
				DEBUG("HaltOperation apagado!");
			}

			/* gerência de memória. */
			void HaltOperation::initialize()
			{
				DEBUG("Inicializando HaltOperation...");
			}

			void HaltOperation::finalize()
			{
				DEBUG("Finalizando HaltOperation...");
				_del_inst(HaltOperation);
			}

			/* factory. */
			HaltOperation* HaltOperation::create()
			{
				DEBUG("Criando HaltOperation...");
				_new_inst(HaltOperation, halt);
				halt->initialize();
				return halt;
			}

			/* implementação de MovementOperation. */
			int HaltOperation::getLength()
			{
				return 1;
			}

			/* implementação de MovementOperation. */
			int HaltOperation::getValue()
			{
				return 1;
			}

			/* implementação de MovementOperation. */
			void HaltOperation::run(int id, _strong(MovementManager)& manager)
			{
			}
		}
	}
}
