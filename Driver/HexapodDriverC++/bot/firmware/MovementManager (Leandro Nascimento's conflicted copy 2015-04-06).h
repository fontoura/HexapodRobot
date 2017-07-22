/*
 * MovementManager.h
 *
 *  Created on: 28/03/2013
 */

#ifndef BOT_FIRMWARE_MOVEMENTMANAGER_H_
#define BOT_FIRMWARE_MOVEMENTMANAGER_H_

#include "../../globaldefs.h"
#include "../../base.h"
#include "../../concurrent.managed.h"
#include "../../concurrent.thread.h"
#include "../../concurrent.semaphore.h"
#include "../../bot/firmware/LegPositions.h"

namespace bot
{
	namespace firmware
	{
		class RobotManager;
		class SensorsManager;
		class MovementOperation;
		class MagnetometerAdjuster;

		/**
		 * Classe que gerencia o movimento do robô.
		 */
		class MovementManager :
			public virtual concurrent::thread::ThreadBody
		{
			private:
				/* pool de objetos. */
				friend class base::ObjectPool<MovementManager, 1>;
				static base::ObjectPool<MovementManager, 1> m_pool;

			protected:
				/* construtor e destrutor. */
				MovementManager();
				~MovementManager();

				/* gerência de memória. */
				void initialize(_strong(RobotManager)& robot);
				void finalize();

			public:
				/* factory. */
				static MovementManager* create(_strong(RobotManager)& robot);

			protected:
				/* identificador da operação de movimentação em andamento. */
				int m_currentId;

				/* posição das patas. */
				LegPositions m_legs;

				/* flag que indica se o gerente de movimento está ajustando. */
				bool m_isAdjusting;

				/* flag que indica se a próxima operação é de ajustar. */
				bool m_willAdjust;

				/* operação de movimentação referente a parar. */
				_strong(MovementOperation) m_halt;

				/* mutex de controle da transição de movimento. */
				_strong(concurrent::semaphore::Semaphore) m_mutex;

				/* gerente do robô. */
				_strong(RobotManager) m_robot;

				/* operação de movimentação em andamento. */
				_strong(MovementOperation) m_currentOperation;

				/* operação de movimentação a executar em seguida. */
				_strong(MovementOperation) m_nextOperation;

				/* objetos utilizados para o ajuste. */
				_strong(MagnetometerAdjuster) m_adjusterObject;
				_strong(concurrent::thread::Thread) m_adjusterThread;

				/* implementação de ThreadBody. */
				void run();

			public:
				/* inicia a thread de movimentação. */
				void start();

				/* para a operação de movimentação atual. */
				void halt();

				/* inicia uma operação de movimentação, abortando a atual. */
				void move(_strong(MovementOperation) operation);

				/* inicia uma operação de ajuste, abortando a atual. */
				void adjust(int label);

				/* verifica se a operação de movimento com certo identificador deve parar. */
				bool shouldStop(int movementId);

				/* verifica se está em movimento. */
				bool isMoving();

				/* obtém um objeto utilizado para leitura dos sensores. */
				_strong(SensorsManager)& getSensors();
		};
	}
}

#endif /* BOT_FIRMWARE_MOVEMENTMANAGER_H_ */
