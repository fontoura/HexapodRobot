/*
 * movements.h
 *
 *  Created on: 09/09/2013
 */

#ifndef MOVEMENTS_H_
#define MOVEMENTS_H_

#include "../../../concurrent/managed/all.h"

namespace drivers
{
	class InterpolationDriver;
}

namespace bot
{
	namespace firmware
	{
		class MovementManager;
		class SensorsManager;
	}
}

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			/**
			 * Move o robô para a posição de descanso pela primeira vez.
			 * @param driver Driver utilizado para a movimentação.
			 */
			void initPosition(drivers::InterpolationDriver* driver);

			/**
			 * Move o robô para a posição de descanso.
			 * @param driver Driver utilizado para a movimentação.
			 */
			void restPosition(drivers::InterpolationDriver* driver);

			/**
			 * Faz o robô andar em linha reta no eixo Y (para a frente ou para trás).
			 * @param driver Driver utilizado para a movimentação.
			 * @param manager Gerente de movimentos do robô.
			 * @param sensors Gerente de sensores do robô.
			 * @param id Identificador do movimento.
			 * @param steps Total de passos realizados até o movimento terminar.
			 * @param totalSteps Total de passos do movimento.
			 * @param targetAngle Ângulo de destino do movimento.
			 * @param isBackward Indica se o movimento é para trás.
			 * @param isAligned Indica se o movimento é alinhado.
			 */
			void walkAlongY(drivers::InterpolationDriver* driver, MovementManager* manager, SensorsManager* sensors, int id, int& steps, int totalSteps, int targetAngle, bool isBackward, bool isAligned);

			/**
			 * Faz o robô andar em linha reta no eixo X (para a direita ou para a esquerda).
			 * @param driver Driver utilizado para a movimentação.
			 * @param manager Gerente de movimentos do robô.
			 * @param sensors Gerente de sensores do robô.
			 * @param id Identificador do movimento.
			 * @param steps Total de passos realizados até o movimento terminar.
			 * @param totalSteps Total de passos do movimento.
			 * @param isLeftToRight Indica se o movimento é para a direita.
			 */
			void walkAlongX(drivers::InterpolationDriver* driver, MovementManager* manager, SensorsManager* sensors, int id, int& steps, int totalSteps, bool isLeftToRight);

			/**
			 * Faz o robô girar no próprio eixo em torno do eixo Z (sobre o chão) para ajustar.
			 * @param driver Driver utilizado para a movimentação.
			 * @param manager Gerente de movimentos do robô.
			 * @param sensors Gerente de sensores do robô.
			 * @param id Identificador do movimento.
			 * @param steps Total de passos realizados até o movimento terminar.
			 * @param totalSteps Total de passos do movimento.
			 */
			void rotateToAdjust(drivers::InterpolationDriver* driver, MovementManager* manager, SensorsManager* sensors, int id, int& steps, int totalSteps);

			/**
			 * Faz o robô girar no próprio eixo em torno do eixo Z (sobre o chão).
			 * @param driver Driver utilizado para a movimentação.
			 * @param manager Gerente de movimentos do robô.
			 * @param sensors Gerente de sensores do robô.
			 * @param id Identificador do movimento.
			 * @param currentAngle Ângulo atual do movimento.
			 * @param targetAngle Ângulo absoluto de destino.
			 */
			void rotateArroundZ(drivers::InterpolationDriver* driver, MovementManager* manager, SensorsManager* sensors, int id, int &currentAngle, int targetAngle);

			void pushUp(drivers::InterpolationDriver* driver, MovementManager* manager, SensorsManager* sensors, int id, int& pushUps, int totalPushUps);
			void hulaHoop(drivers::InterpolationDriver* driver, MovementManager* manager, SensorsManager* sensors, int id, int& cycles, int totalCycles);
		}
	}
}

#endif /* MOVEMENTS_H_ */
