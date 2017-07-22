/*
 * MovementManager.cpp
 *
 *  Created on: 28/03/2013
 */

#include "../../bot/firmware/fw_defines.h"
#include "../../bot/firmware/RobotManager.h"
#include "../../bot/firmware/UartManager.h"
#include "../../bot/firmware/MovementManager.h"
#include "../../bot/firmware/MovementOperation.h"
#include "../../bot/firmware/MagnetometerAdjuster.h"
#include "../../bot/firmware/movement/HaltOperation.h"
#include "../../bot/firmware/movement/AdjustOperation.h"
#include "../../bot/firmware/movement/fw_native.h"

using namespace base;
using namespace bot::firmware::movement;
using namespace concurrent::managed;
using namespace concurrent::semaphore;
using namespace concurrent::thread;

/* macros para debug */
#ifdef DEBUG_bot_firmware_MovementManager
#include <iostream>
#define DEBUG(v1) std::cout<<(v1)<<std::endl
#define DEBUG2(v1,v2) std::cout<<(v1)<<(v2)<<std::endl
#define DEBUG3(v1,v2,v3) std::cout<<(v1)<<(v2)<<(v3)<<std::endl
#define DEBUG4(v1,v2,v3,v4) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<std::endl
#define DEBUG5(v1,v2,v3,v4,v5) std::cout<<(v1)<<(v2)<<(v3)<<(v4)<<(v5)<<std::endl
#else /* ifndef DEBUG_bot_firmware_MovementManager */
#define DEBUG(v1) {}
#define DEBUG2(v1,v2) {}
#define DEBUG3(v1,v2,v3) {}
#define DEBUG4(v1,v2,v3,v4) {}
#define DEBUG5(v1,v2,v3,v4,v5) {}
#endif /* DEBUG_bot_firmware_MovementManager */

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			void initPosition(bot::firmware::LegPositions& position);
		}

		/* pool de objetos. */
		ObjectPool<MovementManager, 1> MovementManager::m_pool;

		/* construtor e destrutor. */
		MovementManager::MovementManager()
		{
			DEBUG("MovementManager alocado!");
			m_currentId = 0;
		}

		MovementManager::~MovementManager()
		{
			m_currentOperation = NULL;
			m_nextOperation = NULL;
			DEBUG("MovementManager apagado!");
		}

		/* gerência de memória. */
		void MovementManager::initialize(_strong(RobotManager)& robot)
		{
			DEBUG("Inicializando MovementManager...");
			m_mutex = Semaphore::create(1, 1);
			initPosition(m_legs);
			m_currentId = 0;
			m_robot = robot;
			m_halt = HaltOperation::create();
		}

		void MovementManager::finalize()
		{
			DEBUG("Finalizando MovementManager...");
			m_mutex = NULL;
			m_robot = NULL;
			m_currentOperation = NULL;
			m_nextOperation = NULL;
			m_halt = NULL;
			Object::beforeRecycle();
			MovementManager::m_pool.recycle(this);
		}

		/* factory. */
		MovementManager* MovementManager::create(_strong(RobotManager)& robot)
		{
			DEBUG("Criando MovementManager...");
			MovementManager* manager = MovementManager::m_pool.obtain();
			if (manager != NULL)
			{
				manager->initialize(robot);
			}
			return manager;
		}

		/* implementação de ThreadBody. */
		void MovementManager::run()
		{
			DEBUG("Iniciou a thread do MovementManager");
			while (true)
			{
				if (m_currentOperation != NULL)
				{
					DEBUG("MovementManager vai iniciar um movimento.");

					// executa o movimento atual.
					_strong(MovementManager)_this = this;
					m_currentOperation->run(m_currentId, m_legs, _this);
					if (m_isAdjusting)
					{
						DEBUG("MovementManager terminou o ajuste.");
						m_adjusterObject->stop();
						Thread::sleep(10);
						m_adjusterThread = NULL;
						m_adjusterObject = NULL;
					}

					// verifica se o movimento foi abortado.
					bool ok = true;
					m_mutex->down();
					if (m_nextOperation != NULL)
					{
						ok = false;
					}
					m_mutex->up();
					if (ok)
					{
						DEBUG("MovementManager terminou com sucesso um movimento.");
						m_robot->getUartManager()->sendMovementFinishedNotification(m_currentOperation);
					}
					else
					{
						DEBUG("MovementManager abortou um movimento.");
						m_robot->getUartManager()->sendMovementAbortedNotification(m_currentOperation);
					}

					// vai para o movimento seguinte.
					m_mutex->down();
					if (m_nextOperation == m_halt)
					{
						m_nextOperation = NULL;
					}
					if (m_nextOperation != NULL)
					{
						m_isAdjusting = m_willAdjust;
						m_willAdjust = false;
						m_currentOperation = m_nextOperation;
						m_nextOperation = NULL;
						if (m_isAdjusting)
						{
							DEBUG("MovementManager começou o ajuste.");
							m_adjusterObject = MagnetometerAdjuster::create(this->getSensors());
							m_adjusterThread = m_adjusterObject->start();
						}
					}
					else
					{
						m_currentOperation = NULL;
					}
					m_currentId ++;
					m_mutex->up();
				}
				else
				{
					concurrent::thread::Thread::sleep(5);

					// faz a transição para movimento, se for o caso.
					m_mutex->down();
					if (m_nextOperation == m_halt)
					{
						m_nextOperation = NULL;
					}
					if (m_nextOperation != NULL)
					{
						m_isAdjusting = m_willAdjust;
						m_willAdjust = false;
						m_currentOperation = m_nextOperation;
						m_nextOperation = NULL;
						if (m_isAdjusting)
						{
							DEBUG("MovementManager começou o ajuste.");
							m_adjusterObject = MagnetometerAdjuster::create(this->getSensors());
							m_adjusterThread = m_adjusterObject->start();
						}
					}
					m_mutex->up();
				}
			}
		}

		/* inicia a thread de movimentação. */
		void MovementManager::start()
		{
			_strong(Thread) thread = Thread::create(this);
			thread->setPriority(LowThreadPriority);
			thread->start();
		}

		/* para a operação de movimentação atual. */
		void MovementManager::halt()
		{
			DEBUG("MovementManager esta parando...");
			this->move(m_halt);
		}

		/* inicia uma operação de movimentação, abortando a atual. */
		void MovementManager::move(_strong(MovementOperation)operation)
		{
			DEBUG("MovementManager esta iniciando operacao...");
			m_mutex->down();
			m_nextOperation = operation;
			m_willAdjust = false;
			m_mutex->up();
		}

		/* inicia uma operação de ajuste, abortando a atual. */
		void MovementManager::adjust(int label)
		{
			m_mutex->down();
			DEBUG("MovementManager esta iniciando ajuste...");
			m_nextOperation = AdjustOperation::create();
			m_nextOperation->setLabel(label);
			m_willAdjust = true;
			m_mutex->up();
		}

		/* verifica se a operação de movimento com certo identificador deve parar. */
		bool MovementManager::shouldStop(int movementId)
		{
			bool result = false;
			m_mutex->down();
			if (m_nextOperation != NULL)
			{
				result = true;
			}
			m_mutex->up();
			return result;
		}

		/* verifica se está em movimento. */
		bool MovementManager::isMoving()
		{
			bool result = false;
			m_mutex->down();
			if ((m_nextOperation != m_halt) && (m_currentOperation != NULL || m_nextOperation != NULL))
			{
				result = true;
			}
			m_mutex->up();
			return result;
		}

		_strong(SensorsManager)& MovementManager::getSensors()
		{
			return m_robot->getSensorsManager();
		}
	}
}
