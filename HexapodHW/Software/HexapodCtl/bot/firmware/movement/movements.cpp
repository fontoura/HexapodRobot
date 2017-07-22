/*
 * movements.cpp
 *
 *  Created on: 09/09/2013
 */

#include "./movements.h"

#include <math.h>
#include "../../../utils.h"

#include "../../../concurrent/managed/all.h"
#include "../../../drivers/InterpolationDriver.h"
#include "../MovementManager.h"
#include "../SensorsManager.h"

using namespace drivers;

namespace bot
{
	namespace firmware
	{
		namespace movement
		{
			// posições de descanso do robô.
			int x_base = 70;
			int y_base = 30;
			int z_base = 60;

			// posições de descanso reduzidas do robô.
			int x_base_small = 60;
			int y_base_small = 15;

			// deltas utilizados no movimento de andar.
			int walk_delta_x = 25;
			int walk_delta_y = 25;
			int walk_delta_z = 10;

			// deltas utilizados no movimento de rotacionar.
			int rotate_delta_z = 15;
			int rotate_delta_y = 40;

/* -------------------- MOVIMENTOS PARA ATINGIR POSIÇÕES DE DESCANSO -------------------- */

			void initPosition(InterpolationDriver* driver)
			{
				driver->setPosition(0, x_base, y_base, z_base);
				driver->setPosition(1, x_base, 0, z_base);
				driver->setPosition(2, x_base, -y_base, z_base);
				driver->setPosition(3, -x_base, -y_base, z_base);
				driver->setPosition(4, -x_base, 0, z_base);
				driver->setPosition(5, -x_base, y_base, z_base);
				driver->move(0, 0);
			}

			void restPosition(InterpolationDriver* driver)
			{
				const int delay = (int)10e3;
				const int numInterpol = 50;
				driver->setPosition(0, x_base, y_base, z_base);
				driver->setPosition(1, x_base, 0, z_base);
				driver->setPosition(2, x_base, -y_base, z_base);
				driver->setPosition(3, -x_base, -y_base, z_base);
				driver->setPosition(4, -x_base, 0, z_base);
				driver->setPosition(5, -x_base, y_base, z_base);
				driver->move(delay, numInterpol);
			}

/* -------------------- MOVIMENTOS DE ANDAR EM LINHA RETA -------------------- */

			void walkAlongY(InterpolationDriver* driver, MovementManager* manager, SensorsManager* sensors, int id, int& steps, int totalSteps, int targetAngle, bool isBackward, bool isAligned)
			{
				// constantes de interpolação.
				const int delay = (int)10e3;
				const int numInterpol = 50;

				// constantes de movimento.
				const int delta_y = walk_delta_x;
				const int delta_z = walk_delta_z;

				// variáveis de ajuste do alinhamento.
				int offset_l = 0;
				int offset_r = 0;
				int alpha = 0;
				int beta = 0;

				// prepara-se para andar.
				if (!isBackward)
				{
					driver->setPosition(0, x_base, y_base, z_base);
					driver->setPosition(1, x_base, delta_y, z_base - delta_z);
					driver->setPosition(2, x_base, -y_base, z_base);
					driver->setPosition(3, -x_base, -y_base, z_base);
					driver->setPosition(4, -x_base, 0, z_base);
					driver->setPosition(5, -x_base, y_base + delta_y, z_base - delta_z);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_base, y_base, z_base);
					driver->setPosition(1, x_base, delta_y, z_base);
					driver->setPosition(2, x_base, -y_base, z_base);
					driver->setPosition(3, -x_base, -y_base, z_base);
					driver->setPosition(4, -x_base, 0, z_base);
					driver->setPosition(5, -x_base, y_base + delta_y, z_base);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_base, y_base, z_base - delta_z);
					driver->setPosition(1, x_base, delta_y, z_base);
					driver->setPosition(2, x_base, -y_base - delta_y, z_base - delta_z);
					driver->setPosition(3, -x_base, -y_base, z_base);
					driver->setPosition(4, -x_base, -delta_y, z_base - delta_z);
					driver->setPosition(5, -x_base, y_base + delta_y, z_base);
					driver->move(delay, numInterpol);
				}
				else
				{
					driver->setPosition(0, x_base, y_base, z_base);
					driver->setPosition(1, x_base, 0, z_base);
					driver->setPosition(2, x_base, -y_base - delta_y, z_base - delta_z);
					driver->setPosition(3, -x_base, -y_base, z_base);
					driver->setPosition(4, -x_base, -delta_y, z_base - delta_z);
					driver->setPosition(5, -x_base, y_base, z_base);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_base, y_base, z_base);
					driver->setPosition(1, x_base, 0, z_base);
					driver->setPosition(2, x_base, -y_base - delta_y, z_base);
					driver->setPosition(3, -x_base, -y_base, z_base);
					driver->setPosition(4, -x_base, -delta_y, z_base);
					driver->setPosition(5, -x_base, y_base, z_base);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_base, y_base, z_base);
					driver->setPosition(1, x_base, delta_y, z_base - delta_z);
					driver->setPosition(2, x_base, -y_base - delta_y, z_base);
					driver->setPosition(3, -x_base, -y_base, z_base - delta_z);
					driver->setPosition(4, -x_base, -delta_y, z_base);
					driver->setPosition(5, -x_base, y_base + delta_y, z_base - delta_z);
					driver->move(delay, numInterpol);
				}

				// anda.
				for (steps = 0; steps < totalSteps; steps ++)
				{

					// se está andando alinhado, calcula os fatores de ajuste.
					if (isAligned)
					{
						MagnetometerData data;
						sensors->readMagnetometer(data);

						alpha = targetAngle - (int)data.heading;
						beta = 45 - alpha;

						if(alpha > 0)
						{
							offset_l = 0;
							offset_r = (int)(delta_y*(1.0 - 1.0/tan(deg_to_rad(beta))));

						}
						else if(alpha < 0)
						{
							offset_r = 0;
							offset_l = (int)(delta_y*(1.0 - tan(deg_to_rad(beta))));
						}
						else
						{
							offset_l = 0;
							offset_r = 0;
						}

						if(offset_l > delta_y)
						{
							offset_l = delta_y;
						}
						if(offset_r > delta_y)
						{
							offset_r = delta_y;
						}
					}

					// anda um passo.
					if (!isBackward)
					{
						driver->setPosition(0, x_base, y_base + delta_y, z_base - delta_z);
						driver->setPosition(1, x_base, -delta_y + offset_r, z_base);
						driver->setPosition(2, x_base, -y_base, z_base - delta_z);
						driver->setPosition(3, -x_base, -y_base - delta_y, z_base);
						driver->setPosition(4, -x_base, delta_y, z_base - delta_z);
						driver->setPosition(5, -x_base, y_base, z_base);
						driver->move(delay, numInterpol);

						driver->setPosition(0, x_base, y_base + delta_y, z_base);
						driver->setPosition(1, x_base, -delta_y + offset_r, z_base - delta_z);
						driver->setPosition(2, x_base, -y_base, z_base);
						driver->setPosition(3, -x_base, -y_base - delta_y, z_base - delta_z);
						driver->setPosition(4, -x_base, delta_y, z_base);
						driver->setPosition(5, -x_base, y_base, z_base - delta_z);
						driver->move(delay, numInterpol);

						driver->setPosition(0, x_base, y_base, z_base);
						driver->setPosition(1, x_base, delta_y, z_base - delta_z);
						driver->setPosition(2, x_base, -y_base - delta_y, z_base);
						driver->setPosition(3, -x_base, -y_base, z_base - delta_z);
						driver->setPosition(4, -x_base, -delta_y + offset_l, z_base);
						driver->setPosition(5, -x_base, y_base + delta_y, z_base - delta_z);
						driver->move(delay, numInterpol);

						driver->setPosition(0, x_base, y_base, z_base - delta_z);
						driver->setPosition(1, x_base, delta_y, z_base);
						driver->setPosition(2, x_base, -y_base - delta_y, z_base - delta_z);
						driver->setPosition(3, -x_base, -y_base, z_base);
						driver->setPosition(4, -x_base, -delta_y + offset_l, z_base - delta_z);
						driver->setPosition(5, -x_base, y_base + delta_y, z_base);
						driver->move(delay, numInterpol);
					}
					else
					{
						driver->setPosition(0, x_base, y_base + delta_y - offset_r, z_base);
						driver->setPosition(1, x_base, -delta_y, z_base - delta_z);
						driver->setPosition(2, x_base, -y_base, z_base);
						driver->setPosition(3, -x_base, -y_base - delta_y + offset_l, z_base - delta_z);
						driver->setPosition(4, -x_base, delta_y, z_base);
						driver->setPosition(5, -x_base, y_base, z_base - delta_z);
						driver->move(delay, numInterpol);

						driver->setPosition(0, x_base, y_base + delta_y - offset_r, z_base - delta_z);
						driver->setPosition(1, x_base, -delta_y, z_base);
						driver->setPosition(2, x_base, -y_base, z_base - delta_z);
						driver->setPosition(3, -x_base, -y_base - delta_y + offset_l, z_base);
						driver->setPosition(4, -x_base, delta_y, z_base - delta_z);
						driver->setPosition(5, -x_base, y_base, z_base);
						driver->move(delay, numInterpol);

						driver->setPosition(0, x_base, y_base, z_base - delta_z);
						driver->setPosition(1, x_base, delta_y, z_base);
						driver->setPosition(2, x_base, -y_base - delta_y + offset_r, z_base - delta_z);
						driver->setPosition(3, -x_base, -y_base, z_base);
						driver->setPosition(4, -x_base, -delta_y, z_base - delta_z);
						driver->setPosition(5, -x_base, y_base + delta_y - offset_l, z_base);
						driver->move(delay, numInterpol);

						driver->setPosition(0, x_base, y_base, z_base);
						driver->setPosition(1, x_base, delta_y, z_base - delta_z);
						driver->setPosition(2, x_base, -y_base - delta_y + offset_r, z_base);
						driver->setPosition(3, -x_base, -y_base, z_base - delta_z);
						driver->setPosition(4, -x_base, -delta_y, z_base);
						driver->setPosition(5, -x_base, y_base + delta_y - offset_l, z_base - delta_z);
						driver->move(delay, numInterpol);
					}

					// verifica se deve parar.
					if (manager->shouldStop(id))
					{
						break;
					}

					// atualiza a leitura dos sensores.
					sensors->refresh();
				}

				// volta para a posição convencional.
				if (!isBackward)
				{
					driver->setPosition(0, x_base, y_base, z_base - delta_z);
					driver->setPosition(1, x_base, delta_y, z_base);
					driver->setPosition(2, x_base, -y_base, z_base - delta_z);
					driver->setPosition(3, -x_base, -y_base, z_base);
					driver->setPosition(4, -x_base, 0, z_base - delta_z);
					driver->setPosition(5, -x_base, y_base + delta_y, z_base);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_base, y_base, z_base);
					driver->setPosition(1, x_base, delta_y, z_base);
					driver->setPosition(2, x_base, -y_base, z_base);
					driver->setPosition(3, -x_base, -y_base, z_base);
					driver->setPosition(4, -x_base, 0, z_base);
					driver->setPosition(5, -x_base, y_base + delta_y, z_base);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_base, y_base, z_base);
					driver->setPosition(1, x_base, 0, z_base - delta_z);
					driver->setPosition(2, x_base, -y_base, z_base);
					driver->setPosition(3, -x_base, -y_base, z_base - delta_z);
					driver->setPosition(4, -x_base, 0, z_base);
					driver->setPosition(5, -x_base, y_base, z_base - delta_z);
					driver->move(delay, numInterpol);
				}
				else
				{
					driver->setPosition(0, x_base, y_base, z_base);
					driver->setPosition(1, x_base, 0, z_base - delta_z);
					driver->setPosition(2, x_base, -y_base - delta_y, z_base);
					driver->setPosition(3, -x_base, -y_base, z_base - delta_z);
					driver->setPosition(4, -x_base, -delta_y, z_base);
					driver->setPosition(5, -x_base, y_base, z_base - delta_z);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_base, y_base, z_base);
					driver->setPosition(1, x_base, 0, z_base);
					driver->setPosition(2, x_base, -y_base - delta_y, z_base);
					driver->setPosition(3, -x_base, -y_base, z_base);
					driver->setPosition(4, -x_base, -delta_y, z_base);
					driver->setPosition(5, -x_base, y_base, z_base);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_base, y_base, z_base - delta_z);
					driver->setPosition(1, x_base, 0, z_base);
					driver->setPosition(2, x_base, -y_base, z_base - delta_z);
					driver->setPosition(3, -x_base, -y_base, z_base);
					driver->setPosition(4, -x_base, 0, z_base - delta_z);
					driver->setPosition(5, -x_base, y_base, z_base);
					driver->move(delay, numInterpol);
				}
			}

			void walkAlongX(drivers::InterpolationDriver* driver, MovementManager* manager, SensorsManager* sensors, int id, int& steps, int totalSteps, bool isLeftToRight)
			{
				// constantes de interpolação.
				const int delay = (int)10e3;
				const int numInterpol = 50;

				// constantes de movimento.
				const int y_small = y_base_small;
				const int delta_x = walk_delta_y;
				const int delta_z = walk_delta_z;

				// prepara-se para andar.
				if (isLeftToRight)
				{
					driver->setPosition(0, x_base + delta_x, y_small, z_base - delta_z);
					driver->setPosition(1, x_base, 0, z_base);
					driver->setPosition(2, x_base + delta_x, -y_small, z_base - delta_z);
					driver->setPosition(3, -x_base, -y_base, z_base);
					driver->setPosition(4, -x_base, 0, z_base);
					driver->setPosition(5, -x_base, y_base, z_base);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_base + delta_x, y_small, z_base);
					driver->setPosition(1, x_base, 0, z_base);
					driver->setPosition(2, x_base + delta_x, -y_small, z_base);
					driver->setPosition(3, -x_base, -y_base, z_base);
					driver->setPosition(4, -x_base, 0, z_base);
					driver->setPosition(5, -x_base, y_base, z_base);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_base + delta_x, y_small, z_base);
					driver->setPosition(1, x_base, 0, z_base - delta_z);
					driver->setPosition(2, x_base + delta_x, -y_small, z_base);
					driver->setPosition(3, -x_base - delta_x, -y_small, z_base - delta_z);
					driver->setPosition(4, -x_base, 0, z_base);
					driver->setPosition(5, -x_base - delta_x, y_small, z_base - delta_z);
					driver->move(delay, numInterpol);
				}
				else
				{
					driver->setPosition(0, x_base, y_base, z_base);
					driver->setPosition(1, x_base, 0, z_base);
					driver->setPosition(2, x_base, -y_base, z_base);
					driver->setPosition(3, -x_base - delta_x, -y_small, z_base - delta_z);
					driver->setPosition(4, -x_base, 0, z_base);
					driver->setPosition(5, -x_base - delta_x, y_small, z_base - delta_z);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_base, y_base, z_base);
					driver->setPosition(1, x_base, 0, z_base);
					driver->setPosition(2, x_base, -y_base, z_base);
					driver->setPosition(3, -x_base - delta_x, -y_small, z_base);
					driver->setPosition(4, -x_base, 0, z_base);
					driver->setPosition(5, -x_base - delta_x, y_small, z_base);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_base + delta_x, y_small, z_base - delta_z);
					driver->setPosition(1, x_base, 0, z_base);
					driver->setPosition(2, x_base + delta_x, -y_small, z_base - delta_z);
					driver->setPosition(3, -x_base - delta_x, -y_small, z_base);
					driver->setPosition(4, -x_base, 0, z_base - delta_z);
					driver->setPosition(5, -x_base - delta_x, y_small, z_base);
					driver->move(delay, numInterpol);
				}

				// anda.
				for (steps = 0; steps < totalSteps; steps ++)
				{
					// anda um passo.
					if (isLeftToRight)
					{
						//O conjunto 0/2/4 vai do chao pra esquerda e o 1/3/5 do ar pra direita
						driver->setPosition(0, x_base, y_small, z_base);
						driver->setPosition(1, x_base + delta_x, 0, z_base - delta_z);
						driver->setPosition(2, x_base, -y_small, z_base);
						driver->setPosition(3, -x_base, -y_small, z_base - delta_z);
						driver->setPosition(4, -x_base - delta_x, 0, z_base);
						driver->setPosition(5, -x_base, y_small, z_base  - delta_z);
						driver->move(delay, numInterpol);

						//O conjunto 0/2/4 vai pro ar e o 1/3/5 vai pro chao
						driver->setPosition(0, x_base, y_small, z_base - delta_z);
						driver->setPosition(1, x_base + delta_x, 0, z_base);
						driver->setPosition(2, x_base, -y_small, z_base - delta_z);
						driver->setPosition(3, -x_base, -y_small, z_base);
						driver->setPosition(4, -x_base - delta_x, 0, z_base - delta_z);
						driver->setPosition(5, -x_base, y_small, z_base);
						driver->move(delay, numInterpol);

						//O conjunto 0/2/4 vai do ar pra direita e o 1/3/5 vai do chao pra esquerda
						driver->setPosition(0, x_base + delta_x, y_small, z_base - delta_z);
						driver->setPosition(1, x_base, 0, z_base);
						driver->setPosition(2, x_base + delta_x, -y_small, z_base - delta_z);
						driver->setPosition(3, -x_base - delta_x, -y_small, z_base);
						driver->setPosition(4, -x_base, 0, z_base - delta_z);
						driver->setPosition(5, -x_base - delta_x, y_small, z_base);
						driver->move(delay, numInterpol);

						//O conjunto 0/2/4 vai pro chao e o 1/3/5 vai pro ar
						driver->setPosition(0, x_base + delta_x, y_small, z_base);
						driver->setPosition(1, x_base, 0, z_base - delta_z);
						driver->setPosition(2, x_base + delta_x, -y_small, z_base);
						driver->setPosition(3, -x_base - delta_x, -y_small, z_base - delta_z);
						driver->setPosition(4, -x_base, 0, z_base);
						driver->setPosition(5, -x_base - delta_x, y_small, z_base - delta_z);
						driver->move(delay, numInterpol);
					}
					else
					{
						//O conjunto 0/2/4 vai do ar pra esquerda e o 1/3/5 do chao pra direita
						driver->setPosition(0, x_base, y_small, z_base - delta_z);
						driver->setPosition(1, x_base + delta_x, 0, z_base);
						driver->setPosition(2, x_base, -y_small, z_base - delta_z);
						driver->setPosition(3, -x_base, -y_small, z_base);
						driver->setPosition(4, -x_base - delta_x, 0, z_base - delta_z);
						driver->setPosition(5, -x_base, y_small, z_base);
						driver->move(delay, numInterpol);

						//O conjunto 0/2/4 vai pro chao e o 1/3/5 vai pro ar
						driver->setPosition(0, x_base, y_small, z_base);
						driver->setPosition(1, x_base + delta_x, 0, z_base - delta_z);
						driver->setPosition(2, x_base, -y_small, z_base);
						driver->setPosition(3, -x_base, -y_small, z_base - delta_z);
						driver->setPosition(4, -x_base - delta_x, 0, z_base);
						driver->setPosition(5, -x_base, y_small, z_base - delta_z);
						driver->move(delay, numInterpol);

						//O conjunto 0/2/4 vai do chao pra direita e o 1/3/5 vai do chao pra esquerda
						driver->setPosition(0, x_base + delta_x, y_small, z_base);
						driver->setPosition(1, x_base, 0, z_base - delta_z);
						driver->setPosition(2, x_base + delta_x, -y_small, z_base);
						driver->setPosition(3, -x_base - delta_x, -y_small, z_base - delta_z);
						driver->setPosition(4, -x_base, 0, z_base);
						driver->setPosition(5, -x_base - delta_x, y_small, z_base - delta_z);
						driver->move(delay, numInterpol);

						//O conjunto 0/2/4 vai pro ar e o 1/3/5 vai pro chao
						driver->setPosition(0, x_base + delta_x, y_small, z_base - delta_z);
						driver->setPosition(1, x_base, 0, z_base);
						driver->setPosition(2, x_base + delta_x, -y_small, z_base - delta_z);
						driver->setPosition(3, -x_base - delta_x, -y_small, z_base);
						driver->setPosition(4, -x_base, 0, z_base - delta_z);
						driver->setPosition(5, -x_base - delta_x, y_small, z_base);
						driver->move(delay, numInterpol);
					}

					// verifica se deve parar.
					if (manager->shouldStop(id))
					{
						break;
					}

					// atualiza a leitura dos sensores.
					sensors->refresh();
				}

				// volta para a posição convencional.
				if (isLeftToRight)
				{
					driver->setPosition(0, x_base + delta_x, y_small, z_base);
					driver->setPosition(1, x_base, 0, z_base);
					driver->setPosition(2, x_base + delta_x, -y_small, z_base);
					driver->setPosition(3, -x_base, -y_base, z_base - delta_z);
					driver->setPosition(4, -x_base, 0, z_base);
					driver->setPosition(5, -x_base, y_base, z_base - delta_z);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_base + delta_x, y_small, z_base);
					driver->setPosition(1, x_base, 0, z_base);
					driver->setPosition(2, x_base + delta_x, -y_small, z_base);
					driver->setPosition(3, -x_base, -y_base, z_base);
					driver->setPosition(4, -x_base, 0, z_base);
					driver->setPosition(5, -x_base, y_base, z_base);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_base, y_base, z_base - delta_z);
					driver->setPosition(1, x_base, 0, z_base);
					driver->setPosition(2, x_base, -y_base, z_base - delta_z);
					driver->setPosition(3, -x_base, -y_base, z_base);
					driver->setPosition(4, -x_base, 0, z_base);
					driver->setPosition(5, -x_base, y_base, z_base);
					driver->move(delay, numInterpol);
				}
				else
				{
					driver->setPosition(0, x_base, y_base, z_base - delta_z);
					driver->setPosition(1, x_base, 0, z_base);
					driver->setPosition(2, x_base, -y_base, z_base - delta_z);
					driver->setPosition(3, -x_base - delta_x, -y_small, z_base);
					driver->setPosition(4, -x_base, 0, z_base - delta_z);
					driver->setPosition(5, -x_base - delta_x, y_small, z_base);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_base, y_base, z_base);
					driver->setPosition(1, x_base, 0, z_base);
					driver->setPosition(2, x_base, -y_base, z_base);
					driver->setPosition(3, -x_base - delta_x, -y_small, z_base);
					driver->setPosition(4, -x_base, 0, z_base);
					driver->setPosition(5, -x_base - delta_x, y_small, z_base);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_base, y_base, z_base);
					driver->setPosition(1, x_base, 0, z_base);
					driver->setPosition(2, x_base, -y_base, z_base);
					driver->setPosition(3, -x_base, -y_base, z_base - delta_z);
					driver->setPosition(4, -x_base, 0, z_base);
					driver->setPosition(5, -x_base, y_base, z_base - delta_z);
					driver->move(delay, numInterpol);
				}
			}

/* -------------------- MOVIMENTOS DE GIRAR EM TORNO DO PRÓPRIO EIXO -------------------- */

			void rotateToAdjust(drivers::InterpolationDriver* driver, MovementManager* manager, SensorsManager* sensors, int id, int& steps, int totalSteps)
			{
				// constantes de interpolação.
				int delay = (int)15e3;
				int numInterpol = 20;

				// constantes de movimento.
				int x_small = x_base_small;
				int y_small = y_base_small;
				int delta_y = rotate_delta_y;
				int delta_z = rotate_delta_z;

				// aproxima as patas
				driver->setPosition(0, x_base, y_base, z_base - delta_z);
				driver->setPosition(1, x_small, 0, z_base);
				driver->setPosition(2, x_base, -y_base, z_base - delta_z);
				driver->setPosition(3, -x_small, -y_small, z_base);
				driver->setPosition(4, -x_base, 0, z_base - delta_z);
				driver->setPosition(5, -x_small, y_small, z_base);
				driver->move(delay, numInterpol);

				driver->setPosition(0, x_base, y_base, z_base);
				driver->setPosition(1, x_small, 0, z_base);
				driver->setPosition(2, x_base, -y_base, z_base);
				driver->setPosition(3, -x_small, -y_small, z_base);
				driver->setPosition(4, -x_base, 0, z_base);
				driver->setPosition(5, -x_small, y_small, z_base);
				driver->move(delay, numInterpol);

				driver->setPosition(0, x_small, y_small, z_base);
				driver->setPosition(1, x_small, 0, z_base - delta_z);
				driver->setPosition(2, x_small, -y_small, z_base);
				driver->setPosition(3, -x_small, -y_small, z_base - delta_z);
				driver->setPosition(4, -x_small, 0, z_base);
				driver->setPosition(5, -x_small, y_small, z_base - delta_z);
				driver->move(delay, numInterpol);

				driver->setPosition(0, x_small, y_small, z_base);
				driver->setPosition(1, x_small, 0, z_base);
				driver->setPosition(2, x_small, -y_small, z_base);
				driver->setPosition(3, -x_small, -y_small, z_base);
				driver->setPosition(4, -x_small, 0, z_base);
				driver->setPosition(5, -x_small, y_small, z_base);
				driver->move(delay, numInterpol);

				for (steps = 0; steps < totalSteps; steps ++)
				{
					driver->setPosition(0, x_small, y_small + delta_y, z_base);
					driver->setPosition(1, x_small, -delta_y, z_base - delta_z);
					driver->setPosition(2, x_small, -y_small, z_base);
					driver->setPosition(3, -x_small, -y_small, z_base - delta_z);
					driver->setPosition(4, -x_small, 0, z_base);
					driver->setPosition(5, -x_small, y_small + delta_y, z_base - delta_z);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_small, y_small, z_base);
					driver->setPosition(1, x_small, -delta_y, z_base - delta_z);
					driver->setPosition(2, x_small, -y_small - delta_y, z_base);
					driver->setPosition(3, -x_small, -y_small, z_base - delta_z);
					driver->setPosition(4, -x_small, +delta_y, z_base);
					driver->setPosition(5, -x_small, y_small + delta_y, z_base - delta_z);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_small, y_small, z_base);
					driver->setPosition(1, x_small, 0, z_base - delta_z);
					driver->setPosition(2, x_small, -y_small - delta_y, z_base);
					driver->setPosition(3, -x_small, -y_small - delta_y, z_base - delta_z);
					driver->setPosition(4, -x_small, +delta_y, z_base);
					driver->setPosition(5, -x_small, y_small, z_base - delta_z);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_small, y_small, z_base - delta_z);
					driver->setPosition(1, x_small, 0, z_base);
					driver->setPosition(2, x_small, -y_small - delta_y, z_base - delta_z);
					driver->setPosition(3, -x_small, -y_small - delta_y, z_base);
					driver->setPosition(4, -x_small, +delta_y, z_base - delta_z);
					driver->setPosition(5, -x_small, y_small, z_base);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_small, y_small + delta_y, z_base - delta_z);
					driver->setPosition(1, x_small, 0, z_base);
					driver->setPosition(2, x_small, -y_small, z_base - delta_z);
					driver->setPosition(3, -x_small, -y_small - delta_y, z_base);
					driver->setPosition(4, -x_small, 0, z_base - delta_z);
					driver->setPosition(5, -x_small, y_small, z_base);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_small, y_small + delta_y, z_base - delta_z);
					driver->setPosition(1, x_small, -delta_y, z_base);
					driver->setPosition(2, x_small, -y_small, z_base - delta_z);
					driver->setPosition(3, -x_small, -y_small, z_base);
					driver->setPosition(4, -x_small, 0, z_base - delta_z);
					driver->setPosition(5, -x_small, y_small + delta_y, z_base);
					driver->move(delay, numInterpol);

					// verifica se deve parar.
					if (manager->shouldStop(id))
					{
						break;
					}

					// atualiza a leitura dos sensores.
					sensors->refresh();
				}

				// afasta as patas
				driver->setPosition(0, x_small, y_small, z_base);
				driver->setPosition(1, x_small, 0, z_base);
				driver->setPosition(2, x_small, -y_small, z_base);
				driver->setPosition(3, -x_small, -y_small, z_base);
				driver->setPosition(4, -x_small, 0, z_base);
				driver->setPosition(5, -x_small, y_small, z_base);
				driver->move(delay, numInterpol);

				driver->setPosition(0, x_base, y_base, z_base);
				driver->setPosition(1, x_small, 0, z_base - delta_z);
				driver->setPosition(2, x_base, -y_base, z_base);
				driver->setPosition(3, -x_small, -y_small, z_base - delta_z);
				driver->setPosition(4, -x_base, 0, z_base);
				driver->setPosition(5, -x_small, y_small, z_base - delta_z);
				driver->move(delay, numInterpol);

				driver->setPosition(0, x_base, y_base, z_base);
				driver->setPosition(1, x_small, 0, z_base);
				driver->setPosition(2, x_base, -y_base, z_base);
				driver->setPosition(3, -x_small, -y_small, z_base);
				driver->setPosition(4, -x_base, 0, z_base);
				driver->setPosition(5, -x_small, y_small, z_base);
				driver->move(delay, numInterpol);

				driver->setPosition(0, x_base, y_base, z_base - delta_z);
				driver->setPosition(1, x_base, 0, z_base);
				driver->setPosition(2, x_base, -y_base, z_base - delta_z);
				driver->setPosition(3, -x_base, -y_base, z_base);
				driver->setPosition(4, -x_base, 0, z_base - delta_z);
				driver->setPosition(5, -x_base, y_base, z_base);
				driver->move(delay, numInterpol);
			}

			void rotateArroundZ(drivers::InterpolationDriver* driver, MovementManager* manager, SensorsManager* sensors, int id, int &currentAngle, int targetAngle)
			{
				// constantes de interpolação.
				const int numInterpol = 20;
				const int delay = (int)15e3;

				// constantes de movimento.
				const int x_small = x_base_small;
				const int y_small = y_base_small;
				const int max_delta_y = rotate_delta_y;
				const int delta_z = rotate_delta_z;

				// conbstantes usadas no alinhamento.
				const int min_error = 3;
				const int P = 100;

				// variáveis usadas no alinhamento.
				bool isClock;
				int error = targetAngle - currentAngle;

				// variáveis de movimento.
				int delta_y = max_delta_y;

				// faz a rotação.
				while (abs(error) > min_error)
				{
					if (error > 180)
					{
						error -= 360;
					}
					else if (error < -180)
					{
						error += 360;
					}
					if (error > 0)
					{
						isClock = false;
					}
					else
					{
						isClock = true;
					}
					delta_y = (int)P*abs(error)/100;
					if (delta_y > max_delta_y)
					{
						delta_y = max_delta_y;
					}

					if (isClock)
					{
						driver->setPosition(0, x_small, y_small + delta_y, z_base - delta_z);
						driver->setPosition(1, x_small, 0, z_base);
						driver->setPosition(2, x_small, -y_small, z_base - delta_z);
						driver->setPosition(3, -x_small, -y_small, z_base);
						driver->setPosition(4, -x_small, -delta_y, z_base - delta_z);
						driver->setPosition(5, -x_small, y_small + delta_y, z_base);
						driver->move(delay, numInterpol);

						driver->setPosition(0, x_small, y_small, z_base - delta_z);
						driver->setPosition(1, x_small, 0, z_base);
						driver->setPosition(2, x_small, -y_small - delta_y, z_base - delta_z);
						driver->setPosition(3, -x_small, -y_small, z_base);
						driver->setPosition(4, -x_small, 0, z_base - delta_z);
						driver->setPosition(5, -x_small, y_small + delta_y, z_base);
						driver->move(delay, numInterpol);

						driver->setPosition(0, x_small, y_small, z_base - delta_z);
						driver->setPosition(1, x_small, +delta_y, z_base);
						driver->setPosition(2, x_small, -y_small - delta_y, z_base - delta_z);
						driver->setPosition(3, -x_small, -y_small - delta_y, z_base);
						driver->setPosition(4, -x_small, 0, z_base - delta_z);
						driver->setPosition(5, -x_small, y_small, z_base);
						driver->move(delay, numInterpol);

						driver->setPosition(0, x_small, y_small, z_base);
						driver->setPosition(1, x_small, +delta_y, z_base - delta_z);
						driver->setPosition(2, x_small, -y_small - delta_y, z_base);
						driver->setPosition(3, -x_small, -y_small - delta_y, z_base - delta_z);
						driver->setPosition(4, -x_small, 0, z_base);
						driver->setPosition(5, -x_small, y_small, z_base - delta_z);
						driver->move(delay, numInterpol);

						driver->setPosition(0, x_small, y_small + delta_y, z_base);
						driver->setPosition(1, x_small, +delta_y, z_base - delta_z);
						driver->setPosition(2, x_small, -y_small, z_base);
						driver->setPosition(3, -x_small, -y_small - delta_y, z_base - delta_z);
						driver->setPosition(4, -x_small, -delta_y, z_base);
						driver->setPosition(5, -x_small, y_small, z_base - delta_z);
						driver->move(delay, numInterpol);

						driver->setPosition(0, x_small, y_small + delta_y, z_base);
						driver->setPosition(1, x_small, 0, z_base - delta_z);
						driver->setPosition(2, x_small, -y_small, z_base);
						driver->setPosition(3, -x_small, -y_small, z_base - delta_z);
						driver->setPosition(4, -x_small, -delta_y, z_base);
						driver->setPosition(5, -x_small, y_small + delta_y, z_base - delta_z);
						driver->move(delay, numInterpol);
					}
					else
					{
						driver->setPosition(0, x_small, y_small + delta_y, z_base);
						driver->setPosition(1, x_small, -delta_y, z_base - delta_z);
						driver->setPosition(2, x_small, -y_small, z_base);
						driver->setPosition(3, -x_small, -y_small, z_base - delta_z);
						driver->setPosition(4, -x_small, 0, z_base);
						driver->setPosition(5, -x_small, y_small + delta_y, z_base - delta_z);
						driver->move(delay, numInterpol);

						driver->setPosition(0, x_small, y_small, z_base);
						driver->setPosition(1, x_small, -delta_y, z_base - delta_z);
						driver->setPosition(2, x_small, -y_small - delta_y, z_base);
						driver->setPosition(3, -x_small, -y_small, z_base - delta_z);
						driver->setPosition(4, -x_small, +delta_y, z_base);
						driver->setPosition(5, -x_small, y_small + delta_y, z_base - delta_z);
						driver->move(delay, numInterpol);

						driver->setPosition(0, x_small, y_small, z_base);
						driver->setPosition(1, x_small, 0, z_base - delta_z);
						driver->setPosition(2, x_small, -y_small - delta_y, z_base);
						driver->setPosition(3, -x_small, -y_small - delta_y, z_base - delta_z);
						driver->setPosition(4, -x_small, +delta_y, z_base);
						driver->setPosition(5, -x_small, y_small, z_base - delta_z);
						driver->move(delay, numInterpol);

						driver->setPosition(0, x_small, y_small, z_base - delta_z);
						driver->setPosition(1, x_small, 0, z_base);
						driver->setPosition(2, x_small, -y_small - delta_y, z_base - delta_z);
						driver->setPosition(3, -x_small, -y_small - delta_y, z_base);
						driver->setPosition(4, -x_small, +delta_y, z_base - delta_z);
						driver->setPosition(5, -x_small, y_small, z_base);
						driver->move(delay, numInterpol);

						driver->setPosition(0, x_small, y_small + delta_y, z_base - delta_z);
						driver->setPosition(1, x_small, 0, z_base);
						driver->setPosition(2, x_small, -y_small, z_base - delta_z);
						driver->setPosition(3, -x_small, -y_small - delta_y, z_base);
						driver->setPosition(4, -x_small, 0, z_base - delta_z);
						driver->setPosition(5, -x_small, y_small, z_base);
						driver->move(delay, numInterpol);

						driver->setPosition(0, x_small, y_small + delta_y, z_base - delta_z);
						driver->setPosition(1, x_small, -delta_y, z_base);
						driver->setPosition(2, x_small, -y_small, z_base - delta_z);
						driver->setPosition(3, -x_small, -y_small, z_base);
						driver->setPosition(4, -x_small, 0, z_base - delta_z);
						driver->setPosition(5, -x_small, y_small + delta_y, z_base);
						driver->move(delay, numInterpol);
					}

					// verifica se deve parar.
					if (manager->shouldStop(id))
					{
						break;
					}

					// atualiza a leitura dos sensores.
					sensors->refresh();

					// atualiza a leitura do magnetômetro.
					{
						MagnetometerData data;
						sensors->readMagnetometer(data);
						currentAngle = (int)data.heading;
					}
					error = targetAngle - currentAngle;
				}

				// volta para a posição convencional.
				if (isClock)
				{
					driver->setPosition(0, x_small, y_small + delta_y, z_base);
					driver->setPosition(1, x_small, 0, z_base - delta_z);
					driver->setPosition(2, x_small, -y_small, z_base);
					driver->setPosition(3, -x_small, -y_base, z_base - delta_z);
					driver->setPosition(4, -x_small, -delta_y, z_base);
					driver->setPosition(5, -x_small, y_base, z_base - delta_z);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_small, y_small + delta_y, z_base - delta_z);
					driver->setPosition(1, x_small, 0, z_base);
					driver->setPosition(2, x_small, -y_small, z_base - delta_z);
					driver->setPosition(3, -x_small, -y_base, z_base);
					driver->setPosition(4, -x_small, -delta_y, z_base - delta_z);
					driver->setPosition(5, -x_small, y_base, z_base);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_small, y_base, z_base - delta_z);
					driver->setPosition(1, x_small, 0, z_base);
					driver->setPosition(2, x_small, -y_base, z_base - delta_z);
					driver->setPosition(3, -x_small, -y_base, z_base);
					driver->setPosition(4, -x_small, 0, z_base - delta_z);
					driver->setPosition(5, -x_small, y_base, z_base);
					driver->move(delay, numInterpol);
				}
				else
				{
					driver->setPosition(0, x_small, y_base, z_base - delta_z);
					driver->setPosition(1, x_small, -delta_y, z_base);
					driver->setPosition(2, x_small, -y_base, z_base - delta_z);
					driver->setPosition(3, -x_small, -y_small, z_base);
					driver->setPosition(4, -x_small, 0, z_base - delta_z);
					driver->setPosition(5, -x_small, y_small + delta_y, z_base);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_small, y_base, z_base);
					driver->setPosition(1, x_small, -delta_y, z_base - delta_z);
					driver->setPosition(2, x_small, -y_base, z_base);
					driver->setPosition(3, -x_small, -y_small, z_base - delta_z);
					driver->setPosition(4, -x_small, 0, z_base);
					driver->setPosition(5, -x_small, y_small + delta_y, z_base - delta_z);
					driver->move(delay, numInterpol);

					driver->setPosition(0, x_small, y_base, z_base);
					driver->setPosition(1, x_small, 0, z_base - delta_z);
					driver->setPosition(2, x_small, -y_base, z_base);
					driver->setPosition(3, -x_small, -y_base, z_base - delta_z);
					driver->setPosition(4, -x_small, 0, z_base);
					driver->setPosition(5, -x_small, y_base, z_base - delta_z);
					driver->move(delay, numInterpol);
				}
			}

/* -------------------- MOVIMENTOS DIVERSOS -------------------- */

			void pushUp(drivers::InterpolationDriver* driver, MovementManager* manager, SensorsManager* sensors, int id, int& pushUps, int totalPushUps)
			{
				// constantes de interpolação.
				const int delay = (int)10e3;
				const int numInterpol = 10;

				// constantes de movimento.
				const int front_x_offset_max = 0;
				const int front_x_offset_min = -20;
				const int mid_x_offset = -80;
				const int back_x_offset = 15;
				const int back_delta_y = 50;
				const int delta_z = 10;
				const int z_min = 35;
				const int z_mid = 0;
				const int z_max = 90;

				// Ergue as patas 0 e 3
				driver->setPosition(0, x_base, y_base, z_base - delta_z);
				driver->setPosition(1, x_base, 0, z_base);
				driver->setPosition(2, x_base, -y_base, z_base);
				driver->setPosition(3, -x_base, -y_base, z_base - delta_z);
				driver->setPosition(4, -x_base, 0, z_base);
				driver->setPosition(5, -x_base, y_base, z_base);
				driver->move(delay, numInterpol);

				// Move a pata 0 para a direita e a pata 3 para direita e para tras
				driver->setPosition(0, x_base + front_x_offset_max, y_base, z_base - delta_z);
				driver->setPosition(1, x_base, 0, z_base);
				driver->setPosition(2, x_base, -y_base, z_base);
				driver->setPosition(3, -x_base + back_x_offset, -y_base - back_delta_y, z_base - delta_z);
				driver->setPosition(4, -x_base, 0, z_base);
				driver->setPosition(5, -x_base, y_base, z_base);
				driver->move(delay, numInterpol);

				// Desce as patas 0 e 3
				driver->setPosition(0, x_base + front_x_offset_max, y_base, z_base);
				driver->setPosition(1, x_base, 0, z_base);
				driver->setPosition(2, x_base, -y_base, z_base);
				driver->setPosition(3, -x_base + back_x_offset, -y_base - back_delta_y, z_base);
				driver->setPosition(4, -x_base, 0, z_base);
				driver->setPosition(5, -x_base, y_base, z_base);
				driver->move(delay, numInterpol);

				// Ergue as patas 2 e 5
				driver->setPosition(0, x_base + front_x_offset_max, y_base, z_base);
				driver->setPosition(1, x_base, 0, z_base);
				driver->setPosition(2, x_base, -y_base, z_base - delta_z);
				driver->setPosition(3, -x_base + back_x_offset, -y_base - back_delta_y, z_base);
				driver->setPosition(4, -x_base, 0, z_base);
				driver->setPosition(5, -x_base, y_base, z_base - delta_z);
				driver->move(delay, numInterpol);

				// Move a pata 2 para esquerda e para tras e a pata 5 para esquerda
				driver->setPosition(0, x_base + front_x_offset_max, y_base, z_base);
				driver->setPosition(1, x_base, 0, z_base);
				driver->setPosition(2, x_base - back_x_offset, -y_base - back_delta_y, z_base - delta_z);
				driver->setPosition(3, -x_base + back_x_offset, -y_base - back_delta_y, z_base);
				driver->setPosition(4, -x_base, 0, z_base);
				driver->setPosition(5, -x_base - front_x_offset_max, y_base, z_base - delta_z);
				driver->move(delay, numInterpol);

				// Desce as patas 2 e 5
				driver->setPosition(0, x_base + front_x_offset_max, y_base, z_base);
				driver->setPosition(1, x_base, 0, z_base);
				driver->setPosition(2, x_base - back_x_offset, -y_base - back_delta_y, z_base);
				driver->setPosition(3, -x_base + back_x_offset, -y_base - back_delta_y, z_base);
				driver->setPosition(4, -x_base, 0, z_base);
				driver->setPosition(5, -x_base - front_x_offset_max, y_base, z_base);
				driver->move(delay, numInterpol);

				// Desce as patas 1, 2, 3 e 4 para o minimo, levanta as patas 0, 5 para o maximo
				driver->setPosition(0, x_base + front_x_offset_max, y_base, z_max);
				driver->setPosition(1, x_base, 0, z_mid);
				driver->setPosition(2, x_base - back_x_offset, -y_base - back_delta_y, z_min);
				driver->setPosition(3, -x_base + back_x_offset, -y_base - back_delta_y, z_min);
				driver->setPosition(4, -x_base, 0, z_mid);
				driver->setPosition(5, -x_base - front_x_offset_max, y_base, z_max);
				driver->move(delay, numInterpol);

				// Encolhe as patas 1 e 4
				driver->setPosition(0, x_base + front_x_offset_max, y_base, z_max);
				driver->setPosition(1, x_base - mid_x_offset, 0, z_mid);
				driver->setPosition(2, x_base - back_x_offset, -y_base - back_delta_y, z_min);
				driver->setPosition(3, -x_base + back_x_offset, -y_base - back_delta_y, z_min);
				driver->setPosition(4, -x_base + mid_x_offset, 0, z_mid);
				driver->setPosition(5, -x_base - front_x_offset_max, y_base, z_max);
				driver->move(delay, numInterpol);

				for (pushUps = 0; pushUps < totalPushUps; pushUps ++)
				{
					// Abaixa as patas 0 e 5 até o mínimo
					driver->setPosition(0, x_base + front_x_offset_min, y_base, z_min);
					driver->setPosition(1, x_base - mid_x_offset, 0, z_mid);
					driver->setPosition(2, x_base - back_x_offset, -y_base - back_delta_y, z_min);
					driver->setPosition(3, -x_base + back_x_offset, -y_base - back_delta_y, z_min);
					driver->setPosition(4, -x_base + mid_x_offset, 0, z_mid);
					driver->setPosition(5, -x_base - front_x_offset_min, y_base, z_min);
					driver->move(8*delay, 8*numInterpol);

					// Ergue as patas o e 5 até o maximo
					driver->setPosition(0, x_base + front_x_offset_max, y_base, z_max);
					driver->setPosition(1, x_base - mid_x_offset, 0, z_mid);
					driver->setPosition(2, x_base - back_x_offset, -y_base - back_delta_y, z_min);
					driver->setPosition(3, -x_base + back_x_offset, -y_base - back_delta_y, z_min);
					driver->setPosition(4, -x_base + mid_x_offset, 0, z_mid);
					driver->setPosition(5, -x_base - front_x_offset_max, y_base, z_max);
					driver->move(8*delay, 8*numInterpol);

					if (manager->shouldStop(id))
					{
						break;
					}
					manager->getSensors()->refresh();

				}

				// Volta as patas 1 e 4 para posição padrão
				driver->setPosition(0, x_base + front_x_offset_max, y_base, z_max);
				driver->setPosition(1, x_base, 0, z_mid);
				driver->setPosition(2, x_base - back_x_offset, -y_base - back_delta_y, z_min);
				driver->setPosition(3, -x_base + back_x_offset, -y_base - back_delta_y, z_min);
				driver->setPosition(4, -x_base, 0, z_mid);
				driver->setPosition(5, -x_base - front_x_offset_max, y_base, z_max);
				driver->move(delay, numInterpol);

				// Retorna a altura certa
				driver->setPosition(0, x_base + front_x_offset_max, y_base, z_base);
				driver->setPosition(1, x_base, 0, z_base);
				driver->setPosition(2, x_base - back_x_offset, -y_base - back_delta_y, z_base);
				driver->setPosition(3, -x_base + back_x_offset, -y_base - back_delta_y, z_base);
				driver->setPosition(4, -x_base, 0, z_base);
				driver->setPosition(5, -x_base - front_x_offset_max, y_base, z_base);
				driver->move(delay, numInterpol);

				// Ergue as patas 2 e 5
				driver->setPosition(0, x_base + front_x_offset_max, y_base, z_base);
				driver->setPosition(1, x_base, 0, z_base);
				driver->setPosition(2, x_base - back_x_offset, -y_base - back_delta_y, z_base - delta_z);
				driver->setPosition(3, -x_base + back_x_offset, -y_base - back_delta_y, z_base);
				driver->setPosition(4, -x_base, 0, z_base);
				driver->setPosition(5, -x_base - front_x_offset_max, y_base, z_base - delta_z);
				driver->move(delay, numInterpol);

				// Retorna as patas 2 e 5 para posição padrão
				driver->setPosition(0, x_base + front_x_offset_max, y_base, z_base);
				driver->setPosition(1, x_base, 0, z_base);
				driver->setPosition(2, x_base, -y_base, z_base - delta_z);
				driver->setPosition(3, -x_base + back_x_offset, -y_base - back_delta_y, z_base);
				driver->setPosition(4, -x_base, 0, z_base);
				driver->setPosition(5, -x_base, y_base, z_base - delta_z);
				driver->move(delay, numInterpol);

				// Abaixa as patas 2 e 5
				driver->setPosition(0, x_base + front_x_offset_max, y_base, z_base);
				driver->setPosition(1, x_base, 0, z_base);
				driver->setPosition(2, x_base, -y_base, z_base);
				driver->setPosition(3, -x_base + back_x_offset, -y_base - back_delta_y, z_base);
				driver->setPosition(4, -x_base, 0, z_base);
				driver->setPosition(5, -x_base, y_base, z_base);
				driver->move(delay, numInterpol);

				// Ergue as patas 0 e 3
				driver->setPosition(0, x_base + front_x_offset_max, y_base, z_base - delta_z);
				driver->setPosition(1, x_base, 0, z_base);
				driver->setPosition(2, x_base, -y_base, z_base);
				driver->setPosition(3, -x_base + back_x_offset, -y_base - back_delta_y, z_base - delta_z);
				driver->setPosition(4, -x_base, 0, z_base);
				driver->setPosition(5, -x_base, y_base, z_base);
				driver->move(delay, numInterpol);

				// Volta as patas 0 e 3 para posicao padrao
				driver->setPosition(0, x_base, y_base, z_base - delta_z);
				driver->setPosition(1, x_base, 0, z_base);
				driver->setPosition(2, x_base, -y_base, z_base);
				driver->setPosition(3, -x_base, -y_base, z_base - delta_z);
				driver->setPosition(4, -x_base, 0, z_base);
				driver->setPosition(5, -x_base, y_base, z_base);
				driver->move(delay, numInterpol);

				// Desce as patas 0 e 3
				driver->setPosition(0, x_base, y_base, z_base);
				driver->setPosition(1, x_base, 0, z_base);
				driver->setPosition(2, x_base, -y_base, z_base);
				driver->setPosition(3, -x_base, -y_base, z_base);
				driver->setPosition(4, -x_base, 0, z_base);
				driver->setPosition(5, -x_base, y_base, z_base);
				driver->move(delay, numInterpol);
			}

			void hulaHoop(drivers::InterpolationDriver* driver, MovementManager* manager, SensorsManager* sensors, int id, int& cycles, int totalCycles)
			{
				// constantes de interpolação.
				const int delay = (int)10e3;
				const int numInterpol = 10;

				// constantes de movimento.
				const int centro_offset_x = 50;
				const int y_big = 75;
				const int z_very_low = 20;
				const int z_low = 40;
				const int z_high = 60;
				const int z_very_high = 80;

				for (cycles = 0; cycles < totalCycles; cycles ++)
				{
					// pata 0 no nivel mais alto e pata 3 no mais baixo
					driver->setPosition(0, x_base, y_big, z_very_high);
					driver->setPosition(1, x_base + centro_offset_x, 0, z_high);
					driver->setPosition(2, x_base, -y_big, z_low);
					driver->setPosition(3, -x_base, -y_big, z_very_low);
					driver->setPosition(4, -x_base - centro_offset_x, 0, z_low);
					driver->setPosition(5, -x_base, y_big, z_high);
					driver->move(delay, numInterpol);

					// pata 1 no nivel mais alto e pata 4 no mais baixo
					driver->setPosition(0, x_base, y_big, z_high);
					driver->setPosition(1, x_base + centro_offset_x, 0, z_very_high);
					driver->setPosition(2, x_base, -y_big, z_high);
					driver->setPosition(3, -x_base, -y_big, z_low);
					driver->setPosition(4, -x_base - centro_offset_x, 0, z_very_low);
					driver->setPosition(5, -x_base, y_big, z_low);
					driver->move(delay, numInterpol);

					// pata 2 no nivel mais alto e pata 5 no mais baixo
					driver->setPosition(0, x_base, y_big, z_low);
					driver->setPosition(1, x_base + centro_offset_x, 0, z_high);
					driver->setPosition(2, x_base, -y_big, z_very_high);
					driver->setPosition(3, -x_base, -y_big, z_high);
					driver->setPosition(4, -x_base - centro_offset_x, 0, z_low);
					driver->setPosition(5, -x_base, y_big, z_very_low);
					driver->move(delay, numInterpol);

					// pata 3 no nivel mais alto e pata 0 no mais baixo
					driver->setPosition(0, x_base, y_big, z_very_low);
					driver->setPosition(1, x_base + centro_offset_x, 0, z_low);
					driver->setPosition(2, x_base, -y_big, z_high);
					driver->setPosition(3, -x_base, -y_big, z_very_high);
					driver->setPosition(4, -x_base - centro_offset_x, 0, z_high);
					driver->setPosition(5, -x_base, y_big, z_low);
					driver->move(delay, numInterpol);

					// pata 4 no nivel mais alto e pata 1 no mais baixo
					driver->setPosition(0, x_base, y_big, z_low);
					driver->setPosition(1, x_base + centro_offset_x, 0, z_very_low);
					driver->setPosition(2, x_base, -y_big, z_low);
					driver->setPosition(3, -x_base, -y_big, z_high);
					driver->setPosition(4, -x_base - centro_offset_x, 0, z_very_high);
					driver->setPosition(5, -x_base, y_big, z_high);
					driver->move(delay, numInterpol);

					// pata 5 no nivel mais alto e pata 2 no mais baixo
					driver->setPosition(0, x_base, y_big, z_high);
					driver->setPosition(1, x_base + centro_offset_x, 0, z_low);
					driver->setPosition(2, x_base, -y_big, z_very_low);
					driver->setPosition(3, -x_base, -y_big, z_low);
					driver->setPosition(4, -x_base - centro_offset_x, 0, z_high);
					driver->setPosition(5, -x_base, y_big, z_very_high);
					driver->move(delay, numInterpol);

					if (manager->shouldStop(id))
					{
						break;
					}

					manager->getSensors()->refresh();
				}
			}
		}
	}
}


